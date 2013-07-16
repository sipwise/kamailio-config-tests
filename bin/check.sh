#!/bin/bash

# $1 kamailio msg parsed to yml
# $2 destination png filename
function graph
{
  if [ -f $1 ]; then
    ${BIN_DIR}/graph_flow.pl $1 $2
  else
    ERR_FLAG=1
  fi
}

# $1 unit test yml
# $2 kamailio msg parsed to yml
# $3 destination tap filename
function check_test
{
  if [ ! -f $1 ]; then
    echo "File $1 does not exists"
    ERR_FLAG=1
    return
  fi
  if [ ! -f $2 ]; then
    echo "File $2 does not exists"
    ERR_FLAG=1
    return
  fi

  echo -n "Testing $1 againts $2 -> $3"
  ${BIN_DIR}/check.py $1 $2 > $3
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
  ${BIN_DIR}/create_domain.pl $1
  ${BIN_DIR}/create_subscribers.pl -v 1 -s 3 -d $1 -u testuser -c 43  -a 1 -n 1001 -p testuser
}

# $1 prefs yml file
function create_voip_prefs
{
  if [ -f ${SCEN_CHECK_DIR}/callforward.yml ]; then
   echo "Setting callforward config"
   ${BIN_DIR}/set_subscribers_callforward.pl ${SCEN_CHECK_DIR}/callforward.yml
  fi

  if [ -f ${SCEN_CHECK_DIR}/speeddial.yml ]; then
   echo "Setting speeddial config"
   ${BIN_DIR}/set_subscribers_speeddial.pl ${SCEN_CHECK_DIR}/speeddial.yml
  fi

  if [ -f ${SCEN_CHECK_DIR}/prefs.yml ]; then
    echo "Setting subcribers preferences"
    ${BIN_DIR}/set_subscribers_preferences.pl ${SCEN_CHECK_DIR}/prefs.yml
  fi
}

# $1 domain
function delete_voip
{
  ${BIN_DIR}/delete_domain.pl $1
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
  PORT=50603
  MPORT=6003
  # test LOG_DIR
  # we dont want to remove "/*" don't we?
  if [ -z ${LOG_DIR} ]; then
    error_sipp "LOG_DIR empty" 1
  fi
  rm -rf ${LOG_DIR}
  mkdir -p ${LOG_DIR}

  ${BIN_DIR}/restart_log.sh
  for res in $(find ${SCEN_CHECK_DIR} -type f -name 'sipp_scenario_responder[0-9][0-9].xml'| sort); do
    base=$(basename $res .xml)
    echo "Running ${base} ${PORT}-${MPORT}"
    ${BIN_DIR}/sipp.sh -d ${DOMAIN} -p ${PORT} -r ${SCEN_CHECK_DIR}/${base}_reg.xml
    ${BIN_DIR}/sipp.sh -d ${DOMAIN} -p ${PORT} -m ${MPORT} -r ${SCEN_CHECK_DIR}/${base}.xml &
    responder_pid="${responder_pid} ${base}:$!:${PORT}:${MPORT}"
    let PORT=${PORT}+1
    let MPORT=${MPORT}+3
  done
  status=0
  # let's fire sipp scenarios
  for send in $(find ${SCEN_CHECK_DIR} -type f -name 'sipp_scenario[0-9][0-9].xml'| sort); do
    base=$(basename $send .xml)
    echo "Running ${base} 50602-7002"
    ${BIN_DIR}/sipp.sh -d ${DOMAIN} -p 50602 -m 7002 $send
    if [[ $? -ne 0 ]]; then
      status=1
    fi
  done

  for res in ${responder_pid}; do
    base=$(echo $res| cut -d: -f1)
    pid=$(echo $res| cut -d: -f2)
    port=$(echo $res| cut -d: -f3)
    ps -p${pid} &> /dev/null
    ps_status=$?
    if [ ${ps_status} -eq 0 ]; then
      echo "sipp responder $base pid $pid not finished yet. Waiting 5 secs"
      sleep 5
      ps -p${pid} &> /dev/null
      ps_status=$?
      if [ ${ps_status} -eq 0 ]; then
        echo "sipp responder $base pid $pid not finished yet. Killing it"
        kill -9 ${pid}
      fi
    fi
    ${BIN_DIR}/sipp.sh -d ${DOMAIN} -p ${PORT} -r ${SCEN_CHECK_DIR}/${base}_unreg.xml
  done

  # wait a moment. We want all the info
  sleep 1
  # copy the kamailio log
  cp ${KAM_LOG} ${LOG_FILE} ${LOG_DIR}/kamailio.log
  find ${SCEN_CHECK_DIR}/ -type f -name 'sipp_scenario*errors.log' -exec mv {} ${LOG_DIR} \;
  if [[ $status -ne 0 ]]; then
    error_sipp "error in sipp" 2
  fi

  echo "Parsing ${LOG_DIR}/kamailio.log"
  ${BIN_DIR}/ulog_parser.pl ${LOG_DIR}/kamailio.log ${LOG_DIR}
}

