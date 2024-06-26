#!/bin/bash
#
# Copyright: 2013-2021 Sipwise Development Team <support@sipwise.com>
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
CHECK_TYPE=sipp
SKIP_RUNSIPP=false
SKIP_CHECK=false
FIX_RETRANS=false
GRAPH=false
GRAPH_FAIL=false
SKIP_MOVE_JSON_KAM=false
CDR=false
CDR_TAG_DATA=false
ERR_FLAG=0
RETRANS_SIZE=2
SIP_SERVER=127.0.0.1
LOGTYPE="none"


# $1 kamailio msg parsed to yml
# $2 destination png filename
graph() {
  if [ -f "$1" ]; then
    "${BIN_DIR}/graph_flow.pl" "$1" "$2"
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


# since 3.6.0 there's a warning
# showing up and generates the error file
# See https://github.com/SIPp/sipp/issues/497
clean_sipp_error() {
  while read -r sipp_error ; do
    sed -i '/The following events occurred:/d' "${sipp_error}"
    sed -i '/Failed to delete FD from epoll/d' "${sipp_error}"
    [ -s "${sipp_error}" ] || rm -v "${sipp_error}"
  done < <(find "${LOG_DIR}/" -type f -name '*errors.log')
}

detect_sipp_error_files() {
  local find_cmd

  case ${SIPP_VERSION} in
    v3\.[0-5]\.*) ;;
    *) clean_sipp_error;;
  esac
  find_cmd=$(find "${LOG_DIR}/" -type f -name '*errors.log' 2>/dev/null|wc -l)
  if [ "${find_cmd}" -ne 0 ]; then
    echo "$(date) - Detected sipp error files"
    while read -r sipp_error ; do
      echo "${sipp_error}:"
      echo "---------"
      cat "${sipp_error}" && echo
      echo "---------"
    done < <(find "${LOG_DIR}/" -type f -name '*errors.log')
    return 0
  else
    echo "$(date) - No sipp error files detected"
    return 1
  fi
}

function str_check_error() {
  local err_type=()

  [[ $(($1 & 2)) -eq 2 ]] && err_type+=("FLOW")
  [[ $(($1 & 4)) -eq 4 ]] && err_type+=("FLOW_VARS")
  [[ $(($1 & 8)) -eq 8 ]] && err_type+=("SIP_IN")
  [[ $(($1 & 16)) -eq 16 ]] && err_type+=("SIP_OUT")
  [[ $(($1 & 32)) -eq 32 ]] && err_type+=("SIP")

  echo "${err_type[*]}"
}

check_error() {
  out=${2:-false}
  if [[ $1 -eq 4 ]] ; then
    ${out} && echo " NOT ok[FLOW_VARS] ** stop"
    return 0
  elif [[ $1 -eq 2 ]] ; then
    ${out} && echo " NOT ok[FLOW] ** stop"
    return 0
  elif [[ $1 -eq 6 ]] ; then
    ${out} && echo " NOT ok[FLOW FLOW_VARS] ** stop"
    return 0
  fi
  return 1
}

