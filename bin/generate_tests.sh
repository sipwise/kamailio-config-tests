#!/bin/bash
#
# Copyright: 2013 Sipwise Development Team <support@sipwise.com>
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
BASE_DIR="${BASE_DIR:-/usr/share/kamailio-config-tests}"
TPAGE="/usr/bin/tpage"
DIR="${BASE_DIR}/scenarios"
error_flag=0

function clean
{
  find "${BASE_DIR}/scenarios/" -type f -name '*test.yml'  -exec rm {} \;
}

function usage
{
  echo "Usage: generate_tests.sh [-h] [-c] [-d directory] profile"
  echo "Options:"
  echo -e "\tc: clean. Removes all generated test files"
  echo -e "\td: directory"
  echo -e "\th: this help"
  echo "Args:"
  echo -e "\tprofile: CE|PRO"
}

while getopts 'hcd:' opt; do
  case $opt in
    h) usage; exit 0;;
    c) clean; exit 0;;
    d) DIR=$OPTARG;;
  esac
done
shift $((OPTIND - 1))
PROFILE="$1"

if [[ $# -ne 1 ]]; then
  echo "Wrong number or arguments"
  usage
  exit 1
fi

if [ "${PROFILE}" == "CE" ]; then
  TPAGE_ARGS="--define CE=true"
elif [ "${PROFILE}" == "PRO" ]; then
  TPAGE_ARGS="--define PRO=true"
else
  echo "PROFILE ${PROFILE} unknown"
  usage
  exit 2
fi

if [ ! -x ${TPAGE} ]; then
  echo "Cannot exec ${TPAGE}"
  usage
  exit 3
fi

for t in $(find "${DIR}" -not -regex '.+customtt.tt2' -type f -name '*.tt2' | sort); do
  template="$(basename "$t")"
  destdir="$(dirname "$t")"
  destfile="$(basename "$t" .tt2)"
  custom_template="$(basename "$t" .tt2).customtt.tt2"

  if [ -f "${destdir}/${custom_template}" ]; then
    echo "Custom detected"
    template=${custom_template}
  fi
  echo "generating: ${destdir}/${destfile}"
  # shellcheck disable=SC2086
  "${TPAGE}" ${TPAGE_ARGS} "${destdir}/${template}" > "${destdir}/${destfile}"
  if [ $? -ne 0 ]; then
    error_flag=1
  fi
done

exit $error_flag
#EOF
