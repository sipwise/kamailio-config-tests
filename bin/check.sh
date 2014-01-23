#!/bin/bash
#
# Copyright: 2013 Sipwise Development Team <support@sipwise.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This package is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# On Debian systems, the complete text of the GNU General
# Public License version 3 can be found in "/usr/share/common-licenses/GPL-3".
#

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
  local dest=${RESULT_DIR}/$(basename $3 .tap)
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
    if [ -z ${GRAPH} ] && [ ! -z ${GRAPH_FAIL} ]; then
      echo "$(date) - Generating flow image: ${dest}.png"
      graph $msg ${dest}.png
      echo "$(date) - Done"
    fi
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
  ${BIN_DIR}/create_subscribers.pl ${SCEN_CHECK_DIR}/scenario.yml
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
  if [ -f ${SCEN_CHECK_DIR}/rewrite.yml ]; then
    echo "$(date) - Creating rewrite rules"
    ${BIN_DIR}/create_rewrite_rules.pl ${SCEN_CHECK_DIR}/rewrite.yml
  fi

  if [ -f ${SCEN_CHECK_DIR}/callforward.yml ]; then
   echo "$(date) - Setting callforward config"
   ${BIN_DIR}/set_subscribers_callforward.pl ${SCEN_CHECK_DIR}/callforward.yml
  fi

  if [ -f ${SCEN_CHECK_DIR}/speeddial.yml ]; then
   echo "$(date) - Setting speeddial config"
   ${BIN_DIR}/set_subscribers_speeddial.pl ${SCEN_CHECK_DIR}/speeddial.yml
  fi

  if [ -f ${SCEN_CHECK_DIR}/ncos.yml ]; then
    echo "$(date) - Creating ncos levels"
    ${BIN_DIR}/create_ncos.pl ${SCEN_CHECK_DIR}/ncos.yml
  fi

  if [ -f ${SCEN_CHECK_DIR}/peer.yml ]; then
    echo "$(date) - Creating peers"
    ${BIN_DIR}/create_peers.pl ${SCEN_CHECK_DIR}/peer.yml
  fi

  if [ -f ${SCEN_CHECK_DIR}/prefs.yml ]; then
    echo "$(date) - Setting preferences"
    ${BIN_DIR}/set_preferences.pl ${SCEN_CHECK_DIR}/prefs.yml
  fi
}

# $1 domain
function delete_voip
{
  /usr/bin/ngcp-delete_domain $1

  if [ -f ${SCEN_CHECK_DIR}/peer.yml ]; then
    echo "$(date) - Deleting peers"
    ${BIN_DIR}/create_peers.pl -d ${SCEN_CHECK_DIR}/peer.yml
  fi

  if [ -f ${SCEN_CHECK_DIR}/ncos.yml ]; then
    echo "$(date) - Deleting ncos levels"
    ${BIN_DIR}/create_ncos.pl -d ${SCEN_CHECK_DIR}/ncos.yml
  fi

  if [ -f ${SCEN_CHECK_DIR}/rewrite.yml ]; then
    echo "$(date) - Deleting rewrite rules"
    ${BIN_DIR}/create_rewrite_rules.pl -d ${SCEN_CHECK_DIR}/rewrite.yml
  fi
}

function delete_locations
{
  for sub in $(cat ${SCEN_CHECK_DIR}/callee.csv | grep test | cut -d\; -f1 | xargs); do
    ngcp-kamctl proxy ul rm $sub@${DOMAIN}
  done
}

# $1 msg to echo
# $2 exit value
function error_helper
{
  echo $1
  if [ -z ${SKIP_DELDOMAIN} ]; then
    echo "$(date) - Deleting domain:${DOMAIN}"
    delete_voip ${DOMAIN}
  fi
  find ${SCEN_CHECK_DIR}/ -type f -name 'sipp_scenario*errors.log' -exec mv {} ${LOG_DIR} \;
  stop_capture
  exit $2
}

function capture
{
  local name=$(basename ${SCEN_CHECK_DIR})
  echo "$(date) - Begin capture"
  for inter in $(ip link | grep '^[0-9]' | cut -d: -f2 | sed 's/ //' | xargs); do
    tcpdump -i ${inter} -n -s 65535 -w ${LOG_DIR}/${name}_${inter}.pcap &
    capture_pid="$capture_pid ${inter}:$!"
  done
}