check_retrans_next() {
  # testing next json file, if exist. Necessary in case of retransmissions or wrong timing/order.
  local next_msg
  local next_tap
  local step
  local err_type
  local res

  step=${3:-1}
  next_test_filepath "$1"  "${step}"
  next_tap=${2/_test.tap/_test_next.tap}
  echo "$(date) - Fix retransmissions enabled: try to test the next[+${step}] json file"
  kam_msg=$(basename "${next_msg}")

  if [ -a "${next_msg}" ] ; then
    if [[ "${test_ok[*]}" =~ ${kam_msg} ]] ; then
      echo "$(date) - ** skip ${kam_msg} already processed"
      return 1
    fi
    echo -n "$(date) - Testing $(basename "$1") against ${kam_msg} -> $(basename "${next_tap}")"
    if "${BIN_DIR}/check.py" "$1" "${next_msg}" > "${next_tap}" ; then
      # Test using the next json file was fine. That means that, with high probability, there was a retransmission.
      # Next step is to backup the failed tap test and overwrite it with the working one
      mv "$2" "${2}_retrans"
      mv "${next_tap}" "$2"
      test_ok+=("${kam_msg}")
      check_json=${next_msg}
      echo " ok"
      return 0
    else
      res=$?
      err_type=$(str_check_error "${res}")
    fi

    if check_error "${res}" true; then
      check_json=${next_msg}
      # Test using the next json file was fine. That means that, with high probability, there was a retransmission.
      # Next step is to backup the failed tap test and overwrite it with the working one
      mv "$2" "${2}_retrans"
      mv "${next_tap}" "$2"
      return 2
    fi

    if [ -a "${next_tap}" ] ; then
      # Test using the next json file was a failure.
      # Next step is remove $next_tap file to don't create confusion during the additional checks
      rm "${next_tap}"
    fi
  else
    echo -n "$(date) - File $(basename "${next_msg}") doesn't exists. Result"
  fi

  echo " NOT ok[${err_type}]"
  return 1
}

check_retrans_prev() {
  # testing previous json file, if exist. Necessary in case of wrong timing/order.
  local prev_msg
  local prev_tap
  local step
  local err_type
  local kam_msg
  local res

  step=${3:-1}
  prev_test_filepath "$1" "${step}"
  prev_tap=${2/_test.tap/_test_prev.tap}
  echo "$(date) - Fix retransmissions enabled: try to test the previous[-${step}] json file"
  kam_msg=$(basename "${prev_msg}")

  if [ -a "${prev_msg}" ] ; then
    if [[ "${test_ok[*]}" =~ ${kam_msg} ]] ; then
      echo "$(date) - ** skip ${kam_msg} already processed"
      return 1
    fi
    echo -n "$(date) - Testing $(basename "$1") against ${kam_msg} -> $(basename "${prev_tap}")"
    if "${BIN_DIR}/check.py" "$1" "${prev_msg}" > "${prev_tap}" ; then
      # Test using the previous json file was fine. That means that, with high probability, there was a wrong timing/order.
      # Next step is to backup the failed tap test and overwrite it with the working one
      mv "$2" "${2}_retrans"
      mv "${prev_tap}" "$2"
      test_ok+=("${kam_msg}")
      check_json=${prev_msg}
      echo " ok"
      return 0
    else
      res=$?
      err_type=$(str_check_error "$res")
    fi

    if check_error "${res}" true; then
      check_json=${prev_msg}
      # Test using the previous json file was fine. That means that, with high probability, there was a wrong timing/order.
      # Next step is to backup the failed tap test and overwrite it with the working one
      mv "$2" "${2}_retrans"
      mv "${prev_tap}" "$2"
      return 2
    fi

    if [ -a "${prev_tap}" ] ; then
      # Test using the previous json file was a failure.
      # Next step is remove $prev_tap file to don't create confusion during the additional checks
      rm "${prev_tap}"
    fi
  else
    echo -n "$(date) - File $(basename "${prev_msg}") doesn't exists. Result"
  fi

  echo " NOT ok[${err_type}]"
  return 1
}

# $1 unit test yml
# $2 destination tap filename
# $3 number of messages to check before and after
check_retrans_block() {
  local res

  for i in $(seq "${3:-2}") ; do
    check_retrans_next "$1" "$2" "$i"
    res=$?
    [[ ${res} -eq 2 ]] && break
    [[ ${res} -eq 0 ]] && return 0
    check_retrans_prev "$1" "$2" "$i"
    res=$?
    [[ ${res} -eq 2 ]] && break
    [[ ${res} -eq 0 ]] && return 0
  done
  return 1
}

