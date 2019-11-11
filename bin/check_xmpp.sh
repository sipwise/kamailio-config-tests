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
RUN_DIR="$(dirname "$0")"
export BASE_DIR=${BASE_DIR:-$RUN_DIR}
# Set up the environment, to use local perl modules
export PERL5LIB="${BASE_DIR}/lib"
SKIP=false
SKIP_DELDOMAIN=false
SKIP_TESTS=false

# sipwise password for mysql connections
declare -r SIPWISE_EXTRA_CNF="/etc/mysql/sipwise_extra.cnf"

if [ ! -f "${SIPWISE_EXTRA_CNF}" ]; then
  echo "Error: missing DB credentials file '${SIPWISE_EXTRA_CNF}'." >&2
  exit 1
fi


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

# $1 domain
delete_voip() {
  /usr/bin/ngcp-delete-domain "$1" >/dev/null 2>&1
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

usage() {
  echo "Usage: check_xmpp.sh [-hCRDT] [-d DOMAIN ] [-p PROFILE ] check_name"
  echo "Options:"
  echo -e "\\t-C: skip creation of domain and subscribers"
  echo -e "\\t-R: skip run sipp"
  echo -e "\\t-D: skip deletion of domain and subscribers as final step"
  echo -e "\\t-d: DOMAIN"
  echo -e "\\t-p CE|PRO default is CE"
  echo "Arguments:"
  echo -e "\\tcheck_name. Scenario name to check. This is the name of the directory on GROUP dir."
}

while getopts 'hCd:p:RD' opt; do
  case $opt in
    h) usage; exit 0;;
    C) SKIP=true;;
    d) DOMAIN=${OPTARG};;
    p) PROFILE=${OPTARG};;
    R) SKIP_RUNSIPP=true; SKIP_DELDOMAIN=true;;
    D) SKIP_DELDOMAIN=true;;
    *) echo "unknown option ${opt}"; exit 1;;
  esac
done
shift $((OPTIND - 1))

if [[ $# != 1 ]]; then
  echo "Wrong number of arguments"
  usage
  exit 1
fi

GROUP=xmpp
NAME_CHECK="$1"
BIN_DIR="${BASE_DIR}/bin"
RESULT_DIR="${BASE_DIR}/result/${GROUP}/${NAME_CHECK}"
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

if [ -f "${SCEN_CHECK_DIR}/pro.yml" ] && [ "${PROFILE}" == "CE" ]; then
  echo "${SCEN_CHECK_DIR}/pro.yml found but PROFILE ${PROFILE}"
  echo "Skipping the tests because not in scope"
  exit 0
fi

if ! "$SKIP" ; then
  echo "$(date) - Deleting all info for ${DOMAIN} domain"
  delete_voip "${DOMAIN}" # just to be sure nothing is there
  echo "$(date) - Creating ${DOMAIN}"
  create_voip "${DOMAIN}"
fi

echo "NAME_CHECK:${NAME_CHECK} BASE_DIR:${BASE_DIR} BIN_DIR:${BIN_DIR} RESULT_DIR:${RESULT_DIR} SCEN_DIR:${SCEN_DIR} SCEN_CHECK_DIR:${SCEN_CHECK_DIR} DOMAIN:${DOMAIN} PROFILE:${PROFILE}"

if ! "${SKIP_DELDOMAIN}" ; then
  echo "$(date) - Deleting domain:${DOMAIN}"
  delete_voip "${DOMAIN}"
  echo "$(date) - Done"
fi


ERR_FLAG=0

exit ${ERR_FLAG}
#EOF
