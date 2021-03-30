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
# shellcheck disable=SC2155
declare -r ME="$(basename "$0")"
BASE_DIR="${BASE_DIR:-/usr/share/kamailio-config-tests}"
BIN_DIR="${BASE_DIR}/bin"
if [ -z "${PERL5LIB}" ]; then
  # Set up the environment, to use local perl modules
  export PERL5LIB="${BASE_DIR}/lib"
fi

usage() {
  cat <<EOF
Usage: ${ME} [-h] [-f config.yml] [-x GROUP] action

Options:
  -h: this help
  -f: config.yml path. Default: ${BASE_DIR}/config.yml
  -x: set GROUP scenario. Default: scenarios
Arguments:
  action. 'create' or 'delete'
EOF
}

CONFIG=${BASE_DIR}/config.yml
IP="127.126.0.1"
PORT=51602
MPORT=45003
PHONE_CC=43
PHONE_AC=1
PHONE_SN=1000
PEER_IP="127.0.2.1"
PEER_PORT=51602
PEER_MPORT=45003
PROFILE="${PROFILE:-}"
GROUP="${GROUP:-scenarios}"
SCEN=()

get_scenarios() {
  while read -r t; do
    SCEN+=( "${t}" )
  done < <("${BIN_DIR}/get_scenarios.sh" -p "${PROFILE}" -x "${GROUP}")
  if [[ ${#SCEN[@]} == 0 ]]; then
    echo "$(date) no scenarios found" >&2
    exit 1
  fi
}

while getopts 'hf:x:' opt; do
  case $opt in
    f) CONFIG=${OPTARG};;
    x) GROUP=${OPTARG};;
    h) usage; exit 0;;
    *) usage; exit 1;;
  esac
done
shift $((OPTIND - 1))

if [[ $# != 1 ]]; then
  echo "Wrong number of arguments" >&2
  usage
  exit 1
fi
ACTION="$1"

get_config() {
  local data=()
  if [ ! -f "${CONFIG}" ]; then
    echo "can't read ${CONFIG} file" >&2
    exit 4
  fi
  mapfile -t data < <("${BIN_DIR}/get_config.pl" "${CONFIG}")
  IP=${data[0]}
  PORT=${data[1]}
  MPORT=${data[2]}
  PEER_IP=${data[3]}
  PEER_PORT=${data[4]}
  PEER_MPORT=${data[5]}
  PHONE_CC=${data[6]}
  PHONE_AC=${data[7]}
  PHONE_SN=${data[8]}
}

update_network() {
  local data=()
  local scen=$1
  local ids=${scen}/scenario_ids.yml

  if [ ! -f "${ids}" ]; then
    echo "can't read ${ids}" >&2
    exit 3
  fi
  mapfile -d: -t data < <("${BIN_DIR}/provide_next_network.pl" "${ids}")
  PORT=${data[0]}
  MPORT=${data[1]}
  mapfile -d: -t data < <("${BIN_DIR}/provide_next_network.pl" -peer "${ids}")
  if [[ ${data[0]} -ne 1 ]]; then
    PEER_PORT=${data[0]}
  fi
  if [[ ${data[1]} -ne 2 ]]; then
    PEER_MPORT=${data[1]}
  fi

  mapfile -d: -t data < <("${BIN_DIR}/provide_next_phone.pl" "${ids}")
  PHONE_SN=${data[2]}
}

create() {
  local scen=${BASE_DIR}/${GROUP}/$1
  echo "*** $1 IP:${IP} PORT:${PORT} MPORT:${MPORT} ***"
  "${BIN_DIR}/provide_scenario.sh" \
    -i "${IP}" -p "${PORT}" -m "${MPORT}" \
    -n "${PHONE_CC}:${PHONE_AC}:${PHONE_SN}" \
    -I "${PEER_IP}" -P "${PEER_PORT}" -M "${PEER_MPORT}" \
    "${scen}" "${ACTION}"
  echo "*** done ***"
  update_network "${scen}"
}

delete() {
  local scen=${BASE_DIR}/${GROUP}/$1
  "${BIN_DIR}/provide_scenario.sh" "${scen}" "${ACTION}"
}

get_config
get_scenarios

case ${ACTION} in
  create) for t in "${SCEN[@]}"; do create "${t}"; done;;
  delete) for t in "${SCEN[@]}"; do delete "${t}"; done;;
  *) echo "action ${ACTION} unknown" >&2; exit 2 ;;
esac
echo "$(date) - Done"
