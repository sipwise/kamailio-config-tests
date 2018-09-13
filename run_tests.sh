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
OPTS=(-J -P -T)
DOMAIN="spce.test"
TIMEOUT=${TIMEOUT:-300}
SHOW_SCENARIOS=false
SKIP=false
SKIP_CAPTURE=false
SKIP_RETRANS=false
MEMDBG=false
CDR=false
PARALLEL=false
START_TIME=$(date +%s)
error_flag=0

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
  echo -e "\t-L execute scenarios in parallel"
  echo -e "\t-h this help"

  echo "BASE_DIR:${BASE_DIR}"
  echo "BIN_DIR:${BIN_DIR}"
}

get_scenarios() {
  local t
  local flag
  flag=0
  echo "$(date) - Scenarios defined ${SCENARIOS[*]}"
  if [ ${#SCENARIOS[@]} -gt 0 ]; then
    for t in ${SCENARIOS[@]}; do
      if [ ! -d "${BASE_DIR}/${GROUP}/$t" ]; then
        echo "$(date) - scenario: $t at ${GROUP} not found"
        flag=1
      fi
    done
    if [ $flag != 0 ]; then
      exit 1
    fi
  else
    SCENARIOS=($(find "${BASE_DIR}/${GROUP}/" -depth -maxdepth 1 -mindepth 1 \
      -type d -exec basename {} \; | grep -v templates | sort))
  fi
}

cfg_debug_off() {
  if ! "${SKIP}" ; then
    echo "$(date) - Removed apicert.pem"
    rm -f "${BASE_DIR}/apicert.pem"
    echo "$(date) - Setting config debug off"
    "${BIN_DIR}/config_debug.pl" -g "${GROUP}" off "${DOMAIN}"      # TODO: why DOMAIN is necessary here?????
    if ! ngcpcfg apply "config debug off via kamailio-config-tests" ; then
      echo "$(date) - ngcpcfg apply returned $?"
      error_flag=4
    fi
    echo "$(date) - Setting config debug off. Done[$error_flag]"
  fi
}

serial_execution() {
  if "${SKIP_CAPTURE}" ; then
    echo "$(date) - enable capture"
    OPTS+=(-K)
  fi

  for t in ${SCENARIOS[@]}; do
    echo "$(date) - Run [${GROUP}/${PROFILE}]: $t ================================================="
    log_temp="${LOG_DIR}/${t}"
    if [ -d "${log_temp}" ]; then
      echo "$(date) - Clean log dir"
      rm -rf "${log_temp}"
    fi

    DOMAIN="dom.${t}.test"
    
    if ! "${BIN_DIR}/check.sh" "${OPTS[@]}" -d "${DOMAIN}" -p "${PROFILE}" -s "${GROUP}" "$t" ; then
      echo "ERROR: $t"
      error_flag=1
    fi
    echo "$(date) - ================================================================================="
  done
}

parallel_execution() {
  if "${SKIP_CAPTURE}" ; then
    capture
  fi

  echo "$(date) - Restart log files"
  if ! "${BIN_DIR}/restart_log.sh" ; then
    error_helper "Restart error" 16
  fi

  for t in ${SCENARIOS[@]}; do
    echo "$(date) - Configuring [${GROUP}/${PROFILE}]: $t ================================================="
    log_temp="${LOG_DIR}/${t}"
    if [ -d "${log_temp}" ]; then
      echo "$(date) - Clean log dir"
      rm -rf "${log_temp}"
    fi

    DOMAIN="dom.${t}.test"
    
    "${BIN_DIR}/check.sh" -L -R "${OPTS[@]}" -d "${DOMAIN}" -p "${PROFILE}" -s "${GROUP}" "$t" > "/tmp/${t}_execution.log" 2>&1 &

    echo "$(date) - ================================================================================="

    sleep 2
  done

  sleep 20

  start_element=0
  lenght=3
  while [ ${start_element} -lt ${#SCENARIOS[@]} ] ; do
    for t in "${SCENARIOS[@]:$start_element:$lenght}"; do
      echo "$(date) - Run [${GROUP}/${PROFILE}]: $t ================================================="

      DOMAIN="dom.${t}.test"

      "${BIN_DIR}/check.sh" -L -C "${OPTS[@]}" -d "${DOMAIN}" -p "${PROFILE}" -s "${GROUP}" "$t" >> "/tmp/${t}_execution.log" 2>&1 &

      sleep 2

      echo "$(date) - ================================================================================="
    done
    start_element=$((start_element + lenght))

    while true; do
      if ! ps -C sipp &> /dev/null ; then
        continue 2
      fi
    done

  done

  #for t in ${SCENARIOS}; do
  #  echo "$(date) - Run [${GROUP}/${PROFILE}]: $t ================================================="

  #  DOMAIN="dom.${t}.test"
    
  #  "${BIN_DIR}/check.sh" -L -C "${OPTS[@]}" -d "${DOMAIN}" -p "${PROFILE}" -s "${GROUP}" "$t" >> "/tmp/${t}_execution.log" 2>&1 &

  #  echo "$(date) - ================================================================================="

  #  sleep 2
  #done

  while true; do
    if ! ps -C sipp &> /dev/null ; then
      break
    fi
  done

  sleep 20

  for file_name in /tmp/*_execution.log ; do
    if ! [ -f "${file_name}" ] ; then
      # skip if not regular file
      continue
    fi
    dir_name=$(basename "${file_name%_*}")
    dir_name="${LOG_DIR}/${dir_name}/"
    if ! [ -d "${dir_name}" ] ; then
      # skip if folder does not exist
      continue
    fi
    mv "${file_name}" "${dir_name}"
  done

  if "${SKIP_CAPTURE}" ; then
    stop_capture
  fi
}

capture() {
  echo "$(date) - Begin capture"
  for inter in $(ip link | grep '^[0-9]' | cut -d: -f2 | sed 's/ //' | xargs); do
    tcpdump -i "${inter}" -n -s 65535 -w "${LOG_DIR}/traces_${inter}.pcap" &
    capture_pid="$capture_pid ${inter}:$!"
  done
}

stop_capture() {
  local inter=""
  local temp_pid=""
  if [ -n "${capture_pid}" ]; then
    for temp in ${capture_pid}; do
      inter=$(echo "$temp"|cut -d: -f1)
      temp_pid=$(echo "$temp"|cut -d: -f2)
      #echo "inter:${inter} temp_pid:${temp_pid}"
      if ps -p"${temp_pid}" &> /dev/null ; then
        echo "$(date) - End ${inter}[$temp_pid] capture"
        kill -15 "${temp_pid}"
      fi
    done
  fi
}

while getopts 'hlCcp:Kx:t:rmL' opt; do
  case $opt in
    h) usage; exit 0;;
    l) SHOW_SCENARIOS=true;;
    C) SKIP=true;;
    p) PROFILE=$OPTARG;;
    K) SKIP_CAPTURE=true;;
    x) GROUP=$OPTARG;;
    t) TIMEOUT=$OPTARG;;
    r) SKIP_RETRANS=true;;
    c) CDR=true;;
    m) MEMDBG=true;;
    L) PARALLEL=true;;
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

if [ "$GROUP" = "scenarios_pbx" ] ; then
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
  chown kamailio "${KAM_DIR}"
fi

echo "$(date) - Clean mem log dir"
rm -rf "${MLOG_DIR}"
mkdir -p "${MLOG_DIR}" "${LOG_DIR}"

if ! "${SKIP}" ; then
  echo "$(date) - Setting config debug on"
  "${BIN_DIR}/config_debug.pl" -g "${GROUP}" on "${DOMAIN}"      # TODO: why DOMAIN is necessary here?????
  if [ "${PROFILE}" == "PRO" ]; then
    echo "$(date) - Exec pid_watcher with timeout[$TIMEOUT]"
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
  echo "$(date) - Setting config debug on. Done[$error_flag]."
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

if "${SKIP_RETRANS}" ; then
  echo "$(date) - enable skip retransmissions"
  OPTS+=(-r)
fi

if "${CDR}" ; then
  echo "$(date) - enable cdr export at the end of the execution"
fi

if "${PARALLEL}" ; then
  echo "$(date) - parallel execution of scenarios"
  parallel_execution
else
  echo "$(date) - standard execution of scenarios"
  serial_execution
fi

if "${CDR}" ; then
  sleep 2
  for t in ${SCENARIOS[@]}; do
    echo "$(date) - Extract CDRs for [${GROUP}/${PROFILE}]: $t ===================================="
    if ! "${BIN_DIR}/cdr_extract.sh" -t "${START_TIME}" -s "${GROUP}" "$t" ; then
      echo "ERROR: $t"
      error_flag=1
    fi
    echo "$(date) - ================================================================================="
  done
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

echo "$(date) - Done[$error_flag]"
exit $error_flag