function usage
{
  echo "Usage: check.sh [-hCDRTG] [-d DOMAIN ] [-p PROFILE ] check_name"
  echo "Options:"
  echo -e "\t-C: skip creation of domain and subscribers"
  echo -e "\t-R: skip run sipp"
  echo -e "\t-D: skip deletion of domain and subscribers as final step"
  echo -e "\t-T: skip checks"
  echo -e "\t-G: creation of graphviz image"
  echo -e "\t-d: DOMAIN"
  echo -e "\t-p CE|PRO default is CE"
  echo "Arguments:"
  echo -e "\tcheck_name. Scenario name to check. This is the name of the directory on scenarios dir."
}

while getopts 'hCRDTGd:p:' opt; do
  case $opt in
    h) usage; exit 0;;
    C) SKIP=1;;
    d) DOMAIN=$OPTARG;;
    p) PROFILE=$OPTARG;;
    R) SKIP_RUNSIPP=1;;
    D) SKIP_DELDOMAIN=1;;
    T) SKIP_TESTS=1;;
    G) GRAPH=1;;
  esac
done
shift $(($OPTIND - 1))

if [[ $# != 1 ]]; then
  echo "Wrong number of arguments"
  usage
  exit 1
fi

NAME_CHECK="$1"
BASE_DIR="${BASE_DIR:-/usr/local/src/kamailio-config-tests}"
BIN_DIR="${BASE_DIR}/bin"
LOG_DIR="${BASE_DIR}/log/${NAME_CHECK}"
RESULT_DIR="${BASE_DIR}/result/${NAME_CHECK}"
KAM_LOG="${KAM_LOG:-/var/log/ngcp/kamailio-proxy.log}"
SCEN_DIR="${BASE_DIR}/scenarios"
SCEN_CHECK_DIR="${SCEN_DIR}/${NAME_CHECK}"
DOMAIN=${DOMAIN:-"spce.test"}
PROFILE="${PROFILE:-CE}"

if [ "${PROFILE}" != "CE" ] && [ "${PROFILE}" != "PRO" ]; then
  echo "PROFILE ${PROFILE} unknown"
  usage
  exit 2
fi

if [ ! -d ${SCEN_CHECK_DIR} ]; then
  echo "no ${SCEN_CHECK_DIR} found"
  usage
  exit 3
fi

if [ -z $SKIP ]; then
  delete_voip ${DOMAIN} # just to be sure nothing is there
  create_voip ${DOMAIN}
  create_voip_prefs

  if [ -z $SKIP_RUNSIPP ]; then
    run_sipp
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
  ${BIN_DIR}/generate_tests.sh -d ${SCEN_CHECK_DIR} ${PROFILE}
  for t in ${SCEN_CHECK_DIR}/*_test.yml; do
    msg_name=$(echo $t|sed 's/_test\.yml/\.yml/')
    msg=${LOG_DIR}/$(basename $msg_name)
    dest=${RESULT_DIR}/$(basename $t .yml)
    check_test $t $msg ${dest}.tap
    if [ ! -z ${GRAPH} ]; then
      echo "Generating flow image: ${dest}.png"
      graph $msg ${dest}.png
    fi
  done
fi
exit ${ERR_FLAG}
#EOF
