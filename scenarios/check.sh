#!/bin/bash

# $1 kamailio msg parsed to yml
# $2 destination png filename
function graph
{
  if [ -f $1 ]; then
    ${BASE_DIR}/graph_flow.pl $1 $2
  fi
}

# $1 unit test yml
# $2 kamailio msg parsed to yml
# $3 destination tap filename
function check_test
{
  if [ ! -f $1 ]; then
    echo "File $1 does not exists"
    return
  fi
  if [ ! -f $2 ]; then
   echo "File $2 does not exists"
    return
  fi

  echo -n "Testing $1 againts $2 -> $3"
  ${BASE_DIR}/check.py $1 $2 > $3
  if [[ $? -ne "0" ]]; then
    echo " not ok"
  else
    echo " ok"
  fi
}

# $1 domain
function create_voip
{
  ${BASE_DIR}/create_domain.pl $1
  ${BASE_DIR}/create_subscribers.pl -v 1 -s 3 -d $1 -u testuser -c 43  -a 1 -n 1001 -p testuser
}

# $1 prefs yml file
function create_voip_prefs
{
  if [ -f $1 ]; then
    ${BASE_DIR}/set_subscribers_preferences.pl $1
  fi
}

# $1 domain
function delete_voip
{
  ${BASE_DIR}/delete_domain.pl $1
}

# $1 sipp xml scenario file
function run_sipp
{
  # test LOG_DIR
  # we dont want to remove "/*" don't we?
  if [ -z ${LOG_DIR} ]; then
          echo "LOG_DIR empty"
          delete_voip ${DOMAIN}
          exit 1
  fi
  rm -rf ${LOG_DIR}
  mkdir -p ${LOG_DIR}

  ${BASE_DIR}/restart_log.sh
  # let's fire sipp scenario
  ${BASE_DIR}/sipp.sh $1
  status=$?
  # copy the kamailio log
  cp ${KAM_LOG} ${LOG_FILE} ${LOG_DIR}/kamailio.log

  if [[ $status -ne 0 ]]; then
    echo "error in sipp"
    find ${SCEN_CHECK_DIR}/ -type f -name 'sipp_scenario*errors.log' -exec mv {} ${LOG_DIR} \;
    delete_voip ${DOMAIN}
    exit 2
  fi

  echo "Parsing ${LOG_DIR}/kamailio.log"
  ${BASE_DIR}/ulog_parser.pl ${LOG_DIR}/kamailio.log ${LOG_DIR}
}

while getopts 'c' opt; do
  case $opt in
    c) SKIP=1;;
  esac
done
shift $(($OPTIND - 1))

if [[ $# != 1 ]]; then
  echo "usage: $0 check_name"
  exit 1
fi

NAME_CHECK="$1"
BASE_DIR="/usr/local/src/kamailio-config-tests"
LOG_DIR="${BASE_DIR}/log/${NAME_CHECK}"
RESULT_DIR="${BASE_DIR}/result/${NAME_CHECK}"
KAM_LOG="/var/log/ngcp/kamailio-proxy.log"
SCEN_DIR="${BASE_DIR}/scenarios"
SCEN_CHECK_DIR="${SCEN_DIR}/${NAME_CHECK}"
DOMAIN="127.0.0.1"

if [ -z $SKIP ]; then
  delete_voip ${DOMAIN} # just to be sure nothing is there
  create_voip ${DOMAIN}
  create_voip_prefs ${SCEN_CHECK_DIR}/prefs.yml
  run_sipp ${SCEN_CHECK_DIR}/sipp_scenario.xml
  delete_voip ${DOMAIN}
fi

# let's check the results
mkdir -p ${RESULT_DIR}
for t in ${SCEN_CHECK_DIR}/*_test.yml; do
  msg_name=$(echo $t|sed 's/_test\.yml/\.yml/')
  msg=${LOG_DIR}/$(basename $msg_name)
  dest=${RESULT_DIR}/$(basename $t .yml)
  check_test $t $msg ${dest}.tap
  graph $msg ${dest}.png
done

#EOF
