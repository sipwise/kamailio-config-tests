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
# shellcheck disable=SC2155
declare -r ME="$(basename "$0")"
BASE_DIR="${BASE_DIR:-/usr/share/kamailio-config-tests}"
BIN_DIR="${BASE_DIR}/bin"
if [ -z "${PERL5LIB}" ]; then
  # Set up the environment, to use local perl modules
  export PERL5LIB="${BASE_DIR}/lib"
fi
DOMAINS=()

get_domains() {
  while read -r t; do
    DOMAINS+=( "${t}" )
  done < <("${BIN_DIR}/get_domains.pl" "${SCEN_CHECK_DIR}/scenario.yml")
  if [[ ${#DOMAINS[@]} == 0 ]]; then
    echo "$(date) no domains found"
    exit 1
  fi
}

delete() {
  local DOMAIN=$1
  echo "$(date) - Deleting domain:${DOMAIN}"
  delete_voip "${DOMAIN}"
}

# $1 domain
create_voip() {
  if ! "${BIN_DIR}/create_subscribers.pl" \
    "${SCEN_CHECK_DIR}/scenario.yml" "${SCEN_CHECK_DIR}/scenario_ids.yml"
  then
    echo "$(date) - Cannot create domain subscribers"
    delete "$1"
    exit 1
  fi

  if [ -f "${SCEN_CHECK_DIR}/registration.yml" ]; then
    echo "$(date) - Creating permanent registrations"
    "${BIN_DIR}/create_registrations.pl" \
      -ids "${SCEN_CHECK_DIR}/scenario_ids.yml" \
      "${SCEN_CHECK_DIR}/registration.yml"
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
  fi

  if [ -f "${SCEN_CHECK_DIR}/lnp.yml" ]; then
    echo "$(date) - Creating lnp carrier/number"
    "${BIN_DIR}/create_lnp.pl" "${SCEN_CHECK_DIR}/lnp.yml"
  fi

  if [ -f "${SCEN_CHECK_DIR}/header.yml" ]; then
    echo "$(date) - Creating header manipulations"
    "${BIN_DIR}/create_header_manipulation.pl" "${SCEN_CHECK_DIR}/header.yml"
  fi

  if [ -f "${SCEN_CHECK_DIR}/prefs.json" ]; then
    echo "$(date) - Setting preferences"
    "${BIN_DIR}/set_preferences.pl" "${SCEN_CHECK_DIR}/prefs.json"
  fi
}

# $1 domain
delete_voip() {
  if [ -f "${SCEN_CHECK_DIR}/registration.yml" ]; then
    echo "$(date) - Deleting registrations"
    "${BIN_DIR}/create_registrations.pl" -delete "${SCEN_CHECK_DIR}/registration.yml"
  fi

  ngcp-delete-domain "$1" >/dev/null 2>&1

  if [ -f "${SCEN_CHECK_DIR}/peer.yml" ]; then
    echo "$(date) - Deleting peers"
    "${BIN_DIR}/create_peers.pl" -delete "${SCEN_CHECK_DIR}/peer.yml"
    # REMOVE ME!! fix for REST API
    ngcp-kamcmd proxy lcr.reload
  fi

  if [ -f "${SCEN_CHECK_DIR}/trusted.yml" ]; then
   echo "$(date) - Deleting trusted sources"
   # Trusted sources are not deleted from kamailio cache when the domain is removed
   # therefore better reload them from the database
   ngcp-kamcmd proxy permissions.trustedReload
  fi

  if [ -f "${SCEN_CHECK_DIR}/header.yml" ]; then
    echo "$(date) - Deleting header manipulations"
    "${BIN_DIR}/create_header_manipulation.pl" -delete "${SCEN_CHECK_DIR}/header.yml"
  fi

  if [ -f "${SCEN_CHECK_DIR}/lnp.yml" ]; then
    echo "$(date) - Deleting lnp carrier/number"
    "${BIN_DIR}/create_lnp.pl" -delete "${SCEN_CHECK_DIR}/lnp.yml"
    # REMOVE ME!! fix for REST API
    ngcp-kamcmd proxy lcr.reload
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

scenario_csv() {
  local DOMAIN=$1
  echo "$(date) - Cleaning csv/reg.xml files"
  find "${SCEN_CHECK_DIR}" -name 'sipp_scenario_responder*_reg.xml' -exec rm {} \;
  find "${SCEN_CHECK_DIR}" -name '*.csv' -exec rm {} \;
  echo "$(date) - Generating csv/reg.xml files"
  echo "IP=${IP} PORT=${PORT} MPORT=${MPORT}"
  echo "PEER_IP=${PEER_IP} PEER_PORT=${PEER_PORT} PEER_MPORT=${PEER_MPORT}"
  if ! "${BIN_DIR}/scenario.pl" \
    --ip="${IP}" --port="${PORT}" --mport="${MPORT}" --phone="${PHONE}" \
    --peer-ip="${PEER_IP}" --peer-port="${PEER_PORT}" --peer-mport="${PEER_MPORT}" \
    "${SCEN_CHECK_DIR}/scenario.yml" "${SCEN_CHECK_DIR}/scenario_ids.yml"
  then
    echo "Error creating csv files"
    exit 2
  fi

  if [ -f "${SCEN_CHECK_DIR}/hosts" ]; then
    echo "$(date) - Setting foreign domains"
    cat "${SCEN_CHECK_DIR}/hosts" >> /etc/hosts
  fi
}

create() {
  local DOMAIN=$1
  delete "${DOMAIN}" # just to be sure nothing is there
  scenario_csv "${DOMAIN}"
  echo "$(date) - Creating ${DOMAIN}"
  create_voip "${DOMAIN}"
  echo "$(date) - Adding prefs"
  create_voip_prefs
}

usage() {
  cat <<EOF
Usage: ${ME} [options] scenario_dir action

Options:
  -h: this help
  -i: IP
  -p: sipp port base
  -m: sipp multimedia port base
  -I: peer IP
  -P: sipp peer port base
  -M: sipp peer multimedia port base
  -n: phone base number(cc:ac:sn). Default: 43:1:1000
Arguments:
  scenario_dir
  action. 'create' or 'delete'
EOF
}

IP="127.126.0.1"
PORT=51602
MPORT=45003
PHONE=43:1:1000
PEER_IP="127.0.2.1"
PEER_PORT=51602
PEER_MPORT=45003
while getopts 'hi:p:m:I:P:M:n:' opt; do
  case $opt in
    i) IP=${OPTARG};;
    p) PORT=${OPTARG};;
    m) MPORT=${OPTARG};;
    I) PEER_IP=${OPTARG};;
    P) PEER_PORT=${OPTARG};;
    M) PEER_MPORT=${OPTARG};;
    n) PHONE=${OPTARG};;
    h) usage; exit 0;;
    *) usage; exit 1;;
  esac
done
shift $((OPTIND - 1))

if [[ $# != 2 ]]; then
  echo "Wrong number of arguments"
  usage
  exit 1
fi
SCEN_CHECK_DIR="$1"
ACTION="$2"

if ! [ -d "${SCEN_CHECK_DIR}" ]; then
  echo "scenario_dir:${SCEN_CHECK_DIR} found"
  usage
  exit 2
fi

get_domains

case ${ACTION} in
  create) for t in "${DOMAINS[@]}"; do create "${t}"; done;;
  delete) for t in "${DOMAINS[@]}"; do delete "${t}"; done;;
  *) echo "action ${ACTION} unknown"; exit 2 ;;
esac
echo "$(date) - Done"
