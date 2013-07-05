#!/bin/bash
BASE_DIR="/usr/local/src/kamailio-config-tests"
LOG_DIR="${BASE_DIR}/log"
RESULT_DIR="${BASE_DIR}/result"
DOMAIN="scpe.test"
error_flag=0

while getopts 'ct' opt; do
  case $opt in
    c) SKIP=1;;
    t) TEST=1;;
  esac
done

if [ -z $SKIP ]; then
  ${BASE_DIR}/config_debug.pl on ${DOMAIN}
  ngcpcfg apply
fi

for i in ${LOG_DIR} ${RESULT_DIR}; do
  rm -rf $i
done

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
