#!/bin/bash
BASE_DIR=${BASE_DIR:-"/usr/share/kamailio-config-tests"}
BIN_DIR="${BASE_DIR}/bin"
LOG_DIR="${BASE_DIR}/log"
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

while getopts 'hcp:' opt; do
  case $opt in
    h) usage; exit 0;;
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

if [ -z $SKIP ]; then
  echo "$(date) - Setting config debug on"
  ${BIN_DIR}/config_debug.pl on ${DOMAIN}
  if [ "${PROFILE}" == "PRO" ]; then
    ( timeout 60 ${BIN_DIR}/pid_watcher.py )&
  fi
  ngcpcfg apply
  if [ "${PROFILE}" == "PRO" ]; then
    wait $!
    if [ "$?" != "0" ]; then
      echo "error on apply config"
      echo "$(date) - Done[1]"
      exit 1
    fi
  fi
  echo "$(date) - Setting config debug on. Done."
fi

echo "$(date) - Clean log dir"
rm -rf ${LOG_DIR}

for t in $(find ${BASE_DIR}/scenarios/ -depth -maxdepth 1 -mindepth 1 -type d | grep -v templates | sort); do
  echo "$(date) - Run[${PROFILE}]: $(basename $t) ================================================="
  ${BIN_DIR}/check.sh -P -T -d ${DOMAIN} -p ${PROFILE} $(basename $t)
  if [ $? -ne 0 ]; then
    error_flag=1
  fi
  echo "$(date) - ================================================================================="
done

if [ -z $SKIP ]; then
  echo "$(date) - Setting config debug off"
  ${BIN_DIR}/config_debug.pl off ${DOMAIN}
  ngcpcfg apply
  echo "$(date) - Setting config debug off. Done."
fi

echo "$(date) - Done[$error_flag]"
exit $error_flag
