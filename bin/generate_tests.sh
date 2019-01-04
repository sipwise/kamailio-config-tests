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
BASE_DIR="${BASE_DIR:-/usr/share/kamailio-config-tests}"
DIR="${BASE_DIR}/scenarios"
BIN_DIR="${BASE_DIR}/bin"
DEST_DIR="${DEST_DIR}"

error_flag=0

function clean
{
  find "${BASE_DIR}/scenarios/" -type f -name '*test.yml'  -exec rm {} \;
}

function usage
{
  echo "Usage: generate_tests.sh [-h] [-c] [-d directory] scenario_ids.yml profile"
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
    d) DIR=${OPTARG};;
  esac
done
shift $((OPTIND - 1))
IDS="$1"
PROFILE="$2"

if [[ $# -ne 2 ]]; then
  echo "Wrong number or arguments"
  usage
  exit 1
fi

case ${PROFILE} in
  PRO) ARGS="-p" ;;
  CE)  ARGS="" ;;
  *)
    echo "PROFILE ${PROFILE} unknown"
    usage
    exit 2
esac

if [ ! -x "${BIN_DIR}/generate_test.pl" ]; then
  echo "Cannot exec ${BIN_DIR}/generate_test.pl"
  usage
  exit 3
fi

for t in $(find "${DIR}" -not -regex '.+customtt.tt2' -type f -name '*.tt2' | sort); do
  origdir="$(dirname "${t}")"
  template="$(basename "${t}")"
  if [ -n "${DEST_DIR}" ] ; then
    destdir="${DEST_DIR}/$(dirname "${t}")"
    mkdir -p "${destdir}"
  else
    destdir="$(dirname "${t}")"
  fi
  destfile="$(basename "${t}" .tt2)"
  custom_template="$(basename "${t}" .tt2).customtt.tt2"

  if [ -f "${origdir}/${custom_template}" ]; then
    echo "$(date) - - Custom detected"
    template=${custom_template}
  fi
  echo "$(date) - - Generating: ${destdir}/${destfile}"
  # shellcheck disable=SC2086
  if ! "${BIN_DIR}/generate_test.pl" ${ARGS} "${origdir}/${template}" ${IDS} > "${destdir}/${destfile}" ; then
    error_flag=1
  fi
done

exit ${error_flag}
#EOF
