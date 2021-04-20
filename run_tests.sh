#!/bin/bash
RUN_DIR="$(dirname "$0")"
export BASE_DIR=${BASE_DIR:-$RUN_DIR}
# Set up the environment, to use local perl modules
export PERL5LIB="${BASE_DIR}/lib"
BIN_DIR="${BASE_DIR}/bin"
GROUP="${GROUP:-scenarios}"
LOG_DIR="${BASE_DIR}/log/${GROUP}"
MLOG_DIR="${BASE_DIR}/mem"
KAM_LOG=${KAM_LOG:-"/var/log/ngcp/kamailio-proxy.log"}
KAMLB_LOG=${KAMLB_LOG:-"/var/log/ngcp/kamailio-lb.log"}
SEMS_LOG=${SEMS_LOG:-"/var/log/ngcp/sems.log"}
SEMS_PBX_LOG=${SEMS_PBX_LOG:-"/var/log/ngcp/sems-pbx.log"}
RTP_LOG=${RTP_LOG:-"/var/log/ngcp/rtp.log"}
TMP_LOG_DIR="/tmp"
KAM_DIR="/tmp/cfgtest"
COREDUMP_DIR="/ngcp-data/coredumps"
PROFILE="${PROFILE:-}"
OPTS=(-P -T -M) #SKIP_PARSE=true, SKIP_TESTS=true, SKIP_MOVE_JSON_KAM=true

TIMEOUT=${TIMEOUT:-300}
SHOW_SCENARIOS=false
SKIP_CONFIG=false
CAPTURE=false
SINGLE_CAPTURE=false
FIX_RETRANS=false
MEMDBG=false
CDR=false
START_TIME=$(date +%s)
error_flag=0
SCEN=()

