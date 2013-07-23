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

  echo -n "$(date) - Testing $(basename $1) againts $(basename $2) -> $(basename $3)"
  ${BIN_DIR}/check.py $1 $2 > $3
  if [[ $? -ne "0" ]]; then
    echo " NOT ok"
    ERR_FLAG=1
  else
    echo " ok"
  fi
}

# $1 domain
function create_voip
{
  /usr/bin/ngcp-create_domain $1
  if [[ $? -ne 0 ]]; then
    echo "$(date) - Cannot create domain"
    exit 1
  fi
  ${BIN_DIR}/create_subscribers.pl -v 1 -s 5 -d $1 -u testuser -c 43  -a 1 -n 1001 -p testuser
  if [[ $? -ne 0 ]]; then
    echo "$(date) - Deleting domain:${DOMAIN}"
    delete_voip $1
    echo "$(date) - Cannot create domain subscribers"
    exit 1
  fi
}

# $1 prefs yml file
function create_voip_prefs
{
  if [ -f ${SCEN_CHECK_DIR}/callforward.yml ]; then
   echo "$(date) - Setting callforward config"
   ${BIN_DIR}/set_subscribers_callforward.pl ${SCEN_CHECK_DIR}/callforward.yml
  fi

  if [ -f ${SCEN_CHECK_DIR}/speeddial.yml ]; then
   echo "$(date) - Setting speeddial config"
   ${BIN_DIR}/set_subscribers_speeddial.pl ${SCEN_CHECK_DIR}/speeddial.yml
  fi

  if [ -f ${SCEN_CHECK_DIR}/prefs.yml ]; then
    echo "$(date) - Setting subcribers preferences"
    ${BIN_DIR}/set_subscribers_preferences.pl ${SCEN_CHECK_DIR}/prefs.yml
  fi
}

# $1 domain
function delete_voip
{
  /usr/bin/ngcp-delete_domain $1
}

function delete_locations
{
  for sub in $(cat ${SCEN_DIR}/callee.csv | grep test | cut -d\; -f1 | xargs); do
    ngcp-kamctl proxy ul rm $sub@${DOMAIN}
  done
}

# $1 msg to echo
# $2 exit value
function error_sipp
{
  echo $1
  if [ -z ${SKIP} ] || [ -z ${SKIP_DELDOMAIN} ]; then
    echo "$(date) - Deleting domain:${DOMAIN}"
    delete_voip ${DOMAIN}
  fi
  find ${SCEN_CHECK_DIR}/ -type f -name 'sipp_scenario*errors.log' -exec mv {} ${LOG_DIR} \;
  exit $2
}

# $1 port to check
function check_port
{
  status=0
  port=$1
  step=${2:-1}
  until [ $status -eq 1 ]; do
    let port=${port}+${step}
    $(netstat -n | grep ":$port ")
    status=$?
  done
}

# $1 sipp xml scenario file
function run_sipp
{
  check_port 50603
  PORT=$port
  check_port 6003 3
  MPORT=$port
  # test LOG_DIR
  # we dont want to remove "/*" don't we?
  if [ -z ${LOG_DIR} ]; then
    error_sipp "LOG_DIR empty" 1
  fi
  rm -rf ${LOG_DIR}
  mkdir -p ${LOG_DIR}

  delete_locations

  ${BIN_DIR}/restart_log.sh
  for res in $(find ${SCEN_CHECK_DIR} -type f -name 'sipp_scenario_responder[0-9][0-9].xml'| sort); do
    base=$(basename $res .xml)
    echo "$(date) - Running ${base} ${PORT}-${MPORT}"
    ${BIN_DIR}/sipp.sh -p ${PORT} -r ${SCEN_CHECK_DIR}/${base}_reg.xml
    ${BIN_DIR}/sipp.sh -p ${PORT} -m ${MPORT} -r ${SCEN_CHECK_DIR}/${base}.xml &
    responder_pid="${responder_pid} ${base}:$!:${PORT}:${MPORT}"
    check_port ${PORT}
    PORT=$port
    check_port ${MPORT} 3
    MPORT=$port
  done
  status=0
  # let's fire sipp scenarios
  for send in $(find ${SCEN_CHECK_DIR} -type f -name 'sipp_scenario[0-9][0-9].xml'| sort); do
    base=$(basename $send .xml)
    echo "$(date) - Running ${base} 50602-7002"
    ${BIN_DIR}/sipp.sh -p 50602 -m 7002 $send
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
      echo "$(date) - sipp responder $base pid $pid not finished yet. Waiting 5 secs"
      sleep 5
      ps -p${pid} &> /dev/null
      ps_status=$?
      if [ ${ps_status} -eq 0 ]; then
        echo "$(date) - sipp responder $base pid $pid not finished yet. Killing it"
        kill -9 ${pid}
      fi
    fi
    ${BIN_DIR}/sipp.sh -p ${PORT} -r ${SCEN_CHECK_DIR}/${base}_unreg.xml
  done

  # wait a moment. We want all the info
  sleep 1
  # copy the kamailio log
  cp ${KAM_LOG} ${LOG_FILE} ${LOG_DIR}/kamailio.log
  find ${SCEN_CHECK_DIR}/ -type f -name 'sipp_scenario*errors.log' -exec mv {} ${LOG_DIR} \;
  if [[ $status -ne 0 ]]; then
    error_sipp "error in sipp" 2
  fi
}