# $1 sip message test yml
# $2 sipp msg parsed to .msg log file
# $3 destination tap filename
check_sip_test() {
  local test_file="${1}"
  local msg_file="${2}"
  local dest_file="${3}"

  if ! [ -f "$1" ]; then
    generate_error_tap "$3" "$1"
    ERR_FLAG=1
    return 1
  fi
  if ! [ -f "$2" ]; then
    generate_error_tap "$3" "$2"
    ERR_FLAG=1
    return 1
  fi

  sipp_msg=$(basename "${msg_file}")
  if "${BIN_DIR}/check_sip.py" "${test_file}" "${msg_file}" > "${dest_file}" ; then
    echo " ok"
    test_ok+=("${sipp_msg}")
    return 0
  else
    err_type=$(str_check_error $?)
    echo " NOT ok[${err_type}]"
    ERR_FLAG=1
    # we have to add here show_sip.pl funcitoning to produce differences in results
    return 1
  fi
}

# $1 unit test yml
# $2 kamailio msg parsed to yml
# $3 destination tap filename
check_test() {
  local dest
  local err_type
  local kam_msg
  local res

  dest=${RESULT_DIR}/$(basename "$3" .tap)
  check_json=$2

  if ! [ -f "$1" ]; then
    generate_error_tap "$3" "$1"
    ERR_FLAG=1
    return 1
  fi
  if ! [ -f "$2" ]; then
    generate_error_tap "$3" "${check_json}"
    ERR_FLAG=1
    return 1
  fi

  kam_msg=$(basename "${check_json}")
  echo -n "$(date) - Testing $(basename "$1") against ${kam_msg} -> $(basename "$3")"
  if "${BIN_DIR}/check.py" "$1" "${check_json}" > "$3" ; then
    echo " ok"
    test_ok+=("${kam_msg}")
    return 0
  else
    res=$?
    err_type=$(str_check_error "${res}")
  fi

  echo " NOT ok[${err_type}]"

  if ! check_error "${res}" && "${FIX_RETRANS}" ; then
    check_retrans_block "$1" "$3" "${RETRANS_SIZE}" && return 0
    echo "$(date) - using $(basename "${check_json}") instead"
  fi

  ERR_FLAG=1
  if [ -x "${BIN_DIR}/show_flow_diff.pl" ] ; then
    echo "$(date) - Generating flow diff: ${dest}.diff"
    "${BIN_DIR}/show_flow_diff.pl" "$1" "${check_json}" > "${dest}.diff"
  fi
  if [ -x "${BIN_DIR}/show_sip.pl" ] ; then
    echo "$(date) - Generating: ${dest}.sip"
    "${BIN_DIR}/show_sip.pl" "${check_json}" > "${dest}.sip"
  fi
  if ( ! "${GRAPH}" ) && "${GRAPH_FAIL}" ; then
    echo "$(date) - Generating flow image: ${dest}.png"
    # In any failure case only the graph related to the original json file will be created
    graph "$msg" "${dest}.png"
    echo "$(date) - Done"
  fi
  return 1
}

release_appearance() {
  local values
  values=$(mktemp)
  ngcp-kamcmd proxy sca.all_appearances >"${values}" 2>&1
  if grep -q error "${values}" ; then
    # sca not enabled, not pbx scenario
    rm "${values}"
    return
  fi
  while read -r sca idx rest; do
    echo "$(date) release_appearance for ${sca} ${idx}"
    ngcp-kamcmd proxy sca.release_appearance "${sca}" "${idx}" || true
  done < "${values}"
  rm "${values}"
}

