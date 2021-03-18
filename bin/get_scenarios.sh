#!/bin/bash
#
# Copyright: 2021 Sipwise Development Team <support@sipwise.com>
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
GROUP="${GROUP:-scenarios}"
BASE_DIR="${BASE_DIR:-/usr/share/kamailio-config-tests}"
PROFILE="${PROFILE:-}"

usage() {
  echo "Usage: $0 [-h] [-x GROUP]"
  echo "Options:"
  echo -e "\\t-p CE|PRO default is autodetect"
  echo -e "\\t-x set GROUP scenario. Default: scenarios"
  echo -e "\\t-h this help"
}

while getopts 'hp:x:' opt; do
  case $opt in
    h) usage; exit 0;;
    p) PROFILE=${OPTARG};;
    x) GROUP=${OPTARG};;
    *) usage; exit 1;;
  esac
done
shift $((OPTIND - 1))

if [[ $# -ne 0 ]]; then
  echo "Wrong number or arguments"
  usage
  exit 1
fi

if [ -z "${PROFILE}" ] ; then
  ngcp_type=$(command -v ngcp-type)
  if [ -n "${ngcp_type}" ]; then
    case $(${ngcp_type}) in
      sppro|carrier) PROFILE=PRO;;
      spce) PROFILE=CE;;
      *) ;;
    esac
  fi
fi
if [ "${PROFILE}" != "CE" ] && [ "${PROFILE}" != "PRO" ]; then
  echo "PROFILE ${PROFILE} unknown"
  usage
  exit 2
fi

filter_scenario() {
  # filter out PRO only scenarios on CE
  local scen=$1

  if [ "${PROFILE}" == CE ] ; then
    [ -f "${BASE_DIR}/${GROUP}/${scen}/pro.yml" ] && return 1
  fi
  return 0
}

get_scenarios() {
  local t
  local flag
  flag=false

  if [ -n "${SCENARIOS}" ]; then
    for t in ${SCENARIOS}; do
      if [ ! -f "${BASE_DIR}/${GROUP}/${t}/scenario.yml" ]; then
        flag=true
      else
        filter_scenario "${t}" && echo "${t}"
      fi
    done
    ${flag} && exit 1
  else
    while read -r t; do
      t=$(basename "${t}")
      filter_scenario "${t}" && echo "${t}"
    done < <(find "${BASE_DIR}/${GROUP}/" -name scenario.yml \
      -type f -exec dirname {} \; | sort)
  fi
}

get_scenarios
exit 0