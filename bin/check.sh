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

# sipwise password for mysql connections
. /etc/mysql/sipwise.cnf

# $1 kamailio msg parsed to yml
# $2 destination png filename
function graph
{
  local OPTS
  if [ -n "${JSON_KAM}" ]; then
    OPTS="--json"
  fi
  if [ -f "$1" ]; then
    "${BIN_DIR}/graph_flow.pl" $OPTS "$1" "$2"
  else
    echo "No $1 found"
    ERR_FLAG=1
  fi
}

# $1 destination tap file
# $2 file path
function generate_error_tap
{
  local tap_file="$1"
  cat <<EOF > $tap_file
1..1
not ok 1 - ERROR: File $2 does not exists
EOF
echo "$(date) - $(basename "$2") NOT ok"
}

# $1 unit test yml
# $2 kamailio msg parsed to yml
# $3 destination tap filename
function check_test
{
  local dest
  local kam_type="--yaml"

  dest=${RESULT_DIR}/$(basename "$3" .tap)

  if ! [ -f "$1" ]; then
    generate_error_tap "$3" "$1"
    ERR_FLAG=1
    return
  fi
  if ! [ -f "$2" ]; then
    generate_error_tap "$3" "$2"
    ERR_FLAG=1
    return
  fi

  if [ -n "${JSON_KAM}" ]; then
    kam_type="--json"
  fi

  echo -n "$(date) - Testing $(basename "$1") againts $(basename "$2") -> $(basename "$3")"
  if ! "${BIN_DIR}/check.py" ${kam_type} "$1" "$2" > "$3" ; then
    echo " NOT ok"
    ERR_FLAG=1
    if [ -z "${GRAPH}" ] && [ -n "${GRAPH_FAIL}" ]; then
      echo "$(date) - Generating flow image: ${dest}.png"
      graph "$msg" "${dest}.png"
      echo "$(date) - Done"
    fi
  else
    echo " ok"
  fi
}

# $1 domain
function create_voip
{
  if ! "${BIN_DIR}/create_subscribers.pl" "${SCEN_CHECK_DIR}/scenario.yml" ; then
    echo "$(date) - Deleting domain:${DOMAIN}"
    delete_voip "$1"
    echo "$(date) - Cannot create domain subscribers"
    exit 1
  fi
}

# $1 prefs yml file
function create_voip_prefs
{
  if [ -f "${SCEN_CHECK_DIR}/rewrite.yml" ]; then
    echo "$(date) - Creating rewrite rules"
    "${BIN_DIR}/create_rewrite_rules.pl" "${SCEN_CHECK_DIR}/rewrite.yml"
  fi

  if [ -f "${SCEN_CHECK_DIR}/callforward.yml" ]; then
   echo "$(date) - Setting callforward config"
   "${BIN_DIR}/set_subscribers_callforward.pl" "${SCEN_CHECK_DIR}/callforward.yml"
  fi

  if [ -f "${SCEN_CHECK_DIR}/speeddial.yml" ]; then
   echo "$(date) - Setting speeddial config"
   "${BIN_DIR}/set_subscribers_speeddial.pl" "${SCEN_CHECK_DIR}/speeddial.yml"
  fi

  if [ -f "${SCEN_CHECK_DIR}/ncos.yml" ]; then
    echo "$(date) - Creating ncos levels"
    "${BIN_DIR}/create_ncos.pl" "${SCEN_CHECK_DIR}/ncos.yml"
  fi

  if [ -f "${SCEN_CHECK_DIR}/peer.yml" ]; then
    echo "$(date) - Creating peers"
    "${BIN_DIR}/create_peers.pl" "${SCEN_CHECK_DIR}/peer.yml"
    # REMOVE ME!! fix for REST API
    ngcp-sercmd proxy lcr.reload
  fi

  if [ -f "${SCEN_CHECK_DIR}/lnp.yml" ]; then
    echo "$(date) - Creating lnp carrier/number"
    "${BIN_DIR}/create_lnp.pl" "${SCEN_CHECK_DIR}/lnp.yml"
  fi

  if [ -f "${SCEN_CHECK_DIR}/prefs.json" ]; then
    echo "$(date) - Setting preferences"
    "${BIN_DIR}/set_preferences.pl" "${SCEN_CHECK_DIR}/prefs.json"
  fi
}

