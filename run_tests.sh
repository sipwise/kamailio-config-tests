#!/bin/bash
BASE_DIR=${BASE_DIR:-"/usr/share/kamailio-config-tests"}
BIN_DIR="${BASE_DIR}/bin"
LOG_DIR="${BASE_DIR}/log"
MLOG_DIR="${BASE_DIR}/mem"
PROFILE="CE"
DOMAIN="spce.test"
error_flag=0

function usage
{
  echo "Usage: run_test.sh [-p PROFILE] [-c] [-t]"
  echo "-p CE|PRO default is CE"
  echo "-c skips configuration of the environment"
  echo "-K capture messages with tcpdump"
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
      if [ ! -d "${BASE_DIR}/scenarios/$t" ]; then
        echo "$(date) - scenario: $t not found"
        flag=1
      fi
    done
    if [ $flag != 0 ]; then
      exit 1
    fi
  else
    SCENARIOS=$(find "${BASE_DIR}/scenarios/" -depth -maxdepth 1 -mindepth 1 \
      -type d -exec basename {} \; | grep -v templates | sort)
  fi
}

function cfg_debug_off
{
  if [ -z "$SKIP" ]; then
    echo "$(date) - Setting config debug off"
    "${BIN_DIR}/config_debug.pl" off ${DOMAIN}
    if ! ngcpcfg apply ; then
      echo "$(date) - ngcpcfg apply returned $?"
      error_flag=4
    fi
    echo "$(date) - Setting config debug off. Done[$error_flag]"
  fi
}

while getopts 'hlcp:K' opt; do
  case $opt in
    h) usage; exit 0;;
    l) get_scenarios; echo "${SCENARIOS}"; exit 0;;
    c) SKIP=1;;
    p) PROFILE=$OPTARG;;
    K) SKIP_CAPTURE=1;;
  esac
done
shift $((OPTIND - 1))

if [[ $# -ne 0 ]]; then
  echo "Wrong number or arguments"
  usage
  exit 1
fi

if [ "${PROFILE}" != "CE" ] && [ "${PROFILE}" != "PRO" ]; then
  echo "PROFILE ${PROFILE} unknown"
  usage
  exit 2
fi

echo "$(date) - Clean mem log dir"
rm -rf "${MLOG_DIR}"
mkdir -p "${MLOG_DIR}" "${LOG_DIR}"

if [ -z $SKIP ]; then
  echo "$(date) - Setting config debug on"
  "${BIN_DIR}/config_debug.pl" on ${DOMAIN}
  if [ "${PROFILE}" == "PRO" ]; then
    ( timeout 60 "${BIN_DIR}/pid_watcher.py" )&
  fi
  if ! ngcpcfg apply ; then
    echo "$(date) - ngcp apply returned $?"
    echo "$(date) - Done[3]"
    cfg_debug_off
    exit 3
  fi
  if [ "${PROFILE}" == "PRO" ]; then
    if ! wait "$!" ; then
      echo "error on apply config"
      cfg_debug_off
      echo "$(date) - Done[1]"
      exit 1
    fi
  fi
  echo "$(date) - Setting config debug on. Done[$error_flag]."
fi

echo "$(date) - Initial mem stats"
VERSION="${PROFILE}_$(cut -f1 -d' '< /etc/ngcp_version)_"
"${BIN_DIR}/mem_stats.py" --private_file="${MLOG_DIR}/${VERSION}initial_pvm.cvs" \
  --share_file="${MLOG_DIR}/${VERSION}initial_shm.cvs"

get_scenarios

if [[ ${SKIP_CAPTURE} = 1 ]] ; then
  echo "$(date) enable capture"
  OPTS+="-K"
fi

for t in ${SCENARIOS}; do
  echo "$(date) - Run[${PROFILE}]: $t ================================================="
  log_temp="${LOG_DIR}/${t}"
  if [ -d "${log_temp}" ]; then
    echo "$(date) - Clean log dir"
    rm -rf "${log_temp}"
  fi
  if ! "${BIN_DIR}/check.sh" ${OPTS} -J -P -T -d ${DOMAIN} -p "${PROFILE}" "$t" ; then
    echo "ERROR: $t"
    error_flag=1
  fi
  echo "$(date) - ================================================================================="
done

echo "$(date) - Final mem stats"
"${BIN_DIR}/mem_stats.py" --private_file="${MLOG_DIR}/${VERSION}final_pvm.cvs" \
  --share_file="${MLOG_DIR}/${VERSION}final_shm.cvs"

cfg_debug_off

echo "$(date) - Done[$error_flag]"
exit $error_flag
