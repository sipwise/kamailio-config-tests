#!/bin/bash
#
# Copyright: 2013-2016 Sipwise Development Team <support@sipwise.com>
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

CAPTURE=false
SKIP=false
MEMDBG=false
SKIP_DELDOMAIN=false
SKIP_TESTS=false
SKIP_PARSE=false
SKIP_RUNSIPP=false
FIX_RETRANS=false
GRAPH=false
GRAPH_FAIL=false
JSON_KAM=false
CDR=false


# sipwise password for mysql connections
. /etc/mysql/sipwise.cnf


# $1 kamailio msg parsed to yml
# $2 destination png filename
graph() {
  local OPTS
  if "${JSON_KAM}" ; then
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
generate_error_tap() {
  local tap_file="$1"
  cat <<EOF > "${tap_file}"
1..1
not ok 1 - ERROR: File $2 does not exists
EOF
echo "$(date) - $(basename "$2") NOT ok"
}

# $1 unit test yml
# $2 kamailio msg parsed to yml
# $3 destination tap filename
check_test() {
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

  if "${JSON_KAM}" ; then
    kam_type="--json"
  fi

  echo -n "$(date) - Testing $(basename "$1") against $(basename "$2") -> $(basename "$3")"
  if "${BIN_DIR}/check.py" ${kam_type} "$1" "$2" > "$3" ; then
    echo " ok"
    return
  fi

  echo " NOT ok"

  if "${FIX_RETRANS}" ; then
    # testing next json file, if exist. Necessary in case of retransmissions or wrong timing/order.
    echo "$(date) - Fix retransmissions enabled: try to test the next json file"
    local next_msg
    local next_tap
    next_test_filepath "$1"
    next_tap=${3/_test.tap/_test_next.tap}

    if [ -a "${next_msg}" ] ; then
      echo -n "$(date) - Testing $(basename "$1") against $(basename "${next_msg}") -> $(basename "${next_tap}")"
      if "${BIN_DIR}/check.py" ${kam_type} "$1" "${next_msg}" > "${next_tap}" ; then
        # Test using the next json file was fine. That means that, with high probability, there was a retransmission.
        # Next step is to backup the failed tap test and overwrite it with the working one
        mv "$3" "${3}_retrans"
        mv "${next_tap}" "$3"
        echo " ok"
        return
      fi

      if [ -a "${next_tap}" ] ; then
        # Test using the next json file was a failure.
        # Next step is remove $next_tap file to don't create confusion during the additional checks
        rm "${next_tap}"
      fi
    else
      echo -n "$(date) - File $(basename "${next_msg}") doesn't exists. Result"
    fi

    echo " NOT ok"

    # testing previous json file, if exist. Necessary in case of wrong timing/order.
    echo "$(date) - Fix retransmissions enabled: try to test the previous json file"
    local prev_msg
    local prev_tap
    prev_test_filepath "$1"
    prev_tap=${3/_test.tap/_test_prev.tap}

    if [ -a "${prev_msg}" ] ; then
      echo -n "$(date) - Testing $(basename "$1") against $(basename "${prev_msg}") -> $(basename "${prev_tap}")"
      if "${BIN_DIR}/check.py" ${kam_type} "$1" "${prev_msg}" > "${prev_tap}" ; then
        # Test using the previous json file was fine. That means that, with high probability, there was a wrong timing/order.
        # Next step is to backup the failed tap test and overwrite it with the working one
        mv "$3" "${3}_retrans"
        mv "${prev_tap}" "$3"
        echo " ok"
        return
      fi

      if [ -a "${prev_tap}" ] ; then
        # Test using the previous json file was a failure.
        # Next step is remove $prev_tap file to don't create confusion during the additional checks
        rm "${prev_tap}"
      fi
    else
      echo -n "$(date) - File $(basename "${prev_msg}") doesn't exists. Result"
    fi

    echo " NOT ok"
  fi

  ERR_FLAG=1
  if ( ! "${GRAPH}" ) && "${GRAPH_FAIL}" ; then
    echo "$(date) - Generating flow image: ${dest}.png"
    # In any failure case only the graph related to the original json file will be created
    graph "$msg" "${dest}.png"
    echo "$(date) - Done"
  fi
}

# $1 domain
create_voip() {
  if ! "${BIN_DIR}/create_subscribers.pl" \
    "${SCEN_CHECK_DIR}/scenario.yml" "${SCEN_CHECK_DIR}/scenario_ids.yml"
  then
    echo "$(date) - Deleting domain:${DOMAIN}"
    delete_voip "$1"
    echo "$(date) - Cannot create domain subscribers"
    exit 1
  fi
}

# $1 prefs yml file
create_voip_prefs() {
  if [ -f "${SCEN_CHECK_DIR}/rewrite.yml" ]; then
    echo "$(date) - Creating rewrite rules"
    "${BIN_DIR}/create_rewrite_rules.pl" "${SCEN_CHECK_DIR}/rewrite.yml"
  fi

  if [ -f "${SCEN_CHECK_DIR}/callforward.yml" ]; then
   echo "$(date) - Setting callforward config"
   "${BIN_DIR}/set_subscribers_callforward_advanced.pl" "${SCEN_CHECK_DIR}/callforward.yml"
  fi

  if [ -f "${SCEN_CHECK_DIR}/trusted.yml" ]; then
   echo "$(date) - Setting trusted sources"
   "${BIN_DIR}/set_subscribers_trusted_sources.pl" "${SCEN_CHECK_DIR}/trusted.yml"
  fi

  if [ -f "${SCEN_CHECK_DIR}/speeddial.yml" ]; then
   echo "$(date) - Setting speeddial config"
   "${BIN_DIR}/set_subscribers_speeddial.pl" "${SCEN_CHECK_DIR}/speeddial.yml"
  fi

  if [ -f "${SCEN_CHECK_DIR}/ncos.yml" ]; then
    echo "$(date) - Creating ncos levels"
    "${BIN_DIR}/create_ncos.pl" "${SCEN_CHECK_DIR}/ncos.yml"
  fi

  if [ -f "${SCEN_CHECK_DIR}/soundsets.yml" ]; then
    echo "$(date) - Creating soundsets"
    "${BIN_DIR}/create_soundsets.pl" \
      "${SCEN_CHECK_DIR}/soundsets.yml" "${SCEN_CHECK_DIR}/scenario_ids.yml"
  fi

  if [ -f "${SCEN_CHECK_DIR}/peer.yml" ]; then
    echo "$(date) - Creating peers"
    "${BIN_DIR}/create_peers.pl" \
      "${SCEN_CHECK_DIR}/peer.yml" "${SCEN_CHECK_DIR}/scenario_ids.yml"
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
delete_voip() {
  /usr/bin/ngcp-delete_domain "$1" >/dev/null 2>&1

  if [ -f "${SCEN_CHECK_DIR}/peer.yml" ]; then
    echo "$(date) - Deleting peers"
    "${BIN_DIR}/create_peers.pl" -delete "${SCEN_CHECK_DIR}/peer.yml"
  fi

  if [ -f "${SCEN_CHECK_DIR}/trusted.yml" ]; then
   echo "$(date) - Deleting trusted sources"
   # Trusted sources are not deleted from kamailio cache when the domain is removed
   # therefore better reload them from the database
   ngcp-sercmd proxy permissions.trustedReload
  fi

  if [ -f "${SCEN_CHECK_DIR}/lnp.yml" ]; then
    echo "$(date) - Deleting lnp carrier/number"
    "${BIN_DIR}/create_lnp.pl" -delete "${SCEN_CHECK_DIR}/lnp.yml"
    # REMOVE ME!! fix for REST API
    ngcp-sercmd proxy lcr.reload
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

  if [ -f "${SCEN_CHECK_DIR}/soundsets.yml" ]; then
    echo "$(date) - Deleting soundsets"
    "${BIN_DIR}/create_soundsets.pl" -delete "${SCEN_CHECK_DIR}/soundsets.yml"
  fi
}

delete_locations() {
  local f
  local sub

  for f in ${SCEN_CHECK_DIR}/callee.csv ${SCEN_CHECK_DIR}/caller.csv; do
    for sub in $(uniq "${f}" | grep "${DOMAIN}" | cut -d\; -f1 | xargs); do
      ngcp-kamctl proxy fifo ul.rm location "${sub}@${DOMAIN}" >/dev/null
      # delete possible banned user
      ngcp-sercmd lb htable.delete auth "${sub}@${DOMAIN}::auth_count"
    done
  done

  # check what's in the DDBB
  f=$(mysql -usipwise -p"${SIPWISE_DB_PASSWORD}" \
      kamailio -e 'select count(*) from location;' -s -r | head)
  if [ "${f}" != "0" ]; then
    echo "$(date) Cleaning location table"
    sub=$(mysql -usipwise -p"${SIPWISE_DB_PASSWORD}" \
      -e 'select concat(username, "@", domain) as user from kamailio.location;' \
      -r -s | head| uniq|xargs)
    for f in $sub; do
      ngcp-kamctl proxy fifo ul.rm location "${f}" >/dev/null
    done
    mysql -usipwise -p"${SIPWISE_DB_PASSWORD}" \
      -e 'delete from kamailio.location;' || true
  fi
}

release_appearance() {
  local values
  values=$(mktemp)
  ngcp-sercmd proxy sca.all_appearances >"${values}" 2>&1
  if grep -q error "${values}" ; then
    # sca not enabled, not pbx scenario
    rm "${values}"
    return
  fi
  while read -r sca idx rest; do
    echo "$(date) release_appearance for ${sca} ${idx}"
    ngcp-sercmd proxy sca.release_appearance "${sca}" "${idx}" || true
  done < "${values}"
  rm "${values}"
}

# $1 msg to echo
# $2 exit value
error_helper() {
  echo "$1"
  if ! "${SKIP_DELDOMAIN}" ; then
    echo "$(date) - Deleting domain:${DOMAIN}"
    delete_voip "${DOMAIN}"
  fi
  find "${SCEN_CHECK_DIR}/" -type f -name 'sipp_scenario*errors.log' \
    -exec mv {} "${LOG_DIR}" \;
  stop_capture
  exit "$2"
}

capture() {
  local name
  name=$(basename "${SCEN_CHECK_DIR}")
  echo "$(date) - Start tcpdump captures"
  for inter in $(ip link | grep '^[0-9]' | cut -d: -f2 | sed 's/ //' | xargs); do
    tcpdump -i "${inter}" -n -s 65535 -w "${LOG_DIR}/${name}_${inter}.pcap" &
    capture_pid="$capture_pid ${inter}:$!"
  done
}

stop_capture() {
  echo "$(date) - Stop tcpdump captures"
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
check_port() {
  local status=0
  local port=$1
  local step=${2:-1}

  until [ ${status} -eq 1 ]; do
    if netstat -an | grep -q ":${port} " ; then
      port=$((port + step))
    else
      status=1
    fi
  done
  echo ${port}
}

# $1 media port to check
# sipp uses media_port and media_port+2
check_mport() {
  local status=0
  local mport=$1
  local step=${2:-3}
  local mport2
  until [ ${status} -eq 1 ]; do
    if ! (netstat -aun | grep -q ":${mport} ") ; then
      mport2=$((mport + 2))
      if ! (netstat -aun | grep -q ":${mport2} "); then
        status=1
      fi
    fi
    if [ $status -eq 0 ] ; then
      mport=$((mport + step))
    fi
  done
  echo ${mport}
}

#$1 is filename
get_ip() {
  transport=$(grep "$1" "${SCEN_CHECK_DIR}/scenario.csv"|cut -d\; -f2| tr -d '\n')
  ip=$(grep "$1" "${SCEN_CHECK_DIR}/scenario.csv"|cut -d\; -f3| tr -d '\n')
  if [[ $? -ne 0 ]]; then
    error_helper "cannot find $1 ip on ${SCEN_CHECK_DIR}/scenario.csv" 10
  fi
  peer_host=$(grep "$1" "${SCEN_CHECK_DIR}/scenario.csv"|cut -d\; -f4| tr -d '\n')
  foreign_dom=$(grep "$1" "${SCEN_CHECK_DIR}/scenario.csv"|cut -d\; -f5| tr -d '\n')
}

copy_logs() {
  # copy the kamailio log
  cp "${KAM_LOG}" "${LOG_DIR}/kamailio.log"
  if [ -f "${SEMS_LOG}" ] ; then
    # copy the sems log
    cp "${SEMS_LOG}" "${LOG_DIR}/sems.log"
  fi
  if [ -f "${SEMS_PBX_LOG}" ] ; then
    # copy the sems-pbx log
    cp "${SEMS_PBX_LOG}" "${LOG_DIR}/sems-pbx.log"
  fi
  # copy the kamailio-lb log
  cp "${KAMLB_LOG}" "${LOG_DIR}/kamailio-lb.log"
}

memdbg() {
  if [ -x /usr/share/ngcp-system-tools/kamcmd/memdbg ] ; then
    ngcp-sercmd proxy memdbg all >/dev/null
    mkdir -p "${MLOG_DIR}"
    ngcp-memdbg-csv "${KAM_LOG}" "${MLOG_DIR}" >/dev/null
  fi
}

# $1 sipp xml scenario file
run_sipp() {
  local PORT
  local MPORT
  PORT=$(check_port 50603)
  MPORT=$(check_mport 46003)

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
  if [ "${PROFILE}" = "PRO" ] ; then
    release_appearance
  fi

  if ! "${BIN_DIR}/restart_log.sh" ; then
    copy_logs
    error_helper "Restart error" 16
  fi
  if "${CAPTURE}" ; then
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
    if ! grep -q "$(basename "${res}")" "${SCEN_CHECK_DIR}/scenario.csv" ; then
      echo "$(date) $(basename "${res}") deactivated"
      continue
    fi
    get_ip "$(basename "${res}")"
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
      echo "$(date) - Register ${base} ${ip}:${PORT}-${MPORT}"
      "${BIN_DIR}/sipp.sh" -T "$transport" -i "${ip}" -p "${PORT}" \
        -r "${SCEN_CHECK_DIR}/${base}_reg.xml"
    fi
    pid=$("${BIN_DIR}/sipp.sh" -b -T "$transport" -i "${ip}" -p "${PORT}" \
      -m "${MPORT}" -r "${SCEN_CHECK_DIR}/${base}.xml")
    echo "$(date) - Running ${base}[${pid}] ${ip}:${PORT}-${MPORT}"
    responder_pid="${responder_pid} ${base}:${pid}"

    if [ "${foreign_dom}" == "no" ]; then
      PORT=$(check_port "$((PORT+1))")
    fi
    MPORT=$(check_mport "$((MPORT+2))")
  done

  local status=0
  # let's fire sipp scenarios
  for send in $(find "${SCEN_CHECK_DIR}" -type f -name 'sipp_scenario[0-9][0-9].xml'| sort); do
    base=$(basename "$send" .xml)
    if ! grep -q "$(basename "${send}")" "${SCEN_CHECK_DIR}/scenario.csv" ; then
      echo "$(date) $(basename "${send}") deactivated"
      continue
    fi
    get_ip "$(basename "${send}")"
    PORT=$(check_port )
    MPORT=$(check_mport )
    echo "$(date) - Running ${base} $ip:51602-45003"
    if ! "${BIN_DIR}/sipp.sh" -T "${transport}" -i "${ip}" -p 51602 -m 45003 "${send}" ; then
      echo "$(date) - ${base} error"
      status=1
    fi
  done

  for res in ${responder_pid}; do
    base=$(echo "${res}"| cut -d: -f1)
    pid=$(echo "${res}"| cut -d: -f2)
    if ps -p"${pid}" &> /dev/null ; then
      echo "$(date) - sipp responder ${base} pid ${pid} not finished yet. Waiting 5 secs"
      sleep 5
      if ps -p"${pid}" &> /dev/null ; then
        echo "$(date) - sipp responder ${base} pid ${pid} not finished yet. Killing it"
        kill -SIGUSR1 "${pid}"
      fi
    fi
  done

  if "${CAPTURE}" ; then
    stop_capture
  fi
  if "${MEMDBG}" ; then
    memdbg
  fi
  copy_logs
  # if any scenario has a log... error
  if [ "$(find "${SCEN_CHECK_DIR}" -name 'sipp_scenario*errors.log' 2>/dev/null|wc -l)" -ne 0 ]; then
    find "${SCEN_CHECK_DIR}/" -type f -name 'sipp_scenario*errors.log' -exec mv {} "${LOG_DIR}" \;
    status=1
  fi

  delete_locations
  if [ "${PROFILE}" = "PRO" ] ; then
    release_appearance
  fi

  if [[ ${status} -ne 0 ]]; then
    error_helper "error in sipp" 2
  fi
}

test_filepath() {
  local msg_name

  if ! "${JSON_KAM}" ; then
    msg_name=${1/_test.yml/.yml}
  else
    msg_name=${1/_test.yml/.json}
  fi
  msg="${LOG_DIR}/$(basename "${msg_name}")"
}

next_test_filepath() {
  local msg_name
  local old_json
  local new_json

  if ! "${JSON_KAM}" ; then
    msg_name=${1/_test.yml/.yml}
  else
    msg_name=${1/_test.yml/.json}
  fi

  msg_name=$(basename "${msg_name}")
  old_json="${msg_name:0:4}"
  new_json=$(((10#$old_json)+1))
  new_json=$(printf %04d ${new_json})
  msg_name="${new_json}${msg_name:4}"

  next_msg="${LOG_DIR}/${msg_name}"
}

prev_test_filepath() {
  local msg_name
  local old_json
  local new_json

  if ! "${JSON_KAM}" ; then
    msg_name=${1/_test.yml/.yml}
  else
    msg_name=${1/_test.yml/.json}
  fi

  msg_name=$(basename "${msg_name}")
  old_json="${msg_name:0:4}"
  new_json=$(((10#$old_json)-1))  #There should't be any problem since they start from 0001
  new_json=$(printf %04d ${new_json})
  msg_name="${new_json}${msg_name:4}"

  prev_msg="${LOG_DIR}/${msg_name}"
}

cdr_check() {
  if [ -f "$1" ] ; then
    echo -n "$(date) - Testing $(basename "$1") against $(basename "$2") -> $(basename "$3")"
    if "${BIN_DIR}/cdr_check.py" "--text" "$1" "$2" > "$3" ; then
      echo " ok"
      return
    fi
    echo " NOT ok"
  else
    echo "$(date) - CDR test file $1 doesn't exist, skipping CDR test"
  fi
}

usage() {
  echo "Usage: check.sh [-hCDRTGgJKm] [-d DOMAIN ] [-p PROFILE ] -s [GROUP] check_name"
  echo "Options:"
  echo -e "\t-C: skip creation of domain and subscribers"
  echo -e "\t-R: skip run sipp"
  echo -e "\t-D: skip deletion of domain and subscribers as final step"
  echo -e "\t-T: skip checks"
  echo -e "\t-P: skip parse"
  echo -e "\t-G: creation of graphviz image"
  echo -e "\t-g: creation of graphviz image only if test fails"
  echo -e "\t-r: fix retransmission issues"
  echo -e "\t-d: DOMAIN"
  echo -e "\t-p CE|PRO default is CE"
  echo -e "\t-J kamailio json output ON. PARSE skipped"
  echo -e "\t-K enable tcpdump capture"
  echo -e "\t-s scenario group. Default: scenarios"
  echo -e "\t-m enable memdbg csv"
  echo -e "\t-c enable cdr validation"
  echo "Arguments:"
  echo -e "\tcheck_name. Scenario name to check. This is the name of the directory on GROUP dir."
}

while getopts 'hCd:p:Rs:DTPGgrcJKm' opt; do
  case $opt in
    h) usage; exit 0;;
    C) SKIP=true;;
    d) DOMAIN=${OPTARG};;
    p) PROFILE=${OPTARG};;
    R) SKIP_RUNSIPP=true; SKIP_DELDOMAIN=true;;
    s) GROUP=${OPTARG};;
    D) SKIP_DELDOMAIN=true;;
    T) SKIP_TESTS=true;;
    P) SKIP_PARSE=true;;
    K) CAPTURE=true;;
    G) GRAPH=true;;
    g) GRAPH_FAIL=true;;
    r) FIX_RETRANS=true;;
    J) JSON_KAM=true;;
    m) MEMDBG=true;;
    c) CDR=true;;
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
KAM_DIR="${KAM_DIR:-/tmp/cfgtest}"
JSON_DIR="${KAM_DIR}/${NAME_CHECK}"
BASE_DIR="${BASE_DIR:-/usr/share/kamailio-config-tests}"
BIN_DIR="${BASE_DIR}/bin"
LOG_DIR="${BASE_DIR}/log/${GROUP}/${NAME_CHECK}"
RESULT_DIR="${BASE_DIR}/result/${GROUP}/${NAME_CHECK}"
KAM_LOG=${KAM_LOG:-"/var/log/ngcp/kamailio-proxy.log"}
KAMLB_LOG=${KAMLB_LOG:-"/var/log/ngcp/kamailio-lb.log"}
SEMS_LOG=${SEMS_LOG:-"/var/log/ngcp/sems.log"}
SEMS_PBX_LOG=${SEMS_PBX_LOG:-"/var/log/ngcp/sems-pbx.log"}
SCEN_DIR="${BASE_DIR}/${GROUP}"
SCEN_CHECK_DIR="${SCEN_DIR}/${NAME_CHECK}"
DOMAIN=${DOMAIN:-"spce.test"}
PROFILE="${PROFILE:-CE}"
MLOG_DIR="${BASE_DIR}/mem"

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