# $1 domain
function delete_voip
{
  /usr/bin/ngcp-delete_domain "$1" >/dev/null 2>&1

  if [ -f "${SCEN_CHECK_DIR}/peer.yml" ]; then
    echo "$(date) - Deleting peers"
    "${BIN_DIR}/create_peers.pl" -delete "${SCEN_CHECK_DIR}/peer.yml"
  fi

  if [ -f "${SCEN_CHECK_DIR}/lnp.yml" ]; then
    echo "$(date) - Deleting lnp carrier/number"
    "${BIN_DIR}/create_lnp.pl" -delete "${SCEN_CHECK_DIR}/lnp.yml"
  fi

  if [ -f "${SCEN_CHECK_DIR}/ncos.yml" ]; then
    echo "$(date) - Deleting ncos levels"
    "${BIN_DIR}/create_ncos.pl" -delete "${SCEN_CHECK_DIR}/ncos.yml"
  fi

  if [ -f "${SCEN_CHECK_DIR}/rewrite.yml" ]; then
    echo "$(date) - Deleting rewrite rules"
    "${BIN_DIR}/create_rewrite_rules.pl" -delete "${SCEN_CHECK_DIR}/rewrite.yml"
  fi

  if [ -f "${SCEN_CHECK_DIR}/hosts" ]; then
    echo "$(date) - Deleting foreign domains"
    sed -e "s:$(cat "${SCEN_CHECK_DIR}/hosts")::" -i /etc/hosts
    rm "${SCEN_CHECK_DIR}/hosts"
  fi
}

function delete_locations
{
  local f
  local sub

  for f in ${SCEN_CHECK_DIR}/callee.csv ${SCEN_CHECK_DIR}/caller.csv; do
    for sub in $(uniq "$f" | grep "${DOMAIN}" | cut -d\; -f1 | xargs); do
      ngcp-kamctl proxy ul rm "$sub@${DOMAIN}"
      # delete possible banned user
      ngcp-sercmd lb htable.delete auth "$sub@${DOMAIN}::auth_count"
    done
  done

  # check what's in the DDBB
  f=$(mysql -usipwise -p"${SIPWISE_DB_PASSWORD}" \
      kamailio -e 'select count(*) from location;' -s -r | head)
  if [ "$f" != "0" ]; then
    echo "$(date) Cleaning location table"
    sub=$(mysql -usipwise -p"${SIPWISE_DB_PASSWORD}" \
      -e 'select concat(username, "@", domain) as user from kamailio.location;' \
      -r -s | head| uniq|xargs)
    for f in $sub; do
      ngcp-kamctl proxy ul rm "$f"
    done
    mysql -usipwise -p"${SIPWISE_DB_PASSWORD}" \
      -e 'delete from kamailio.location;' || true
  fi
}

# $1 msg to echo
# $2 exit value
function error_helper
{
  echo "$1"
  if [ -z "${SKIP_DELDOMAIN}" ]; then
    echo "$(date) - Deleting domain:${DOMAIN}"
    delete_voip "${DOMAIN}"
  fi
  find "${SCEN_CHECK_DIR}/" -type f -name 'sipp_scenario*errors.log' \
    -exec mv {} "${LOG_DIR}" \;
  stop_capture
  exit "$2"
}

function capture
{
  local name
  name=$(basename "${SCEN_CHECK_DIR}")
  echo "$(date) - Begin capture"
  for inter in $(ip link | grep '^[0-9]' | cut -d: -f2 | sed 's/ //' | xargs); do
    tcpdump -i "${inter}" -n -s 65535 -w "${LOG_DIR}/${name}_${inter}.pcap" &
    capture_pid="$capture_pid ${inter}:$!"
  done
}

function stop_capture
{
  local inter=""
  local temp_pid=""
  if [ -n "${capture_pid}" ]; then
    for temp in ${capture_pid}; do
      inter=$(echo "$temp"|cut -d: -f1)
      temp_pid=$(echo "$temp"|cut -d: -f2)
      #echo "inter:${inter} temp_pid:${temp_pid}"
      if ps -p"${temp_pid}" &> /dev/null ; then
        echo "$(date) - End ${inter}[$temp_pid] capture"
        kill -15 "${temp_pid}"
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
    netstat -n | grep -q ":$port "
    status=$?
  done
}