function stop_capture
{
  local inter=""
  local temp_pid=""
  if [ ! -z "${capture_pid}" ]; then
    for temp in ${capture_pid}; do
      inter=$(echo $temp|cut -d: -f1)
      temp_pid=$(echo $temp|cut -d: -f2)
      #echo "inter:${inter} temp_pid:${temp_pid}"
      if $(ps -p${temp_pid} &> /dev/null); then
        echo "$(date) - End ${inter}[$temp_pid] capture"
        kill -15 ${temp_pid}
      fi
    done
  fi
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

#$1 is filename
function get_ip
{
  transport=$(grep "$1" ${SCEN_CHECK_DIR}/scenario.csv|cut -d\; -f2| tr -d '\n')
  ip=$(grep "$1" ${SCEN_CHECK_DIR}/scenario.csv|cut -d\; -f3| tr -d '\n')
  if [[ $? -ne 0 ]]; then
    error_helper "cannot find $1 ip on ${SCEN_CHECK_DIR}/scenario.csv" 10
  fi
  peer_host=$(grep "$1" ${SCEN_CHECK_DIR}/scenario.csv|cut -d\; -f4| tr -d '\n')
}

#$1 is filename
function is_enabled
{
  grep "$1" ${SCEN_CHECK_DIR}/scenario.csv &>/dev/null
  if [[ $? -ne 0 ]]; then
    echo "$(date) $1 deactivated"
    continue
  fi
}

function copy_logs
{
  # copy the kamailio log
  cp ${KAM_LOG} ${LOG_DIR}/kamailio.log
  # copy the sems log
  cp ${SEMS_LOG} ${LOG_DIR}/sems.log
  # copy the kamailio-lb log
  cp ${KAMLB_LOG} ${LOG_DIR}/kamailio-lb.log
}

# $1 sipp xml scenario file
function run_sipp
{
  check_port 50603
  local PORT=$port
  check_port 6003 3
  local MPORT=$port

  local base=""
  local pid=""

  # test LOG_DIR
  # we dont want to remove "/*" don't we?
  if [ -z ${LOG_DIR} ]; then
    error_helper "LOG_DIR empty" 1
  fi
  rm -rf ${LOG_DIR}
  mkdir -p ${LOG_DIR}

  delete_locations

  ${BIN_DIR}/restart_log.sh
  if [[ $? -ne 0 ]]; then
    copy_logs
    error_helper "Restart error" 16
  fi
  capture
  
  for res in $(find ${SCEN_CHECK_DIR} -type f -name 'sipp_scenario_responder[0-9][0-9].xml'| sort); do
    base=$(basename $res .xml)
    is_enabled $(basename $res)
    get_ip $(basename $res)
    if [ "${peer_host}" != "" ]; then
      echo "$(date) - Update peer_host:${peer_host} ${ip}:${PORT} info"
      ${BIN_DIR}/update_peer_host.pl --ip=${ip} --port=${PORT} ${peer_host} ${SCEN_CHECK_DIR}/scenario.yml
      if [[ $? -ne 0 ]]; then
        error_helper "$(date) - error updating peer info" 15
      fi
    fi
    echo "$(date) - Running ${base} $ip:${PORT}-${MPORT}"
    if [ -f ${SCEN_CHECK_DIR}/${base}_reg.xml ]; then
      echo "$(date) - Register ${base} $ip:${PORT}-${MPORT}"
      ${BIN_DIR}/sipp.sh -T $transport -i $ip -p ${PORT} -r ${SCEN_CHECK_DIR}/${base}_reg.xml
    fi
    ${BIN_DIR}/sipp.sh -T $transport -i $ip -p ${PORT} -m ${MPORT} -r ${SCEN_CHECK_DIR}/${base}.xml &
    responder_pid="${responder_pid} ${base}:$!"
    check_port ${PORT}
    PORT=$port
    check_port ${MPORT} 3
    MPORT=$port
  done
  
  status=0
  # let's fire sipp scenarios
  for send in $(find ${SCEN_CHECK_DIR} -type f -name 'sipp_scenario[0-9][0-9].xml'| sort); do
    base=$(basename $send .xml)
    is_enabled $(basename $send)
    get_ip $(basename $send)
    echo "$(date) - Running ${base} $ip:50602-7002"
    ${BIN_DIR}/sipp.sh -T $transport -i $ip -p 50602 -m 7002 $send
    if [[ $? -ne 0 ]]; then
      echo "$(date) - $base error"
      status=1
    fi
    sleep 1
  done

  for res in ${responder_pid}; do
    base=$(echo $res| cut -d: -f1)
    pid=$(echo $res| cut -d: -f2)
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
  done

  stop_capture
  copy_logs
  # if any scenario has a log... error
  if [ $(ls ${SCEN_CHECK_DIR}/sipp_scenario*errors.log 2>/dev/null|wc -l) -ne 0 ]; then
    find ${SCEN_CHECK_DIR}/ -type f -name 'sipp_scenario*errors.log' -exec mv {} ${LOG_DIR} \;
    status=1
  fi
  if [[ $status -ne 0 ]]; then
    error_helper "error in sipp" 2
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
  echo -e "\t-P: skip parse"
  echo -e "\t-G: creation of graphviz image"
  echo -e "\t-g: creation of graphviz image only if test fails"
  echo -e "\t-d: DOMAIN"
  echo -e "\t-p CE|PRO default is CE"
  echo "Arguments:"
  echo -e "\tcheck_name. Scenario name to check. This is the name of the directory on scenarios dir."
}

while getopts 'hCd:p:RDTPGg' opt; do
  case $opt in
    h) usage; exit 0;;
    C) SKIP=1;;
    d) DOMAIN=$OPTARG;;
    p) PROFILE=$OPTARG;;
    R) SKIP_RUNSIPP=1;;
    D) SKIP_DELDOMAIN=1;;
    T) SKIP_TESTS=1;;
    P) SKIP_PARSE=1;;
    G) GRAPH=1;;
    g) GRAPH_FAIL=1;;
  esac
