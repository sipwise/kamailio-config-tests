#!/bin/bash
#
# Copyright: 2020 Sipwise Development Team <support@sipwise.com>
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
BIN_DIR=$(dirname "$0")
die()
{
  echo "ERROR: $1" >&2
  exit "${2:-1}"
}

log_info()
{
  echo "INFO: $*"
}

usage() {
  echo "Usage: ${0} [-h] [-g GROUP] fileA.json fileB.json route_name"
  echo "Options:"
  echo -e "\t-g variable group. For instance: 'var'"
  echo -e "\t-h this help"
}

while getopts 'hg:' opt; do
  case $opt in
    h) usage; exit 0;;
    g) GROUP="-g $OPTARG";;
    *) exit 1
  esac
done
shift $((OPTIND - 1))

fileA=$(mktemp)
fileB=$(mktemp)
if [ -n "${GROUP}" ]; then
  CMD="${BIN_DIR}/show_route.pl ${GROUP}"
else
  CMD="${BIN_DIR}"/show_route.pl
fi
${CMD} "${1}" "${3}" > "${fileA}" || exit 1
${CMD} "${2}" "${3}" > "${fileB}" || exit 1
diff -uN "${fileA}" "${fileB}"
res=$?
rm -f "${fileA}" "${fileB}"
exit $res