# $1 msg to echo
# $2 exit value
error_helper() {
  echo "$1"
  if ! "${SKIP_DELDOMAIN}" ; then
    "${BIN_DIR}/provide_scenario.sh" "${SCEN_CHECK_DIR}" delete
  fi
  stop_capture
  check_rtp
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

check_rtp() {
  local uuid

  uuid=$(awk '/^test_uuid:/ { print $2 }' "${SCEN_CHECK_DIR}/scenario.yml")
  mapfile -t callids < <(${RTPENGINE_CTL} list sessions all|awk '{print $2}')
  for callid in "${callids[@]}" ; do
    if [[ "${callid}" =~ NGCP%${uuid}%/// ]]; then
      echo "$(date) - Terminate RTP sessions for ${callid}"
      ${RTPENGINE_CTL} list sessions "${callid}"
      ${RTPENGINE_CTL} terminate "${callid}"
      ERR_FLAG=1
    fi
  done
}

#$1 is filename
get_ip() {
  local scen=()
  while IFS=";" read -r -a scen; do
    transport=${scen[1]}
    ip=${scen[2]}
    port=${scen[3]}
    mport=${scen[4]}
  done< <(grep "$1" "${SCEN_CHECK_DIR}/scenario.csv")
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
  if [ -f "${SEMS_B2B_LOG}" ] ; then
    # copy the sems-b2b log
    cp "${SEMS_B2B_LOG}" "${LOG_DIR}/sems-b2b.log"
  fi
  # copy the kamailio-lb log
  cp "${KAMLB_LOG}" "${LOG_DIR}/kamailio-lb.log"
  # copy the rtpengine log
  cp "${RTP_LOG}" "${LOG_DIR}/rtp.log"
}

memdbg() {
  if [ -x /usr/share/ngcp-system-tools/kamcmd/memdbg ] ; then
    ngcp-kamcmd proxy memdbg all >/dev/null
    mkdir -p "${MLOG_DIR}"
    ngcp-memdbg-csv "${KAM_LOG}" "${MLOG_DIR}" >/dev/null
  fi
}

# $1 sipp xml scenario file
run_sipp() {
  local base=""
  local pid=""
  local responder_pid=""

  # test LOG_DIR
  # we do not want to remove "/*" don't we?
  if [ -z "${LOG_DIR}" ]; then
    error_helper "LOG_DIR empty" 1
  fi
  rm -rf "${LOG_DIR}"
  echo "$(date) - create ${LOG_DIR}"
  mkdir -p "${LOG_DIR}"

  echo "$(date) - Cleaning registrations"
  "${BIN_DIR}/clean_registrations.pl" "${SCEN_CHECK_DIR}/scenario.yml"
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

  echo "$(date) - kamailio debugger level"
  "${BIN_DIR}/kam_dbg.pl" "${SCEN_CHECK_DIR}/scenario.yml"

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

    if [ -f "${SCEN_CHECK_DIR}/${base}_reg.xml" ]; then
      echo "$(date) - Register ${base} ${ip}:${port}-${mport} => ${SIP_SERVER}"
      "${BIN_DIR}/sipp.sh" -I"${SIP_SERVER}" \
        -T "$transport" -i "${ip}" -p "${port}" \
        -e "${LOG_DIR}/${base}_reg_errors.log" \
        -r "${SCEN_CHECK_DIR}/${base}_reg.xml"
    fi
    pid=$("${BIN_DIR}/sipp.sh" -b -I"${SIP_SERVER}" \
      -T "$transport" -i "${ip}" -p "${port}" \
      -l "${LOG_DIR}/${base}.msg" \
      -e "${LOG_DIR}/${base}_errors.log" \
      -L "${LOGTYPE}" \
      -m "${mport}" -r "${SCEN_CHECK_DIR}/${base}.xml")
    echo "$(date) - Running ${base}[${pid}] ${ip}:${port}-${mport} => ${SIP_SERVER}"
    responder_pid="${responder_pid} ${base}:${pid}"
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
    echo "$(date) - Running ${base} ${ip}:${port}-${mport} => ${SIP_SERVER}"
    if ! "${BIN_DIR}/sipp.sh" -I"${SIP_SERVER}" \
        -L "${LOGTYPE}" \
        -e "${LOG_DIR}/${base}_errors.log" -l "${LOG_DIR}/${base}.msg" \
        -T "${transport}" -i "${ip}" -p "${port}" -m "${mport}" "${send}"
    then
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
        status=1
      fi
    fi
  done

  if "${CAPTURE}" ; then
    stop_capture
  fi
  if "${MEMDBG}" ; then
    memdbg
  fi

  echo "$(date) - kamailio debugger level reset to 1"
  "${BIN_DIR}/kam_dbg.pl" --clean "${SCEN_CHECK_DIR}/scenario.yml"

  copy_logs
  # if any scenario has a log... error
  if detect_sipp_error_files; then
    status=1
  fi

  echo "$(date) - Cleaning registrations"
  "${BIN_DIR}/clean_registrations.pl" "${SCEN_CHECK_DIR}/scenario.yml"
  if [ "${PROFILE}" = "PRO" ] ; then
    release_appearance
  fi

  if [[ ${status} -ne 0 ]]; then
    echo "error in sipp!"
    ERR_FLAG=1;
  fi
}

test_filepath() {
  local msg_name

  if grep -q '^retrans: true' "${1}"; then
    echo "$(date) - Detected a test for a retransmission"
    msg_name=${1/_test_retransmission.yml/.json_retransmission}
    msg="${LOG_DIR}/$(basename "${msg_name}")"
    if [ -f "${msg}" ]; then
      return
    fi
  fi
  msg_name=${1/_test.yml/.json}
  msg="${LOG_DIR}/$(basename "${msg_name}")"
}

next_test_filepath() {
  local msg_name
  local old_json
  local new_json
  local step=${2:-1}

  msg_name=${1/_test.yml/.json}

  msg_name=$(basename "${msg_name}")
  old_json="${msg_name:0:4}"
  new_json=$(((10#$old_json)+step))
  new_json=$(printf %04d ${new_json})
  msg_name="${new_json}${msg_name:4}"

  next_msg="${LOG_DIR}/${msg_name}"
}

prev_test_filepath() {
  local msg_name
  local old_json
  local new_json
  local step=${2:-1}

  msg_name=${1/_test.yml/.json}
  msg_name=$(basename "${msg_name}")
  old_json="${msg_name:0:4}"
  new_json=$(((10#$old_json)-step))  # There should not be any problem since they start from 0001
  new_json=$(printf %04d ${new_json})
  msg_name="${new_json}${msg_name:4}"

  prev_msg="${LOG_DIR}/${msg_name}"
}

cdr_check() {
  if [ -f "$1" ] ; then
    echo -n "$(date) - Testing $(basename "$1") against $(basename "$2") -> $(basename "$3")"
    if "${BIN_DIR}/cdr_check.py" "--text" "$1" "$2" > "$3" ; then
      echo " ok"
      return 0
    fi
    echo " NOT ok"
    return 1
  else
    echo "$(date) - CDR test file $1 doesn't exist, skipping CDR test"
    return 0
  fi
}

usage() {
  echo "Usage: check.sh [-hCDRGgKmtd] [-T <all|cfgt|sipp>] [-p PROFILE ] [-s GROUP] check_name"
  echo "Options:"
  echo -e "\\t-I: SIP_SERVER IP, default:127.0.0.1"
  echo -e "\\t-C: skip creation of domain and subscribers"
  echo -e "\\t-R: skip run sipp"
  echo -e "\\t-D: skip deletion of domain and subscribers as final step"
  echo -e "\\t-T check type <all|cfgt|sipp>. Default: sipp"
  echo -e "\\t-t skip check results"
  echo -e "\\t-P: skip parse"
  echo -e "\\t-G: creation of graphviz image"
  echo -e "\\t-g: creation of graphviz image only if test fails"
  echo -e "\\t-r: fix retransmission issues"
  echo -e "\\t-p: CE|PRO default is CE"
  echo -e "\\t-M: skip move of kamailio json output to log folder"
  echo -e "\\t-K: enable tcpdump capture"
  echo -e "\\t-s: scenario group. Default: scenarios"
  echo -e "\\t-m: enable memdbg csv"
  echo -e "\\t-c: enable cdr validation"
  echo -e "\\t-d: enable cdr tag data validation"
  echo -e "\\t-L [caller|responder|all|none]: produce sipp logfile for <log> directive inside <action> (default none)"
  echo "Arguments:"
  echo -e "\\tcheck_name. Scenario name to check. This is the name of the directory on GROUP dir."
}

while getopts 'hI:Cp:Rs:DtT:GgrcdKMmw:L:' opt; do
  case $opt in
    h) usage; exit 0;;
    I) SIP_SERVER=${OPTARG};;
    C) SKIP=true; SKIP_DELDOMAIN=true;;
    p) PROFILE=${OPTARG};;
    R) SKIP_RUNSIPP=true; SKIP_DELDOMAIN=true;;
    t) SKIP_CHECK=true;;
    s) GROUP=${OPTARG};;
    D) SKIP_DELDOMAIN=true;;
    T) CHECK_TYPE=${OPTARG};;
    K) CAPTURE=true;;
    G) GRAPH=true;;
    g) GRAPH_FAIL=true;;
    r) FIX_RETRANS=true;;
    M) SKIP_MOVE_JSON_KAM=true;;
    m) MEMDBG=true;;
    c) CDR=true;;
    d) CDR_TAG_DATA=true;;
    w) RETRANS_SIZE=${OPTARG};;
    L) LOGTYPE=${OPTARG};;
    *) usage; exit 1;;
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
SEMS_B2B_LOG=${SEMS_B2B_LOG:-"/var/log/ngcp/sems-b2b.log"}
RTP_LOG=${RTP_LOG:-"/var/log/ngcp/rtp.log"}
SCEN_DIR="${BASE_DIR}/${GROUP}"
SCEN_CHECK_DIR="${SCEN_DIR}/${NAME_CHECK}"
PROFILE="${PROFILE:-CE}"
MLOG_DIR="${BASE_DIR}/mem"
test_uuid=$(grep test_uuid "${SCEN_CHECK_DIR}/scenario.yml" | awk '{print $2}')

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

