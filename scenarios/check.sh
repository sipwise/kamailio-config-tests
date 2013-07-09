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
    ERR_FLAG=1
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

# $1 msg to echo
# $2 exit value
function error_sipp
{
  echo $1
  if [ -z ${SKIP} ] || [ -z ${SKIP_DELDOMAIN} ]; then
    echo "Deleting domain:${DOMAIN}"
    delete_voip ${DOMAIN}
  fi
  find ${SCEN_CHECK_DIR}/ -type f -name 'sipp_scenario*errors.log' -exec mv {} ${LOG_DIR} \;
  exit $2
}

# $1 sipp xml scenario file
function run_sipp
{
  # test LOG_DIR
  # we dont want to remove "/*" don't we?
  if [ -z ${LOG_DIR} ]; then
    error_sipp "LOG_DIR empty" 1
  fi
  rm -rf ${LOG_DIR}
  mkdir -p ${LOG_DIR}

  ${BASE_DIR}/restart_log.sh
  if [ -f ${SCEN_CHECK_DIR}/sipp_scenario_responder.xml ]; then
    ${BASE_DIR}/sipp.sh -d ${DOMAIN} -r ${SCEN_CHECK_DIR}/sipp_scenario_responder_reg.xml &> /dev/null
    ${BASE_DIR}/sipp.sh -d ${DOMAIN} -r ${SCEN_CHECK_DIR}/sipp_scenario_responder.xml &> /dev/null &
    responder_pid=$!
  fi
  # let's fire sipp scenario
  ${BASE_DIR}/sipp.sh -d ${DOMAIN} $1
  status=$?

  if [ -f ${SCEN_CHECK_DIR}/sipp_scenario_responder.xml ]; then
    ps -p${responder_pid} &> /dev/null
    ps_status=$?
    if [ ${ps_status} -eq 0 ]; then
      echo "sipp responder not finished yet. Waiting 5 secs"
      sleep 5
    fi
    ${BASE_DIR}/sipp.sh -d ${DOMAIN} -r ${SCEN_CHECK_DIR}/sipp_scenario_responder_unreg.xml &> /dev/null
  fi

  # copy the kamailio log
  cp ${KAM_LOG} ${LOG_FILE} ${LOG_DIR}/kamailio.log
  find ${SCEN_CHECK_DIR}/ -type f -name 'sipp_scenario*errors.log' -exec mv {} ${LOG_DIR} \;
  if [[ $status -ne 0 ]]; then
    error_sipp "error in sipp" 2
  fi

  echo "Parsing ${LOG_DIR}/kamailio.log"
  ${BASE_DIR}/ulog_parser.pl ${LOG_DIR}/kamailio.log ${LOG_DIR}
}

while getopts 'CRDTGd:' opt; do
  case $opt in
    C) SKIP=1;;
    d) DOMAIN=$OPTARG;;
    R) SKIP_RUNSIPP=1;;
    D) SKIP_DELDOMAIN=1;;
    T) SKIP_TESTS=1;;
    G) SKIP_GRAPH=1;;
  esac
done
shift $(($OPTIND - 1))

if [[ $# != 1 ]]; then
  echo "Usage: $0 [-sDr] [-d DOMAIN] check_name"
  echo "Options:"
  echo "-C: skip creation of domain and subscribers"
  echo "-R: skip run sipp"
  echo "-D: skip deletion of domain and subscribers as final step"
  echo "-T: skip checks"
  echo "-G: skip creation of graphviz image"
  echo "-d: DOMAIN"
  exit 1
fi

NAME_CHECK="$1"
BASE_DIR="/usr/local/src/kamailio-config-tests"
LOG_DIR="${BASE_DIR}/log/${NAME_CHECK}"
RESULT_DIR="${BASE_DIR}/result/${NAME_CHECK}"
KAM_LOG="/var/log/ngcp/kamailio-proxy.log"
SCEN_DIR="${BASE_DIR}/scenarios"
SCEN_CHECK_DIR="${SCEN_DIR}/${NAME_CHECK}"
DOMAIN=${DOMAIN:-"spce.test"}

if [ -z $SKIP ]; then
  delete_voip ${DOMAIN} # just to be sure nothing is there
  create_voip ${DOMAIN}
  create_voip_prefs ${SCEN_CHECK_DIR}/prefs.yml

  if [ -z $SKIP_RUNSIPP ]; then
    run_sipp ${SCEN_CHECK_DIR}/sipp_scenario.xml
  fi

  if [ -z ${SKIP_DELDOMAIN} ]; then
    echo "Deleting domain:${DOMAIN}"
    delete_voip ${DOMAIN}
  fi
fi

# let's check the results
ERR_FLAG=0
if [ -z ${SKIP_TESTS} ]; then
  mkdir -p ${RESULT_DIR}
  for t in ${SCEN_CHECK_DIR}/*_test.yml; do
    msg_name=$(echo $t|sed 's/_test\.yml/\.yml/')
    msg=${LOG_DIR}/$(basename $msg_name)
    dest=${RESULT_DIR}/$(basename $t .yml)
    check_test $t $msg ${dest}.tap
    if [ -z ${SKIP_GRAPH} ]; then
      echo "Generating flow image: ${dest}.png"
      graph $msg ${dest}.png
    fi
  done
fi
exit ${ERR_FLAG}
#EOF
