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
set -e
BASE_DIR="${BASE_DIR:-/usr/share/kamailio-config-tests}"
GROUP="${1:-}"

usage() {
  echo "Usage: failed_scenarios.sh GROUP"
  echo "Options:"
  echo -e "\\t-h this help"
}

while getopts 'h' opt; do
  case $opt in
    h) usage; exit 0;;
    *) usage; exit 1;;
  esac
done
shift $((OPTIND - 1))

if [[ $# -ne 1 ]]; then
  echo "Wrong number or arguments"
  usage
  exit 1
fi

rm -f "${BASE_DIR}/failed.txt"
if [ -f "${BASE_DIR}/result/${GROUP}/result_failed.txt" ]; then
  echo "$(date) - result_failed.txt detected"
  cp "${BASE_DIR}/result/${GROUP}/result_failed.txt" "${BASE_DIR}/failed.txt"
elif [ -f "${BASE_DIR}/log/${GROUP}/run_failed.txt" ]; then
  echo "$(date) - run_failed.txt detected"
  cp "${BASE_DIR}/log/${GROUP}/run_failed.txt" "${BASE_DIR}/failed.txt"
fi
if [ -f "${BASE_DIR}/failed.txt" ]; then
  echo "*** failed.txt ***"
  cat "${BASE_DIR}/failed.txt"
else
  echo "$(date) - no failed scenarios found[${GROUP}]"
  exit 1
fi
echo "$(date) - Done[${GROUP}]"
