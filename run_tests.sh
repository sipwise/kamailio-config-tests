#!/bin/bash
RUN_DIR="$(dirname "$0")"
export BASE_DIR=${BASE_DIR:-$RUN_DIR}
# Set up the environment, to use local perl modules
export PERL5LIB="${BASE_DIR}/lib"
BIN_DIR="${BASE_DIR}/bin"
GROUP="${GROUP:-scenarios}"
LOG_DIR="${BASE_DIR}/log/${GROUP}"
MLOG_DIR="${BASE_DIR}/mem"
KAM_DIR="/tmp/cfgtest"
PROFILE="CE"
OPTS=(-P -T)
DOMAIN="spce.test"
TIMEOUT=${TIMEOUT:-300}
SHOW_SCENARIOS=false
SKIP_CONFIG=false
CAPTURE=false
FIX_RETRANS=false
MEMDBG=false
CDR=false
START_TIME=$(date +%s)
error_flag=0

get_scenarios() {
  local t
  local flag
  flag=0
  if [ -n "${SCENARIOS}" ]; then
    for t in ${SCENARIOS}; do
      if [ ! -d "${BASE_DIR}/${GROUP}/${t}" ]; then
        echo "$(date) - scenario: $t at ${GROUP} not found"
        flag=1
      fi
    done
    if [ ${flag} != 0 ]; then
      exit 1
    fi
  else
    SCENARIOS=$(find "${BASE_DIR}/${GROUP}/" -depth -maxdepth 1 -mindepth 1 \
      -type d -exec basename {} \; | grep -v templates | sort)
  fi
}

cfg_debug_off() {
  if ! "${SKIP_CONFIG}" ; then
    echo "$(date) - Removed apicert.pem"
    rm -f "${BASE_DIR}/apicert.pem"
    echo "$(date) - Setting config debug off"
    "${BIN_DIR}/config_debug.pl" -g "${GROUP}" off ${DOMAIN}
    if ! ngcpcfg apply "config debug off via kamailio-config-tests" ; then
      echo "$(date) - ngcpcfg apply returned $?"
      error_flag=4
    fi
    echo "$(date) - Setting config debug off. Done[${error_flag}]"
  fi
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
  for t in ${SCENARIOS}; do
    echo "$(date) - - Scenario: ${t}"
    json_dir="${KAM_DIR}/${t}"
    if [ -d "${json_dir}" ] ; then
      for i in "${json_dir}"/*.json ; do
        json_size_before=$(stat -c%s "${i}")
        moved_file="${LOG_DIR}/${t}/$(printf "%04d.json" "$(basename "$i" .json)")"
        expand -t1 "${i}" > "${moved_file}"
        json_size_after=$(stat -c%s "${moved_file}")
        echo "$(date) - - - Moved file ${i} with size before: ${json_size_before} and after: ${json_size_after}"
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
  for t in ${SCENARIOS}; do
    echo "$(date) - - Scenario: ${t}"
    if [ "${t}" == "invite_retrans" ] ; then
      continue
    fi
    RETRANS_ISSUE=false
    file_find=($(find "${LOG_DIR}/${t}" -maxdepth 1 -name '*.json' | sort))
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
      file_find=($(find "${LOG_DIR}/${t}" -maxdepth 1 -name '*.json' | sort))
      a=1
      for json_file in "${file_find[@]}" ; do
        new_name=$(printf "%04d.json" "${a}")
        mv -n "${json_file}" "${LOG_DIR}/${t}/${new_name}" &> /dev/null
        let a=a+1
      done
    fi
  done

  echo "$(date) - Done"
  echo "$(date) - ================================================================================="
}

cdr_export() {
  echo "$(date) - ================================================================================="
  echo "$(date) - Extracting CDRs"
  for t in ${SCENARIOS}; do
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
  echo -e "\t-p CE|PRO default is CE"
  echo -e "\t-l print available SCENARIOS in GROUP"
  echo -e "\t-C skips configuration of the environment"
  echo -e "\t-K capture messages with tcpdump"
  echo -e "\t-x set GROUP scenario. Default: scenarios"
  echo -e "\t-t set timeout in secs for pid_watcher.py [PRO]. Default: 300"
  echo -e "\t-r fix retransmission issues"
  echo -e "\t-c export CDRs at the end of the test"
  echo -e "\t-m mem debug"
  echo -e "\t-h this help"

  echo "BASE_DIR:${BASE_DIR}"
  echo "BIN_DIR:${BIN_DIR}"
}

while getopts 'hlCcp:Kx:t:rm' opt; do
  case $opt in
    h) usage; exit 0;;
    l) SHOW_SCENARIOS=true;;
    C) SKIP_CONFIG=true;;
    p) PROFILE=${OPTARG};;
    K) CAPTURE=true;;
    x) GROUP=${OPTARG};;
    t) TIMEOUT=${OPTARG};;
    r) FIX_RETRANS=true;;
    c) CDR=true;;
    m) MEMDBG=true;;
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
  echo "${SCENARIOS}"
  exit 0
fi

if [ "${PROFILE}" != "CE" ] && [ "${PROFILE}" != "PRO" ]; then
  echo "PROFILE ${PROFILE} unknown"
  usage
  exit 2
fi

if [ "${GROUP}" = "scenarios_pbx" ] ; then
  PIDWATCH_OPTS="--pbx"
  # hack for pid_watcher ( sems-pbx was not active )
  mkdir -p /var/run/sems-pbx/
  touch /var/run/sems-pbx/sems-pbx.pid
  chown -R sems-pbx:sems-pbx /var/run/sems-pbx/
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
  "${BIN_DIR}/config_debug.pl" -g "${GROUP}" on ${DOMAIN}
  if [ "${PROFILE}" == "PRO" ]; then
    echo "$(date) - Exec pid_watcher with timeout[${TIMEOUT}]"
    ( timeout "${TIMEOUT}" "${BIN_DIR}/pid_watcher.py" ${PIDWATCH_OPTS} )&
  fi
  if ! ngcpcfg apply "config debug on via kamailio-config-tests" ; then
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

if "${CAPTURE}" ; then
  capture
fi

for t in ${SCENARIOS}; do
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

  if ! "${BIN_DIR}/check.sh" "${OPTS[@]}" -d "${DOMAIN}" -p "${PROFILE}" -s "${GROUP}" "${t}" ; then
    echo "ERROR: ${t}"
    error_flag=1
  fi

  echo "$(date) - ================================================================================="
done

# Hack to allow tcpdump to capture all the packages and kamailio to write all the json files
sleep 5

if "${CAPTURE}" ; then
  stop_capture
fi

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
  echo "$(date) - Removing temporary json dir"
  rm -rf "${KAM_DIR}"
fi

cfg_debug_off

echo "$(date) - Done[${error_flag}]"
exit ${error_flag}