#$1 is filename
function get_ip
{
  transport=$(grep "$1" "${SCEN_CHECK_DIR}/scenario.csv"|cut -d\; -f2| tr -d '\n')
  ip=$(grep "$1" "${SCEN_CHECK_DIR}/scenario.csv"|cut -d\; -f3| tr -d '\n')
  if [[ $? -ne 0 ]]; then
    error_helper "cannot find $1 ip on ${SCEN_CHECK_DIR}/scenario.csv" 10
  fi
  peer_host=$(grep "$1" "${SCEN_CHECK_DIR}/scenario.csv"|cut -d\; -f4| tr -d '\n')
  foreign_dom=$(grep "$1" "${SCEN_CHECK_DIR}/scenario.csv"|cut -d\; -f5| tr -d '\n')
}

#$1 is filename
function is_enabled
{
  if ! grep -q "$1" "${SCEN_CHECK_DIR}/scenario.csv" ; then
    echo "$(date) $1 deactivated"
    # shellcheck disable=SC2104
    continue
  fi
}

function copy_logs
{
  # copy the kamailio log
  cp "${KAM_LOG}" "${LOG_DIR}/kamailio.log"
  if [ -f "${SEMS_LOG}" ] ; then
    # copy the sems log
    cp "${SEMS_LOG}" "${LOG_DIR}/sems.log"
  fi
  # copy the kamailio-lb log
  cp "${KAMLB_LOG}" "${LOG_DIR}/kamailio-lb.log"
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
  local responder_pid=""

  # test LOG_DIR
  # we dont want to remove "/*" don't we?
  if [ -z "${LOG_DIR}" ]; then
    error_helper "LOG_DIR empty" 1
  fi
  rm -rf "${LOG_DIR}"
  echo "$(date) - create ${LOG_DIR}"
  mkdir -p "${LOG_DIR}"

  delete_locations

  if ! "${BIN_DIR}/restart_log.sh" ; then
    copy_logs
    error_helper "Restart error" 16
  fi
  if [ "${CAPTURE}" = "1" ] ; then
    capture
  fi

  if [ -e "${SCEN_CHECK_DIR}/presence.sh" ]; then
    echo "$(date) - Presence xcap"
    if ! "${SCEN_CHECK_DIR}/presence.sh" ; then
      error_helper "error in presence.sh" 17
    fi
  fi

  for res in $(find "${SCEN_CHECK_DIR}" -type f -name 'sipp_scenario_responder[0-9][0-9].xml'| sort); do
    base=$(basename "$res" .xml)
    is_enabled "$(basename "$res")"
    get_ip "$(basename "$res")"
    if [ "${peer_host}" != "" ]; then
      echo "$(date) - Update peer_host:${peer_host} ${ip}:${PORT} info"
      if ! "${BIN_DIR}/update_peer_host.pl" --ip="${ip}" --port="${PORT}" \
          "${peer_host}" ;
      then
        error_helper "$(date) - error updating peer info" 15
      else
        # REMOVE ME!! fix for REST API
          ngcp-sercmd proxy lcr.reload
      fi
    fi
    if [ "${foreign_dom}" == "yes" ]; then
      echo "$(date) - foreign domain detected... using 5060 port"
      PORT="5060"
    fi

    if [ -f "${SCEN_CHECK_DIR}/${base}_reg.xml" ]; then
      echo "$(date) - Register ${base} $ip:${PORT}-${MPORT}"
      "${BIN_DIR}/sipp.sh" -T "$transport" -i "$ip" -p "${PORT}" \
        -r "${SCEN_CHECK_DIR}/${base}_reg.xml"
    fi
    pid=$("${BIN_DIR}/sipp.sh" -b -T "$transport" -i "$ip" -p "${PORT}" \
      -m "${MPORT}" -r "${SCEN_CHECK_DIR}/${base}.xml")
    echo "$(date) - Running ${base}[${pid}] ${ip}:${PORT}-${MPORT}"
    responder_pid="${responder_pid} ${base}:${pid}"

    if [ "${foreign_dom}" == "no" ]; then
      check_port ${PORT}
      PORT=$port
    fi
    check_port ${MPORT} 3
    MPORT=$port
  done

  status=0
  # let's fire sipp scenarios
  for send in $(find "${SCEN_CHECK_DIR}" -type f -name 'sipp_scenario[0-9][0-9].xml'| sort); do
    base=$(basename "$send" .xml)
    is_enabled "$(basename "$send")"
    get_ip "$(basename "$send")"
    echo "$(date) - Running ${base} $ip:50602-7002"
    if ! "${BIN_DIR}/sipp.sh" -T "$transport" -i "$ip" -p 50602 -m 7002 "$send" ; then
      echo "$(date) - $base error"
      status=1
    fi
  done

  for res in ${responder_pid}; do
    base=$(echo "$res"| cut -d: -f1)
    pid=$(echo "$res"| cut -d: -f2)
    if ps -p"${pid}" &> /dev/null ; then
      echo "$(date) - sipp responder $base pid $pid not finished yet. Waiting 5 secs"
      sleep 5
      if ps -p"${pid}" &> /dev/null ; then
        echo "$(date) - sipp responder $base pid $pid not finished yet. Killing it"
        kill -SIGUSR1 "${pid}"
      fi
    fi
  done

  if [ "${CAPTURE}" = "1" ] ; then
    stop_capture
  fi
  copy_logs
  # if any scenario has a log... error
  if [ "$(find "${SCEN_CHECK_DIR}" -name 'sipp_scenario*errors.log' 2>/dev/null|wc -l)" -ne 0 ]; then
    find "${SCEN_CHECK_DIR}/" -type f -name 'sipp_scenario*errors.log' -exec mv {} "${LOG_DIR}" \;
    status=1
  fi

  delete_locations

  if [[ $status -ne 0 ]]; then
    error_helper "error in sipp" 2
  fi
}

