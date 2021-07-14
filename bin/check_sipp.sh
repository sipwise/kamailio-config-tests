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
set -e
ERR_FLAG=0

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

# $1 sip message test yml
# $2 sipp msg parsed to .msg log file
# $3 destination tap filename
check_sip_test() {
  local test_file="${1}"
  local msg_file="${2}"
  local dest_file="${3}"
  local sipp_msg

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
    echo " NOT ok[SIP]"
    ERR_FLAG=1
    # we have to add here show_sip.pl funcitoning to produce differences in results
    return 1
  fi
}

usage() {
  echo "Usage: check_sipp.sh [-h] [-p PROFILE ] -s [GROUP] check_name"
  echo "Options:"
  echo -e "\\t-p: CE|PRO default is CE"
  echo -e "\\t-s: scenario group. Default: scenarios"
  echo "Arguments:"
  echo -e "\\tcheck_name. Scenario name to check. This is the name of the directory on GROUP dir."
}

while getopts 'hp:s:' opt; do
  case $opt in
    h) usage; exit 0;;
    p) PROFILE=${OPTARG};;
    s) GROUP=${OPTARG};;
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
BASE_DIR="${BASE_DIR:-/usr/share/kamailio-config-tests}"
BIN_DIR="${BASE_DIR}/bin"
LOG_DIR="${BASE_DIR}/log/${GROUP}/${NAME_CHECK}"
RESULT_DIR="${BASE_DIR}/result/${GROUP}/${NAME_CHECK}"
SCEN_DIR="${BASE_DIR}/${GROUP}"
SCEN_CHECK_DIR="${SCEN_DIR}/${NAME_CHECK}"
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

if [ -f "${SCEN_CHECK_DIR}/pro.yml" ] && [ "${PROFILE}" == "CE" ]; then
  echo "${SCEN_CHECK_DIR}/pro.yml found but PROFILE ${PROFILE}"
  echo "Skipping the tests because not in scope"
  exit 0
fi

# let's check the results
echo "$(date) - ================================================================================="
echo "$(date) - Check [${GROUP}/${PROFILE}]: ${NAME_CHECK}"

mkdir -p "${RESULT_DIR}"

echo "$(date) - Cleaning tests files"
find "${SCEN_CHECK_DIR}" -type f -name 'sipp_scenario*test.yml' -exec rm {} \;
echo "$(date) - Generating tests files"
"${BIN_DIR}/generate_tests.sh" \
  -f 'sipp_scenario*test.yml.tt2' \
  -d "${SCEN_CHECK_DIR}" "${LOG_DIR}/scenario_ids.yml" "${PROFILE}"

test_ok=()
while read -r t; do
    msg_name=${t/_test.yml/.msg}
    msg="${LOG_DIR}/$(basename "${msg_name}")"
    echo -n "$(date) - SIP: Check test $(basename "${t}") on ${msg}"
    dest=$(basename "${msg}")
    dest=${RESULT_DIR}/${dest/.msg/.tap}
    check_sip_test "${t}" "$msg" "${dest}"
done < <(find "${SCEN_CHECK_DIR}" -maxdepth 1 -name 'sipp_scenario*_test.yml'|sort)

echo "$(date) - ================================================================================="

exit ${ERR_FLAG}
#EOF