if [ -f "${SCEN_CHECK_DIR}/pro.yml" ] && [ "${PROFILE}" == "CE" ]; then
  echo "${SCEN_CHECK_DIR}/pro.yml found but PROFILE ${PROFILE}"
  echo "Skipping the tests because not in scope"
  exit 0
fi

case "${CHECK_TYPE}" in
  all|sipp|cfgt) echo "check type:${CHECK_TYPE}" ;;
  *) echo "unknown check type ${CHECK_TYPE}"; exit 1;;
esac

if ! "$SKIP" ; then
  "${BIN_DIR}/provide_scenario.sh" "${SCEN_CHECK_DIR}" create
fi

if ! "$SKIP_RUNSIPP" ; then
    rtpengine_ctl_ip=$(grep 'listen-cli' /etc/rtpengine/rtpengine.conf|\
      awk '{print $3}')
    RTPENGINE_CTL="rtpengine-ctl -ip ${rtpengine_ctl_ip}"
    SIPP_VERSION=$(sipp -v | awk -F- '/SIPp/ { print $1 }' | awk '{print $2}')

    if [[ ${CHECK_TYPE} != sipp ]] ; then
      if ! [ -d "${KAM_DIR}" ] ; then
        echo "$(date) - dir and perms for ${KAM_DIR}"
        mkdir -p "${KAM_DIR}"
        chown -R kamailio:kamailio "${KAM_DIR}"
      fi
      if ngcp-kamcmd proxy cfgt.list | grep -q "uuid: ${test_uuid}" ; then
        echo "$(date) - clean cfgt scenario ${test_uuid}"
        ngcp-kamcmd proxy cfgt.clean "${test_uuid}"
      fi
    fi

  echo "$(date) - Running sipp scenarios"
  run_sipp
  echo "$(date) - Done sipp"

  echo "$(date) - copy scenario_ids.yml file"
  cp "${SCEN_CHECK_DIR}/scenario_ids.yml" "${LOG_DIR}"
  echo "$(date) - Done"

  if [[ ${CHECK_TYPE} != sipp ]] ; then
    if ! ${SKIP_MOVE_JSON_KAM} ; then
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
      else
        echo "$(date) - No json files found"
      fi
      echo "$(date) - clean cfgt scenario ${test_uuid}"
      ngcp-kamcmd proxy cfgt.clean "${test_uuid}"
      echo "$(date) - Done"
    fi

    if "${FIX_RETRANS}" ; then
      echo "$(date) - Checking retransmission issues"
      RETRANS_ISSUE=false
      mapfile -t file_find < <(find "${LOG_DIR}" -maxdepth 1 -name '*.json' | sort)
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
        mapfile -t file_find < <(find "${LOG_DIR}" -maxdepth 1 -name '*.json' | sort)
        a=1
        for json_file in "${file_find[@]}" ; do
          new_name=$(printf "%04d.json" "${a}")
          mv -n "${json_file}" "${LOG_DIR}/${new_name}" &> /dev/null
          ((a++))
        done
      fi
      echo "$(date) - Done"
    fi
  fi

  echo "$(date) - check RTP sessions, wait 5 secs first"
  sleep 2
  check_rtp