get_scenarios() {
  while read -r t; do
    SCEN+=( "${t}" )
  done < <("${BIN_DIR}/get_scenarios.sh" -p "${PROFILE}" -x "${GROUP}")
  if [[ ${#SCEN[@]} == 0 ]]; then
    echo "$(date) no scenarios found"
    exit 1
  fi
}

cfg_debug_off() {
  if ! "${SKIP_CONFIG}" ; then
    echo "$(date) - Removed apicert.pem"
    rm -f "${BASE_DIR}/apicert.pem"
    echo "$(date) - Setting config debug off"
    "${BIN_DIR}/config_debug.pl" -g "${GROUP}" off
    echo "$(date) - Setting network config off"
    "${BIN_DIR}/network_config.pl" -g "${GROUP}" off
    dummy_ip=$(ip addr show dummy0 | grep inet | awk '{print $2}' | head -1)
    if [ -n "${dummy_ip}" ]; then
      echo "$(date) - start dummy0 interface"
      ifdown dummy0
    fi
    if lsmod | grep -q dummy ; then
      echo "$(date) - remove dummy module"
      rmmod dummy
    fi
    if ! ngcpcfg --summary-only apply "config debug off via kamailio-config-tests" ; then
      echo "$(date) - ngcpcfg apply returned $?"
      error_flag=4
    fi
    echo "$(date) - Setting config debug off. Done[${error_flag}]"
  fi
}

copy_logs_to_tmp() {
  # copy the kamailio log
  cp -a "${KAM_LOG}" "${TMP_LOG_DIR}/tmp_kamailio.log"
  if [ -f "${SEMS_LOG}" ] ; then
    # copy the sems log
    cp -a "${SEMS_LOG}" "${TMP_LOG_DIR}/tmp_sems.log"
  fi
  if [ -f "${SEMS_PBX_LOG}" ] ; then
    # copy the sems-pbx log
    cp -a "${SEMS_PBX_LOG}" "${TMP_LOG_DIR}/tmp_sems-pbx.log"
  fi
  # copy the kamailio-lb log
  cp -a "${KAMLB_LOG}" "${TMP_LOG_DIR}/tmp_kamailio-lb.log"
}

copy_logs_from_tmp() {
  # copy the kamailio log
  cp -a "${TMP_LOG_DIR}/tmp_kamailio.log" "${KAM_LOG}"
  if [ -f "${SEMS_LOG}" ] ; then
    # copy the sems log
    cp -a "${TMP_LOG_DIR}/tmp_sems.log" "${SEMS_LOG}"
  fi
  if [ -f "${TMP_LOG_DIR}/tmp_sems-pbx.log" ] ; then
    # copy the sems-pbx log
    cp -a "${TMP_LOG_DIR}/tmp_sems-pbx.log" "${SEMS_PBX_LOG}"
  fi
  # copy the kamailio-lb log
  cp -a "${TMP_LOG_DIR}/tmp_kamailio-lb.log" "${KAMLB_LOG}"
}

capture() {
  echo "$(date) - ================================================================================="
  echo "$(date) - Start tcpdump captures"
  datetime=$(date '+%y%m%d_%H%M')
  for inter in $(ip link | grep '^[0-9]' | cut -d: -f2 | sed 's/ //' | xargs); do
    tcpdump -i "${inter}" -n -s 65535 -w "${LOG_DIR}/_traces_${inter}_${datetime}.pcap" &
    capture_pid="${capture_pid} ${inter}:$!"
  done
  echo "$(date) - Done"
  echo "$(date) - ================================================================================="
}

stop_capture() {
  echo "$(date) - ================================================================================="
  echo "$(date) - Stop tcpdump captures"
  local inter=""
  local temp_pid=""
  if [ -n "${capture_pid}" ]; then
    for temp in ${capture_pid}; do
      inter=$(echo "$temp"|cut -d: -f1)
      temp_pid=$(echo "$temp"|cut -d: -f2)
      #echo "inter:${inter} temp_pid:${temp_pid}"
      if ps -p"${temp_pid}" &> /dev/null ; then
        echo "$(date) - End ${inter}[${temp_pid}] capture"
        kill -15 "${temp_pid}"
      fi
    done
  fi
  echo "$(date) - Done"
  echo "$(date) - ================================================================================="
}

move_json_file() {
  echo "$(date) - ================================================================================="
  echo "$(date) - Move kamailio json files"
  for t in "${SCEN[@]}"; do
    echo "$(date) - - Scenario: ${t}"
    json_dir="${KAM_DIR}/${t}"
    if [ -d "${json_dir}" ] ; then
      for i in "${json_dir}"/*.json ; do
        json_size_before=$(stat -c%s "${i}")
        moved_file="${LOG_DIR}/${t}/$(printf "%04d.json" "$(basename "$i" .json)")"
        expand -t1 "${i}" > "${moved_file}"
        json_size_after=$(stat -c%s "${moved_file}")
        if [ "${json_size_before}" -ne "${json_size_after}" ] ; then
          echo "$(date) - - - Moved file ${i} with size before: ${json_size_before} and after: ${json_size_after}"
        fi
        rm "${i}"
      done
      rm -rf "${json_dir}"
    fi
  done

  echo "$(date) - Done"
  echo "$(date) - ================================================================================="
}

fix_retransmissions() {
  echo "$(date) - ================================================================================="
  echo "$(date) - Checking retransmission issues"
  for t in "${SCEN[@]}"; do
    echo "$(date) - - Scenario: ${t}"
    if [ "${t}" == "invite_retrans" ] ; then
      continue
    fi
    RETRANS_ISSUE=false
    mapfile -t file_find < <(find "${LOG_DIR}/${t}" -maxdepth 1 -name '*.json' | sort)
    for json_file in "${file_find[@]}" ; do
      file_find=("${file_find[@]:1}")
      if ! [ -a "${json_file}" ] ; then
        continue
      fi
      for next_json_file in "${file_find[@]}" ; do
        if ! [ -a "${next_json_file}" ] ; then
          continue
        fi
        # Check if both sip_in and Sip_out are equals
        if ( diff -q -u <(tail -n3 "${json_file}") <(tail -n3 "${next_json_file}") &> /dev/null ) ; then
          echo "$(date) - - - $(basename "${next_json_file}") seems a retransmission of $(basename "${json_file}") (case 1) ---> renaming the file in $(basename "${next_json_file}")_retransmission"
          mv -f "${next_json_file}" "${next_json_file}_retransmission"
          RETRANS_ISSUE=true
          continue
        fi
        # Check if only sip_in is equal
        if ( diff -q -u <(tail -n3 "${json_file}" | sed -n 1p) <(tail -n3 "${next_json_file}" | sed -n 1p) &> /dev/null ) ; then
          echo "$(date) - - - $(basename "${next_json_file}") seems a retransmission of $(basename "${json_file}") (case 2) ---> renaming the file in $(basename "${next_json_file}")_retransmission"
          mv -f "${next_json_file}" "${next_json_file}_retransmission"
          RETRANS_ISSUE=true
          continue
        fi
      done
    done

    if "${RETRANS_ISSUE}" ; then
      echo "$(date) - - - Reordering kamailio json files"
      mapfile -t file_find < <(find "${LOG_DIR}/${t}" -maxdepth 1 -name '*.json' | sort)
      a=1
      for json_file in "${file_find[@]}" ; do
        new_name=$(printf "%04d.json" "${a}")
        mv -n "${json_file}" "${LOG_DIR}/${t}/${new_name}" &> /dev/null
        ((a++))
      done
    fi
  done

  echo "$(date) - Done"
  echo "$(date) - ================================================================================="
}

cdr_export() {
  echo "$(date) - ================================================================================="
  echo "$(date) - Extracting CDRs"
  for t in "${SCEN[@]}"; do
    echo "$(date) - - Scenario: $t"
    if ! "${BIN_DIR}/cdr_extract.sh" -m -t "${START_TIME}" -s "${GROUP}" "${t}" ; then
      echo "ERROR: ${t}"
      error_flag=1
    fi
  done

  echo "$(date) - Done"
  echo "$(date) - ================================================================================="
}

usage() {
  echo "Usage: run_test.sh [-p PROFILE] [-C] [-t]"
  echo "Options:"
  echo -e "\\t-p CE|PRO default is autodetect"
  echo -e "\\t-l print available SCENARIOS in GROUP"
  echo -e "\\t-C skips configuration of the environment"
  echo -e "\\t-k capture messages with tcpdump, per scenario"
  echo -e "\\t-K capture messages with tcpdump. One big file for all scenarios"
  echo -e "\\t-x set GROUP scenario. Default: scenarios"
  echo -e "\\t-t set timeout in secs for pid_watcher.py [PRO]. Default: 300"
  echo -e "\\t-r fix retransmission issues"
  echo -e "\\t-c export CDRs at the end of the test"
  echo -e "\\t-m mem debug"
  echo -e "\\t-h this help"

  echo "BASE_DIR:${BASE_DIR}"
  echo "BIN_DIR:${BIN_DIR}"
}

while getopts 'hlCcp:kKx:t:rm' opt; do
  case $opt in
    h) usage; exit 0;;
    l) SHOW_SCENARIOS=true;;
    C) SKIP_CONFIG=true;;
    p) PROFILE=${OPTARG};;
    k) SINGLE_CAPTURE=true;;
    K) CAPTURE=true;;
    x) GROUP=${OPTARG};;
    t) TIMEOUT=${OPTARG};;
    r) FIX_RETRANS=true;;
    c) CDR=true;;
    m) MEMDBG=true;;
    *) usage; exit 1;;
  esac
done
shift $((OPTIND - 1))

if [[ $# -ne 0 ]]; then
  echo "Wrong number or arguments"
  usage
  exit 1
fi

if "${SHOW_SCENARIOS}"  ; then
  get_scenarios
  echo "${SCEN[@]}"
  exit 0
fi

if [ -z "${PROFILE}" ]; then
  ngcp_type=$(command -v ngcp-type)
  if [ -n "${ngcp_type}" ]; then
    case $(${ngcp_type}) in
      sppro|carrier) PROFILE=PRO;;
      spce) PROFILE=CE;;
      *) ;;
    esac
    echo "ngcp-type: profile ${PROFILE}"
  fi
fi
if [ "${PROFILE}" != "CE" ] && [ "${PROFILE}" != "PRO" ]; then
  echo "PROFILE ${PROFILE} unknown"
  usage
  exit 2
fi

if [ "${GROUP}" = "scenarios_pbx" ] ; then
  PIDWATCH_OPTS="--pbx"
  # hack for pid_watcher ( sems-pbx was not active )
  mkdir -p /run/sems-pbx/
  touch /run/sems-pbx/sems-pbx.pid
  chown -R sems-pbx:sems-pbx /run/sems-pbx/
else
  PIDWATCH_OPTS=""
fi

LOG_DIR="${BASE_DIR}/log/${GROUP}"

echo "$(date) - Create temporary folder for json files"
rm -rf "${KAM_DIR}"
mkdir -p "${KAM_DIR}"
if [ -d "${KAM_DIR}" ]; then
  chown kamailio:kamailio "${KAM_DIR}"
fi

echo "$(date) - Clean mem log dir"
rm -rf "${MLOG_DIR}"
mkdir -p "${MLOG_DIR}" "${LOG_DIR}"

if ! "${SKIP_CONFIG}" ; then
  echo "$(date) - Setting config debug on"
  "${BIN_DIR}/config_debug.pl" -c 5 -g "${GROUP}" on
  echo "$(date) - Setting network config"
  "${BIN_DIR}/network_config.pl" -g "${GROUP}" on
  if [ "${PROFILE}" == "PRO" ]; then
    echo "$(date) - Exec pid_watcher with timeout[${TIMEOUT}]"
    ( timeout "${TIMEOUT}" "${BIN_DIR}/pid_watcher.py" ${PIDWATCH_OPTS} )&
  fi
  if ! ngcpcfg --summary-only apply "config debug on via kamailio-config-tests" ; then
    echo "$(date) - ngcp apply returned $?"
    echo "$(date) - Done[3]"
    cfg_debug_off
    exit 3
  fi
  if [ "${PROFILE}" == "PRO" ]; then
    echo "$(date) - waiting for pid_watcher[$!] result"
    if ! wait "$!" ; then
      echo "$(date) - error on apply config. Some expected service didn't restart"
      echo "$(date) - check log/pid_watcher.log for details"
      cfg_debug_off
      echo "$(date) - Done[1]"
      exit 1
    fi
  fi
  echo "$(date) - Setting config debug on. Done[${error_flag}]."
fi

echo "$(date) - Initial mem stats"
VERSION="${PROFILE}_$(cut -f1 -d' '< /etc/ngcp_version)_"
"${BIN_DIR}/mem_stats.py" --private_file="${MLOG_DIR}/${VERSION}_${GROUP}_initial_pvm.cvs" \
  --share_file="${MLOG_DIR}/${VERSION}_${GROUP}_initial_shm.cvs"
if "${MEMDBG}" ; then
  ngcp-memdbg-csv /var/log/ngcp/kamailio-proxy.log "${MLOG_DIR}" >/dev/null
fi

get_scenarios

if "${MEMDBG}" ; then
  echo "$(date) - enable memdbg"
  OPTS+=(-m)
fi

if "${CDR}" ; then
  echo "$(date) - enable cdr export at the end of the execution"
fi

echo "$(date) - backup kamailio and sems logs to temp files"
copy_logs_to_tmp
if ! "${BIN_DIR}/restart_log.sh" ; then
  echo "$(date) - error during initial restart of service logs"
  copy_logs_from_tmp
  exit 4
fi

if "${CAPTURE}" ; then
  capture
elif "${SINGLE_CAPTURE}" ; then
  OPTS+=(-K)
fi

for t in "${SCEN[@]}"; do
  echo "$(date) - ================================================================================="
  echo "$(date) - Run [${GROUP}/${PROFILE}]: ${t}"

  log_temp="${LOG_DIR}/${t}"
  if [ -d "${log_temp}" ]; then
    echo "$(date) - Clean log dir"
    rm -rf "${log_temp}"
  fi

  json_temp="${KAM_DIR}/${t}"
  if [ -d "${json_temp}" ]; then
    echo "$(date) - Clean json dir"
    rm -rf "${json_temp}"
  fi

  if ! "${BIN_DIR}/check.sh" "${OPTS[@]}" -p "${PROFILE}" -s "${GROUP}" "${t}" ; then
    echo "ERROR: ${t}"
    error_flag=1
  fi

  echo "$(date) - ================================================================================="

  # Check if core files have been geneared during the test execution
  coredumps=$(find "${COREDUMP_DIR}" -regex '.*kamailio.*\|.*sems.*\|.*asterisk.*' -print)
  if [ -n "${coredumps}" ]; then
    echo "$(date) - ================================================================================="
    echo "$(date) - One or more coredump files have been generated during the test execution."
    echo "$(date) - Check the following files under the folder '${COREDUMP_DIR}':"
    echo "${coredumps}"
    echo "$(date) - ================================================================================="
    error_flag=1
    break
  fi
done

# Hack to allow:
# - tcpdump to capture all the packages
# - kamailio to write all the json files
# - rtpengine to close rtp ports
sleep 6

# Check if there are still some rtp port open after tests execution
rtpengine_ctl_ip=$(grep 'listen-cli' /etc/rtpengine/rtpengine.conf |awk '{print $3}')
rtp_ports=$(rtpengine-ctl -ip "${rtpengine_ctl_ip}" list interfaces |grep "Ports used" | awk '{print $3}')
if [ -n "${rtp_ports}" ]; then
  while read -r i; do
    if [ "${i}" -gt 0 ]; then
      echo "$(date) - ================================================================================="
      echo "$(date) - There are still some rtp ports open, please check the following output"
      rtpengine-ctl -ip "${rtpengine_ctl_ip}" list interfaces
      rtpengine-ctl -ip "${rtpengine_ctl_ip}" list sessions all
      echo "$(date) - copy rtpengine log to ${LOG_DIR}"
      cp -a "${RTP_LOG}" "${LOG_DIR}"
      echo "$(date) - ================================================================================="
      error_flag=1
    fi
  done <<<  "${rtp_ports}"
fi

if "${CAPTURE}" ; then
  stop_capture
fi

echo "$(date) - restore kamailio and sems logs with the original content"
copy_logs_from_tmp
service rsyslog restart

move_json_file

if "${FIX_RETRANS}" ; then
  fix_retransmissions
fi

if "${CDR}" ; then
  sleep 2
  cdr_export
fi

echo "$(date) - Final mem stats"
"${BIN_DIR}/mem_stats.py" --private_file="${MLOG_DIR}/${VERSION}_${GROUP}_final_pvm.cvs" \
  --share_file="${MLOG_DIR}/${VERSION}_${GROUP}_final_shm.cvs"
if [[ ${MEMDBG} = 1 ]] ; then
  ngcp-memdbg-csv /var/log/ngcp/kamailio-proxy.log "${MLOG_DIR}" >/dev/null
fi

if [ -d "${KAM_DIR}" ]; then
  echo "$(date) - clean cfgt scenarios"
  ngcp-kamcmd proxy cfgt.clean all
  echo "$(date) - Removing temporary json dir"
  rm -rf "${KAM_DIR}"
fi

cfg_debug_off

echo "$(date) - Done[${error_flag}]"
exit ${error_flag}