function usage
{
  echo "Usage: check.sh [-hCDRTG] [-d DOMAIN ] [-p PROFILE ] check_name"
  echo "Options:"
  echo -e "\t-C: skip creation of domain and subscribers"
  echo -e "\t-R: skip run sipp"
  echo -e "\t-D: skip deletion of domain and subscribers as final step"
  echo -e "\t-T: skip checks"
  echo -e "\t-P: skip parse. -T is froced"
  echo -e "\t-G: creation of graphviz image"
  echo -e "\t-d: DOMAIN"
  echo -e "\t-p CE|PRO default is CE"
  echo "Arguments:"
  echo -e "\tcheck_name. Scenario name to check. This is the name of the directory on scenarios dir."
}

while getopts 'hCd:p:RDTPG' opt; do
  case $opt in
    h) usage; exit 0;;
    C) SKIP=1;;
    d) DOMAIN=$OPTARG;;
    p) PROFILE=$OPTARG;;
    R) SKIP_RUNSIPP=1;;
    D) SKIP_DELDOMAIN=1;;
    T) SKIP_TESTS=1;;
    P) SKIP_PARSE=1; SKIP_TESTS=1;;
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
  echo "$(date) - Deleting all info for ${DOMAIN} domain"
  delete_voip ${DOMAIN} # just to be sure nothing is there
  echo "$(date) - Creating ${DOMAIN}"
  create_voip ${DOMAIN}
  echo "$(date) - Adding prefs"
  create_voip_prefs

  if [ -z $SKIP_RUNSIPP ]; then
    echo "$(date) - Running sipp scenarios"
    run_sipp
    echo "$(date) - Done sipp"
  fi

  if [ -z ${SKIP_DELDOMAIN} ]; then
    echo "$(date) - Deleting domain:${DOMAIN}"
    delete_voip ${DOMAIN}
    echo "$(date) - Done"
  fi
fi

if [ -z ${SKIP_PARSE} ]; then
  echo "$(date) - Parsing ${LOG_DIR}/kamailio.log"
  ${BIN_DIR}/ulog_parser.pl ${LOG_DIR}/kamailio.log ${LOG_DIR}
  echo "$(date) - Done"
fi

# let's check the results
ERR_FLAG=0
if [ -z ${SKIP_TESTS} ]; then
  mkdir -p ${RESULT_DIR}
  echo "$(date) - Generating tests files"
  ${BIN_DIR}/generate_tests.sh -d ${SCEN_CHECK_DIR} ${PROFILE}
  echo "$(date) - Done"
  for t in ${SCEN_CHECK_DIR}/*_test.yml; do
    echo "$(date) - check test $t"
    msg_name=$(echo $t|sed 's/_test\.yml/\.yml/')
    msg=${LOG_DIR}/$(basename $msg_name)
    dest=${RESULT_DIR}/$(basename $t .yml)
    check_test $t $msg ${dest}.tap
    echo "$(date) - Done"
    if [ ! -z ${GRAPH} ]; then
      echo "$(date) - Generating flow image: ${dest}.png"
      graph $msg ${dest}.png
      echo "$(date) - Done"
    fi
  done
fi
exit ${ERR_FLAG}
#EOF