fi

if ! "${SKIP_DELDOMAIN}" ; then
  "${BIN_DIR}/provide_scenario.sh" "${SCEN_CHECK_DIR}" delete
fi

# let's check the results
if ! ${SKIP_CHECK} ; then
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

  test_ok=()

  if [[ ${CHECK_TYPE} != sipp ]] ; then
    while read -r t; do
      test_filepath "${t}"
      echo "$(date) - Check test ${t} on ${msg}"
      dest=${RESULT_DIR}/$(basename "${t}" .yml)
      check_test "${t}" "${msg}" "${dest}.tap" && result=OK || result=KO
      echo "$(date) - $(basename "${t}" .yml) - Done[${result}]"
      if "${GRAPH}" ; then
        echo "$(date) - Generating flow image: ${dest}.png"
        graph "${msg}" "${dest}.png"
        echo "$(date) - Done"
      fi
    done < <(find "${SCEN_CHECK_DIR}" -maxdepth 1 -name '[0-9][0-9][0-9][0-9]_test*.yml'|sort)
  fi

  if [[ ${CHECK_TYPE} != cfgt ]] ; then
      echo "$(date) - ~~~~~"
      while read -r t; do
        msg_name=${t/_test.yml/.msg}
        sip_msg="${LOG_DIR}/$(basename "${msg_name}")"
        echo -n "$(date) - SIP: Check test $(basename "${t}") on ${sip_msg}"
        dest=$(basename "${sip_msg}")
        dest=${RESULT_DIR}/${dest/.msg/.tap}
        check_sip_test "${t}" "$sip_msg" "${dest}"
      done < <(find "${SCEN_CHECK_DIR}" -maxdepth 1 -name 'sipp_scenario*_test.yml'|sort)
      echo "$(date) - ~~~~~"
  fi

  if "${CDR}" ; then
    echo "$(date) - Validating CDRs"
    t_cdr="${SCEN_CHECK_DIR}/cdr_test.yml"
    msg="${LOG_DIR}/cdr.txt"
    dest="${RESULT_DIR}/cdr_test.tap"
    echo "$(date) - Check test ${t_cdr} on ${msg}"
    if cdr_check "${t_cdr}" "${msg}" "${dest}" ; then
      result=OK
    else
      result=KO; ERR_FLAG=1
    fi
    echo "$(date) - Done[${result}]"
  fi

  if "${CDR_TAG_DATA}" ; then
    t_cdr="${SCEN_CHECK_DIR}/cdr_tag_data_test.yml"
    if [ -f "$t_cdr" ]; then
      echo "$(date) - Validating CDRs tag data"
      msg="${LOG_DIR}/cdr_tag_data.txt"
      dest="${RESULT_DIR}/cdr_tag_data_test.tap"
      echo "$(date) - Check test ${t_cdr} on ${msg}"
      if cdr_check "${t_cdr}" "${msg}" "${dest}" ; then
        result=OK
      else
        result=KO; ERR_FLAG=1
      fi
      echo "$(date) - Done[${result}]"
    fi
  fi

  echo "$(date) - ================================================================================="
fi
exit ${ERR_FLAG}
#EOF
