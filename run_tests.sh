#!/bin/bash
BASE_DIR="/usr/local/src/kamailio-config-tests"
LOG_DIR="${BASE_DIR}/log"
RESULT_DIR="${BASE_DIR}/result"
PROFILE="CE"
DOMAIN="spce.test"
error_flag=0

function usage
{
  echo "Usage: run_test.sh [-p PROFILE] [-c] [-t]"
  echo "-p CE|PRO default is CE"
  echo "-c skips configuration of the environment"
  echo "-t skips tests"
}

while getopts 'ctp:' opt; do
  case $opt in
    c) SKIP=1;;
    t) TEST=1;;
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
  ${BASE_DIR}/config_debug.pl on ${DOMAIN}
  ngcpcfg apply
fi

for i in ${LOG_DIR} ${RESULT_DIR}; do
  rm -rf $i
done

${BASE_DIR}/generate_tests.sh ${PROFILE}
if [ $? -ne 0 ]; then
  echo "Generating tests error"
  exit 3
fi

for t in $(find ${BASE_DIR}/scenarios/ -depth -maxdepth 1 -mindepth 1 -type d | sort); do
  echo "Run: $(basename $t)"
  if [ -z $TEST ]; then
    ${BASE_DIR}/scenarios/check.sh -d ${DOMAIN} $(basename $t)
    if [ $? -ne 0 ]; then
    	error_flag=1
    fi
  fi
done

if [ -z $SKIP ]; then
  ${BASE_DIR}/config_debug.pl off ${DOMAIN}
  ngcpcfg apply
fi

exit $error_flag