# shellcheck disable=SC2001
function test_filepath
{
  local msg_name

  if [ -z "${JSON_KAM}" ]; then
    msg_name=$(echo "$1"|sed 's/_test\.yml/\.yml/')
  else
    msg_name=$(echo "$1"|sed 's/_test\.yml/\.json/')
  fi
  msg=${LOG_DIR}/$(basename "$msg_name")
}

function usage
{
  echo "Usage: check.sh [-hCDRTGgJ] [-d DOMAIN ] [-p PROFILE ] -s [GROUP] check_name"
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
  echo -e "\t-J kamailio json output ON. PARSE skipped"
  echo -e "\t-K enable tcpdump capture"
  echo -e "\t-s scenario group. Default: scenarios"
  echo "Arguments:"
  echo -e "\tcheck_name. Scenario name to check. This is the name of the directory on GROUP dir."
}

while getopts 'hCd:p:Rs:DTPGgJK' opt; do
  case $opt in
    h) usage; exit 0;;
    C) SKIP=1;;
    d) DOMAIN=$OPTARG;;
    p) PROFILE=$OPTARG;;
    R) SKIP_RUNSIPP=1; SKIP_DELDOMAIN=1;;
    s) GROUP=$OPTARG;;
    D) SKIP_DELDOMAIN=1;;
    T) SKIP_TESTS=1;;
    P) SKIP_PARSE=1;;
    K) CAPTURE=1;;
    G) GRAPH=1;;
    g) GRAPH_FAIL=1;;
    J) JSON_KAM=1;;
  esac
done
shift $((OPTIND - 1))

