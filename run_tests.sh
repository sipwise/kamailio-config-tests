#!/bin/bash
BASE_DIR=${BASE_DIR:-"/usr/share/kamailio-config-tests"}
BIN_DIR="${BASE_DIR}/bin"
LOG_DIR="${BASE_DIR}/log"
MLOG_DIR="${BASE_DIR}/mem"
RESULT_DIR="${BASE_DIR}/result"
PROFILE="CE"
DOMAIN="spce.test"
LOGGER=""
error_flag=0

function usage
{
  echo "Usage: run_test.sh [-p PROFILE] [-c] [-t]"
  echo "-p CE|PRO default is CE"
  echo "-c skips configuration of the environment"
  echo "-h this help"

  echo "BASE_DIR:${BASE_DIR}"
  echo "BIN_DIR:${BIN_DIR}"
}

function list
{
  find ${BASE_DIR}/scenarios/ -depth -maxdepth 1 -mindepth 1 -type d -exec basename {} \;| grep -v templates | sort
}

function cfg_debug_off
{
  local res
  if [ -z $SKIP ]; then
    echo "$(date) - Setting config debug off"
    ${BIN_DIR}/config_debug.pl off ${DOMAIN}
    ngcpcfg apply
    res = $?
    if [ "$res" != "0" ]; then
      echo "$(date) - ngcpcfg apply returned $res"
      error_flag=4
    fi
    echo "$(date) - Setting config debug off. Done[$error_flag]"
  fi
}

while getopts 'hlcp:' opt; do
  case $opt in
    h) usage; exit 0;;
    l) list; exit 0;;
    c) SKIP=1;;
    p) PROFILE=$OPTARG;;
  esac
done
shift $(($OPTIND - 1))

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

echo "$(date) - Clean log dir"
rm -rf ${LOG_DIR}
mkdir -p ${MLOG_DIR} ${LOG_DIR}

if [ -z $SKIP ]; then
  echo "$(date) - Setting config debug on"
  ${BIN_DIR}/config_debug.pl on ${DOMAIN}
  if [ "${PROFILE}" == "PRO" ]; then
    ( timeout 60 ${BIN_DIR}/pid_watcher.py &> ${LOG_DIR}/pid_watcher.log )&
  fi
  ngcpcfg apply
  res = $?
  if [ "$res" != "0" ]; then
    echo "$(date) - ngcp apply returned $res"
    echo "$(date) - Done[3]"
    cfg_debug_off
    exit 3
  fi
  if [ "${PROFILE}" == "PRO" ]; then
    wait $!
    if [ "$?" != "0" ]; then
      echo "error on apply config"
      echo "$(date) - Done[1]"
      cfg_debug_off
      exit 1
    fi
  fi
  echo "$(date) - Setting config debug on. Done[$error_flag]."
fi

echo "$(date) - Initial mem stats"
VERSION="${PROFILE}_$(cat /etc/ngcp_version | cut -f1 -d' ')_"
${BIN_DIR}/mem_stats.py --private_file=${MLOG_DIR}/${VERSION}initial_pvm.cvs \
  --share_file=${MLOG_DIR}/${VERSION}initial_shm.cvs

for t in $(find ${BASE_DIR}/scenarios/ -depth -maxdepth 1 -mindepth 1 -type d | grep -v templates | sort); do
  echo "$(date) - Run[${PROFILE}]: $(basename $t) ================================================="
  ${BIN_DIR}/check.sh -P -T -d ${DOMAIN} -p ${PROFILE} $(basename $t)
  if [ $? -ne 0 ]; then
    error_flag=1
  fi
  echo "$(date) - ================================================================================="
done

echo "$(date) - Final mem stats"
${BIN_DIR}/mem_stats.py --private_file=${MLOG_DIR}/${VERSION}final_pvm.cvs \
  --share_file=${MLOG_DIR}/${VERSION}final_shm.cvs

cfg_debug_off

echo "$(date) - Done[$error_flag]"
exit $error_flag
