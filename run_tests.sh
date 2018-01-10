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
DOMAIN="spce.test"
TIMEOUT=${TIMEOUT:-300}
error_flag=0

function usage
{
  echo "Usage: run_test.sh [-p PROFILE] [-c] [-t]"
  echo "-p CE|PRO default is CE"
  echo "-l print available SCENARIOS in GROUP"
  echo "-c skips configuration of the environment"
  echo "-K capture messages with tcpdump"
  echo "-x set GROUP scenario. Default: scenarios"
  echo "-t set timeout in secs for pid_watcher.py [PRO]. Default: 300"
  echo "-r fix retransmission issues"
  echo "-h this help"

  echo "BASE_DIR:${BASE_DIR}"
  echo "BIN_DIR:${BIN_DIR}"
}

function get_scenarios
{
  local t
  local flag
  flag=0
  if [ -n "${SCENARIOS}" ]; then
    for t in ${SCENARIOS}; do
      if [ ! -d "${BASE_DIR}/${GROUP}/$t" ]; then
        echo "$(date) - scenario: $t at ${GROUP} not found"
        flag=1
      fi
    done
    if [ $flag != 0 ]; then
      exit 1
    fi
  else
    SCENARIOS=$(find "${BASE_DIR}/${GROUP}/" -depth -maxdepth 1 -mindepth 1 \
      -type d -exec basename {} \; | grep -v templates | sort)
  fi
}

function cfg_debug_off
{
  if [ -z "$SKIP" ]; then
    echo "$(date) - Removed apicert.pem"
    rm -f "${BASE_DIR}/apicert.pem"
    echo "$(date) - Setting config debug off"
    "${BIN_DIR}/config_debug.pl" -g "${GROUP}" off ${DOMAIN}
    if ! ngcpcfg apply "config debug off via kamailio-config-tests" ; then
      echo "$(date) - ngcpcfg apply returned $?"
      error_flag=4
    fi
    echo "$(date) - Setting config debug off. Done[$error_flag]"
  fi
}

while getopts 'hlcp:Kx:t:rm' opt; do
  case $opt in
    h) usage; exit 0;;
    l) SHOW_SCENARIOS=1;;
    c) SKIP=1;;
    p) PROFILE=$OPTARG;;
    K) SKIP_CAPTURE=1;;
    x) GROUP=$OPTARG;;
    t) TIMEOUT=$OPTARG;;
    r) SKIP_RETRANS=1;;
    m) MEMDBG=1;;
  esac
done
shift $((OPTIND - 1))

if [[ $# -ne 0 ]]; then
  echo "Wrong number or arguments"
  usage
  exit 1
fi

if [[ ${SHOW_SCENARIOS} = 1 ]] ; then
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

echo "$(date) - Create temporary folder for json files"
rm -rf "${KAM_DIR}"
mkdir -p "${KAM_DIR}"
if [ -d "${KAM_DIR}" ]; then
  chown kamailio "${KAM_DIR}"
fi

echo "$(date) - Clean mem log dir"
rm -rf "${MLOG_DIR}"
mkdir -p "${MLOG_DIR}" "${LOG_DIR}"

if [ -z $SKIP ]; then
  echo "$(date) - Setting config debug on"
  "${BIN_DIR}/config_debug.pl" -g "${GROUP}" on ${DOMAIN}
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
if [[ ${MEMDBG} = 1 ]] ; then
  ngcp-memdbg-csv /var/log/ngcp/kamailio-proxy.log "${MLOG_DIR}" >/dev/null
fi

get_scenarios

if [[ ${SKIP_CAPTURE} = 1 ]] ; then
  echo "$(date) - enable capture"
  OPTS+="-K"
fi

if [[ ${MEMDBG} = 1 ]] ; then
  echo "$(date) - enable memdbg"
  OPTS+="-m"
fi

if [[ ${SKIP_RETRANS} = 1 ]] ; then
  echo "$(date) - enable skip retransmissions"
  OPTS+="-r"
fi

for t in ${SCENARIOS}; do
  echo "$(date) - Run[${GROUP}/${PROFILE}]: $t ================================================="
  log_temp="${LOG_DIR}/${t}"
  if [ -d "${log_temp}" ]; then
    echo "$(date) - Clean log dir"
    rm -rf "${log_temp}"
  fi
  if ! "${BIN_DIR}/check.sh" ${OPTS} -J -P -T -d ${DOMAIN} -p "${PROFILE}" -s "${GROUP}" "$t" ; then
    echo "ERROR: $t"
    error_flag=1
  fi
  echo "$(date) - ================================================================================="
done

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