if [[ $# != 1 ]]; then
  echo "Wrong number of arguments"
  usage
  exit 1
fi

GROUP="${GROUP:-scenarios}"
NAME_CHECK="$1"
KAM_DIR="${KAM_DIR:-/var/run/kamailio/cfgtest}"
BASE_DIR="${BASE_DIR:-/usr/share/kamailio-config-tests}"
BIN_DIR="${BASE_DIR}/bin"
LOG_DIR="${BASE_DIR}/log/${GROUP}/${NAME_CHECK}"
RESULT_DIR="${BASE_DIR}/result/${GROUP}/${NAME_CHECK}"
KAM_LOG=${KAM_LOG:-"/var/log/ngcp/kamailio-proxy.log"}
KAMLB_LOG=${KAMLB_LOG:-"/var/log/ngcp/kamailio-lb.log"}
SEMS_LOG=${SEMS_LOG:-"/var/log/ngcp/sems.log"}
SCEN_DIR="${BASE_DIR}/${GROUP}"
SCEN_CHECK_DIR="${SCEN_DIR}/${NAME_CHECK}"
DOMAIN=${DOMAIN:-"spce.test"}
PROFILE="${PROFILE:-CE}"

if [ "${PROFILE}" != "CE" ] && [ "${PROFILE}" != "PRO" ]; then
  echo "PROFILE ${PROFILE} unknown"
  usage
  exit 2
fi

if ! [ -d "${SCEN_CHECK_DIR}" ]; then
  echo "no ${SCEN_CHECK_DIR} found"
  usage
  exit 3
fi

if ! [ -f "${SCEN_CHECK_DIR}/scenario.yml" ]; then
  echo "${SCEN_CHECK_DIR}/scenario.yml not found"
  exit 14
fi

if [ -z "$SKIP" ]; then
  echo "$(date) - Deleting all info for ${DOMAIN} domain"
  delete_voip "${DOMAIN}" # just to be sure nothing is there
  echo "$(date) - Creating ${DOMAIN}"
  create_voip "${DOMAIN}"
  echo "$(date) - Adding prefs"
  create_voip_prefs
fi

if [ -z "$SKIP_RUNSIPP" ]; then
  if [ -n "${JSON_KAM}" ] ; then
    if ! [ -d "${KAM_DIR}" ] ; then
      echo "$(date) - dir and perms for ${KAM_DIR}"
      mkdir -p "${KAM_DIR}"
      chown -R kamailio:kamailio "${KAM_DIR}"
    else
      echo "$(date) - remove ${KAM_DIR}/${NAME_CHECK}"
      # shellcheck disable=SC2115
      rm -rf "${KAM_DIR}/${NAME_CHECK}"
    fi
  fi
  echo "$(date) - Cleaning csv/reg.xml files"
  find "${SCEN_CHECK_DIR}" -name 'sipp_scenario_responder*_reg.xml' -exec rm {} \;
  find "${SCEN_CHECK_DIR}" -name '*.csv' -exec rm {} \;
  echo "$(date) - Generating csv/reg.xml files"
  if ! "${BIN_DIR}/scenario.pl" "${SCEN_CHECK_DIR}/scenario.yml" ; then
    error_helper "Error creating csv files" 4
  fi

  if [ -f "${SCEN_CHECK_DIR}/hosts" ]; then
    echo "$(date) - Setting foreign domains"
    cat "${SCEN_CHECK_DIR}/hosts" >> /etc/hosts
  fi

  echo "$(date) - Running sipp scenarios"
  run_sipp
  echo "$(date) - Done sipp"
else
  if [ -n "${JSON_KAM}" ] ; then
    echo "$(date) - get kamailio cfgt files"
    if [ -d "${KAM_DIR}/${NAME_CHECK}" ] ; then
      for i in "${KAM_DIR}/${NAME_CHECK}"/*.json ; do
        expand -t1 "$i" > "${LOG_DIR}/$(printf '%04d.json' "$(basename "$i" .json)")"
      done
    else
      echo "no cfgt files found"
    fi
  fi
fi

if [ -z "${SKIP_DELDOMAIN}" ]; then
  echo "$(date) - Deleting domain:${DOMAIN}"
  delete_voip "${DOMAIN}"
  echo "$(date) - Done"
fi

if [ -z "${SKIP_PARSE}" ]; then
  if [ -z "${JSON_KAM}" ]; then
    echo "$(date) - Parsing ${LOG_DIR}/kamailio.log"
    "${BIN_DIR}/ulog_parser.pl" "${LOG_DIR}/kamailio.log ${LOG_DIR}"
    echo "$(date) - Done"
  fi
fi

# let's check the results
ERR_FLAG=0
if [ -z "${SKIP_TESTS}" ]; then
  if [ -d "${RESULT_DIR}" ]; then
    echo "$(date) - Cleaning result dir"
    rm -rf "${RESULT_DIR}"
  fi
  mkdir -p "${RESULT_DIR}"
  echo "$(date) - Cleaning tests files"
  find "${SCEN_CHECK_DIR}" -type f -name '*test.yml' -exec rm {} \;
  echo "$(date) - Generating tests files"
  "${BIN_DIR}/generate_tests.sh" -d "${SCEN_CHECK_DIR}" "${PROFILE}"
  echo "$(date) - Done"

  for t in ${SCEN_CHECK_DIR}/*_test.yml; do
    test_filepath "$t"
    echo "$(date) - check test $t on $msg"
    dest=${RESULT_DIR}/$(basename "$t" .yml)
    check_test "$t" "$msg" "${dest}.tap"
    echo "$(date) - Done"
    if [ -n "${GRAPH}" ]; then
      echo "$(date) - Generating flow image: ${dest}.png"
      graph "$msg" "${dest}.png"
      echo "$(date) - Done"
    fi
  done
fi
exit ${ERR_FLAG}
#EOF
