#!/bin/bash
#
# Copyright: 2013-2022 Sipwise Development Team <support@sipwise.com>
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
RUN_DIR="$(dirname "$0")"
export BASE_DIR=${BASE_DIR:-$RUN_DIR}
# Set up the environment, to use local perl modules
export PERL5LIB="${BASE_DIR}/lib"
BIN_DIR="${BASE_DIR}/bin"
GROUP="${GROUP:-scenarios}"
PROFILE="${PROFILE:-}"
CLEAN=false
TIMEOUT=${TIMEOUT:-300}
SKIP_NET=false
CFGT=false

usage() {
  echo "Usage: set_config.sh [-cht] [-x GROUP] [-p PROFILE]"
  echo "Options:"
  echo -e "\\t-p CE|PRO default is autodetect"
  echo -e "\t-x set GROUP scenario. Default: scenarios"
  echo -e "\\t-c clean config"
  echo -e "\\t-t set timeout in secs for pid_watcher.py [PRO]. Default: 300"
  echo -e "\\t-s skip network IP detection, just use values at config.yml"
  echo -e "\\t-T enable cfgt"
  echo -e "\t-h this help"

  echo "BASE_DIR:${BASE_DIR}"
  echo "BIN_DIR:${BIN_DIR}"
}

while getopts 'chp:sTt:x:' opt; do
  case $opt in
    c) CLEAN=true;;
    h) usage; exit 0;;
    p) PROFILE=${OPTARG};;
    s) SKIP_NET=true;;
    t) TIMEOUT=${OPTARG};;
    x) GROUP=${OPTARG};;
    T) CFGT=true;;
    *) echo "Unknown option ${opt}"; usage; exit 1;;
  esac
done
shift $((OPTIND - 1))

if [ -z "${PROFILE}" ]; then
  ngcp_type=$(command -v ngcp-type)
  if [ -n "${ngcp_type}" ]; then
    case $(${ngcp_type}) in
      sppro|carrier) PROFILE=PRO;;
      spce) PROFILE=CE;;
      *) ;;
    esac
    echo "ngcp-type: profile ${PROFILE}"
  fi
fi
if [ "${PROFILE}" != "CE" ] && [ "${PROFILE}" != "PRO" ]; then
  echo "PROFILE ${PROFILE} unknown"
  usage
  exit 2
fi

if [ "${GROUP}" = "scenarios_pbx" ] ; then
  PIDWATCH_OPTS=('--pbx')
  # hack for pid_watcher ( sems-pbx was not active )
  mkdir -p /run/sems-pbx/
  touch /run/sems-pbx/sems-pbx.pid
  chown -R sems-pbx:sems-pbx /run/sems-pbx/
else
  PIDWATCH_OPTS=()
fi

error_flag=0

dummy_up() {
  local dummy_ip
  dummy_ip=$(ip addr show "dummy$1" | grep inet | awk '{print $2}' | head -1)
  if [ -z "${dummy_ip}" ]; then
    echo "$(date) - start dummy$1 interface"
    ifup "dummy$1"
  fi
}

dummy_down() {
  local dummy_ip
  dummy_ip=$(ip addr show "dummy$1" | grep inet | awk '{print $2}' | head -1)
  if [ -n "${dummy_ip}" ]; then
    echo "$(date) - stop dummy$1 interface"
    ifdown "dummy$1"
  fi
}

dummy_add() {
  if ! lsmod | grep -q dummy ; then
    echo "$(date) - add dummy module"
    modprobe dummy numdummies=2
  fi
}

dummy_remove() {
  if lsmod | grep -q dummy ; then
    echo "$(date) - remove dummy module"
    rmmod dummy
  fi
}

clean() {
  echo "$(date) - Removed apicert.pem"
  rm -f "${BASE_DIR}/apicert.pem"
  echo "$(date) - Setting config debug off"
  "${BIN_DIR}/config_debug.pl" -g "${GROUP}" "${BASE_DIR}/config.yml" off
  echo "$(date) - Setting network config off"
  "${BIN_DIR}/network_config.pl" -g "${GROUP}" "${BASE_DIR}/config.yml" off
  dummy_down 0|| error_flag=5
  dummy_down 1|| error_flag=5
  dummy_remove|| error_flag=5
  if ! ngcpcfg --summary-only apply "config debug off via kamailio-config-tests" ; then
    echo "$(date) - ngcpcfg apply returned $?"
    error_flag=4
  fi
  echo "$(date) - Setting config[${GROUP}] debug off. Done[${error_flag}]"
}

config() {
  local opts

  echo "$(date) - Removed apicert.pem"
  rm -f "${BASE_DIR}/apicert.pem"
  if ${SKIP_NET} ; then
    echo "$(date) - Use network IPs, from config.yml"
  else
    echo "$(date) - Guess network IPs"
    "${BIN_DIR}/detect_network.py" --verbose "${BASE_DIR}/config.yml" /etc/ngcp-config/network.yml
  fi
  opts="-c 5 -g ${GROUP}"
  if ${CFGT} ; then
    opts+=" -t"
  fi
  echo "$(date) - Setting config debug on"
  # shellcheck disable=SC2086
  "${BIN_DIR}/config_debug.pl" ${opts} "${BASE_DIR}/config.yml" on
  echo "$(date) - Setting network config"
  "${BIN_DIR}/network_config.pl" -g "${GROUP}" "${BASE_DIR}/config.yml" on
  if [ "${PROFILE}" == "PRO" ]; then
    mkdir -p "${BASE_DIR}/log"
    echo "$(date) - Exec pid_watcher with timeout[${TIMEOUT}]"
    # shellcheck disable=SC2086
    ( timeout "${TIMEOUT}" "${BIN_DIR}/pid_watcher.py" ${PIDWATCH_OPTS[*]} )&
  fi
  echo "$(date) - Config files"
  "${BIN_DIR}/config_files.sh" "${GROUP}"
  (
    cd /etc/ngcp-config || exit 3
    if ! ngcpcfg --summary-only apply "config debug on via kamailio-config-tests" ; then
      echo "$(date) - ngcpcfg apply returned $?"
      clean
      exit 4
    fi
  )
  dummy_add || error_flag=5
  dummy_up 0|| error_flag=5
  dummy_up 1|| error_flag=5

  if [ "${PROFILE}" == "PRO" ]; then
    echo "$(date) - waiting for pid_watcher[$!] result"
    if ! wait "$!" ; then
      echo "$(date) - error on apply config. Some expected service didn't restart"
      echo "$(date) - check log/pid_watcher.log for details"
      clean
      error_flag=1
    fi
  fi
  echo "$(date) - Setting config[${GROUP}] debug on. Done[${error_flag}]"
}

if ${CLEAN} ; then
  clean
else
  config
fi

exit ${error_flag}