if ! "$SKIP" ; then
  echo "$(date) - Deleting all info for ${DOMAIN} domain"
  delete_voip "${DOMAIN}" # just to be sure nothing is there
  echo "$(date) - Creating ${DOMAIN}"
  create_voip "${DOMAIN}"
  echo "$(date) - Adding prefs"
  create_voip_prefs
fi

if ! "$SKIP_RUNSIPP" ; then
  if "${JSON_KAM}" ; then
    if ! [ -d "${KAM_DIR}" ] ; then
      echo "$(date) - dir and perms for ${KAM_DIR}"
      mkdir -p "${KAM_DIR}"
      chown -R kamailio:kamailio "${KAM_DIR}"
    else
      echo "$(date) - remove ${JSON_DIR}"
      rm -rf "${JSON_DIR}"
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

  echo "$(date) - move scenario_ids.yml file"
  mv "${SCEN_CHECK_DIR}/scenario_ids.yml" "${LOG_DIR}"
  echo "$(date) - Done"

  if "${JSON_KAM}" ; then
    echo "$(date) - Move kamailio json files"
    if [ -d "${JSON_DIR}" ] ; then
      for i in "${JSON_DIR}"/*.json ; do
        json_size_before=$(stat -c%s "${i}")
        moved_file="${LOG_DIR}/$(printf "%04d.json" "$(basename "${i}" .json)")"
        expand -t1 "${i}" > "${moved_file}"
        json_size_after=$(stat -c%s "${moved_file}")
        echo "$(date) - Moved file ${i} with size before: ${json_size_before} and after: ${json_size_after}"
        rm "${i}"
      done
      rm -rf "${JSON_DIR}"
      echo "$(date) - Done"
    else
      echo "$(date) - No json files found"
    fi
  fi

  if "${FIX_RETRANS}" ; then
    echo "$(date) - Checking retransmission issues"
    RETRANS_ISSUE=false
    file_find=($(find "${LOG_DIR}" -maxdepth 1 -name '*.json' | sort))
    for json_file in "${file_find[@]}" ; do
      file_find=("${file_find[@]:1}")
      if ! [ -a "${json_file}" ] ; then
        continue
      fi
      for next_json_file in "${file_find[@]}" ; do
        if ! [ -a "${next_json_file}" ] ; then
          continue
        fi
        if ( diff -q -u <(tail -n3 "${json_file}") <(tail -n3 "${next_json_file}") &> /dev/null ) ; then
          echo "$(date) - $(basename "${next_json_file}") seems a retransmission of $(basename "${json_file}") ---> renaming the file in $(basename "${next_json_file}")_retransmission"
          mv -f "${next_json_file}" "${next_json_file}_retransmission"
          RETRANS_ISSUE=true
        fi
      done
    done

    if "${RETRANS_ISSUE}" ; then
      echo "$(date) - Reordering kamailio json files"
      file_find=($(find "${LOG_DIR}" -maxdepth 1 -name '*.json' | sort))
      a=1
      for json_file in "${file_find[@]}" ; do
        new_name=$(printf "%04d.json" "${a}")
        mv -n "${json_file}" "${LOG_DIR}/${new_name}" &> /dev/null
        let a=a+1
      done
    fi

    echo "$(date) - Done"
  fi

fi


if ! "${SKIP_DELDOMAIN}" ; then
  echo "$(date) - Deleting domain:${DOMAIN}"
  delete_voip "${DOMAIN}"
  echo "$(date) - Done"
fi


if ! "${SKIP_PARSE}" ; then
  if ! "${JSON_KAM}" ; then
    echo "$(date) - Parsing ${LOG_DIR}/kamailio.log"
    "${BIN_DIR}/ulog_parser.pl" "${LOG_DIR}/kamailio.log ${LOG_DIR}"
    echo "$(date) - Done"
  fi
fi


# let's check the results
ERR_FLAG=0
if ! "${SKIP_TESTS}" ; then
  echo "$(date) - ================================================================================="
  echo "$(date) - Check [${GROUP}/${PROFILE}]: ${NAME_CHECK}"

  if [ -d "${RESULT_DIR}" ]; then
    echo "$(date) - Cleaning result dir"
    rm -rf "${RESULT_DIR}"
  fi
  mkdir -p "${RESULT_DIR}"

  echo "$(date) - Cleaning tests files"
  find "${SCEN_CHECK_DIR}" -type f -name '*test.yml' -exec rm {} \;
  echo "$(date) - Generating tests files"
  "${BIN_DIR}/generate_tests.sh" -d \
    "${SCEN_CHECK_DIR}" "${LOG_DIR}/scenario_ids.yml" "${PROFILE}"

  for t in ${SCEN_CHECK_DIR}/[0-9][0-9][0-9][0-9]_test.yml; do
    test_filepath "${t}"
    echo "$(date) - Check test ${t} on ${msg}"
    dest=${RESULT_DIR}/$(basename "${t}" .yml)
    check_test "${t}" "${msg}" "${dest}.tap"
    echo "$(date) - Done"
    if "${GRAPH}" ; then
      echo "$(date) - Generating flow image: ${dest}.png"
      graph "${msg}" "${dest}.png"
      echo "$(date) - Done"
    fi
  done

  if "${CDR}" ; then
    echo "$(date) - Validating CDRs"
    t_cdr="${SCEN_CHECK_DIR}/cdr_test.yml"
    msg="${LOG_DIR}/cdr.txt"
    dest="${RESULT_DIR}/cdr_test.tap"
    echo "$(date) - Check test ${t_cdr} on ${msg}"
    cdr_check "${t_cdr}" "${msg}" "${dest}"
    echo "$(date) - Done"
  fi
  echo "$(date) - ================================================================================="
fi
exit ${ERR_FLAG}
#EOF