done
shift $(($OPTIND - 1))

if [[ $# != 1 ]]; then
  echo "Wrong number of arguments"
  usage
  exit 1
fi

NAME_CHECK="$1"
BASE_DIR="${BASE_DIR:-/usr/share/kamailio-config-tests}"
BIN_DIR="${BASE_DIR}/bin"
LOG_DIR="${BASE_DIR}/log/${NAME_CHECK}"
RESULT_DIR="${BASE_DIR}/result/${NAME_CHECK}"
KAM_LOG=${KAM_LOG:-"/var/log/ngcp/kamailio-proxy.log"}
KAMLB_LOG=${KAMLB_LOG:-"/var/log/ngcp/kamailio-lb.log"}
SEMS_LOG=${SEMS_LOG:-"/var/log/ngcp/sems.log"}
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

if [ ! -f ${SCEN_CHECK_DIR}/scenario.yml ]; then
  echo "${SCEN_CHECK_DIR}/scenario.yml not found"
  exit 14
fi

if [ -z $SKIP ]; then
  echo "$(date) - Deleting all info for ${DOMAIN} domain"
  delete_voip ${DOMAIN} # just to be sure nothing is there
  echo "$(date) - Creating ${DOMAIN}"
  create_voip ${DOMAIN}
  echo "$(date) - Adding prefs"
  create_voip_prefs
fi

if [ -z $SKIP_RUNSIPP ]; then
  echo "$(date) - Cleaning csv/reg.xml files"
  find ${SCEN_CHECK_DIR} -name 'sipp_scenario_responder*_reg.xml' -exec rm {} \;
  find ${SCEN_CHECK_DIR} -name '*.csv' -exec rm {} \;
  echo "$(date) - Generating csv/reg.xml files"
  ${BIN_DIR}/scenario.pl ${SCEN_CHECK_DIR}/scenario.yml
  if [[ $? -ne 0 ]]; then
    error_helper "Error creating csv files" 4
  fi
  echo "$(date) - Running sipp scenarios"
  run_sipp
  echo "$(date) - Done sipp"
fi

if [ -z ${SKIP_DELDOMAIN} ]; then
  echo "$(date) - Deleting domain:${DOMAIN}"
  delete_voip ${DOMAIN}
  echo "$(date) - Done"
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
  echo "$(date) - Cleaning tests files"
  find ${SCEN_CHECK_DIR} -type f -name '*test.yml' -exec rm {} \;
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
