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
BASE_DIR="${BASE_DIR:-/usr/share/kamailio-config-tests}"
BIN_DIR="${BASE_DIR}/bin"
DEST_DIR="${DEST_DIR}"
GROUP="${GROUP:-scenarios}"

function usage
{
  echo "Usage: generate_tests_tt2.sh [-h] [-x GROUP] scenario [id1] [id2]"
  echo "Options:"
  echo -e "\\tx: group of scenarios. Default: scenarios"
  echo -e "\\th: this help"
  echo "Args:"
  echo -e "\\tscenario: name of the scenario in GROUP"
  echo -e "\\tid: of the json file and test file to be produced. This is optional,"
  echo -e "\\t   if no ids, all json files in log dir will be used."
  echo -e "\\t   More than one id can be used. No need to pass leading zeros."
  echo
  echo "Examples:"
  echo -e "\\t\$ generate_tests_tt2.sh -x scenarios_pbx invite"
  echo -e "\\t\$ generate_tests_tt2.sh incoming 1 7 12"
}

while getopts 'hx:' opt; do
  case $opt in
    h) usage; exit 0;;
    x) GROUP=${OPTARG};;
    *) usage; exit 1;;
  esac
done
shift $((OPTIND - 1))
SCEN="$1"

if [[ $# -lt 1 ]]; then
  echo "Wrong number or arguments" >&2
  usage
  exit 1
fi

SCEN_DIR="${BASE_DIR}/${GROUP}/${SCEN}"
LOG_DIR="${BASE_DIR}/log/${GROUP}/${SCEN}"
if [ ! -d  "${SCEN_DIR}" ] ; then
	echo "${SCEN_DIR} not found" >&2
	exit 2
elif [ ! -f "${SCEN_DIR}/scenario.yml" ] ; then
	echo "${SCEN_DIR}/scenario.yml not found" >&2
	exit 2
fi
if [ ! -d  "${LOG_DIR}" ] ; then
	echo "${LOG_DIR} not found" >&2
	exit 2
elif [ ! -f "${LOG_DIR}/scenario_ids.yml" ] ; then
	echo "${LOG_DIR}/scenario_ids.yml not found" >&2
	exit 2
fi

if [ ! -x "${BIN_DIR}/generate_test_tt2.pl" ]; then
  echo "Cannot exec ${BIN_DIR}/generate_test_tt2.pl" >&2
  usage
  exit 3
fi
if [[ $# -eq 1 ]]; then
	mapfile -t IDS < <(find "${LOG_DIR}" -maxdepth 1 -name '*.json' -exec basename {} \;| sort)
else
	shift 1
	IDS=()
	for t in "${@}"; do
		file=$(printf "%04d.json" "${t}")
		if [ ! -f "${LOG_DIR}/${file}" ]; then
			echo "${LOG_DIR}/${file} not found" >&2
			exit 4
		fi
		IDS+=( "${file}" )
	done
fi
CMD="${BIN_DIR}/generate_test_tt2.pl -F -i ${LOG_DIR}/scenario_ids.yml"
CMD+=" -n ${SCEN_DIR}/scenario.yml "
for t in "${IDS[@]}" ; do
	file="${SCEN_DIR}/$(basename "${t}" .json)"_test.yml.tt2
	echo "generating: ${file}"
	${CMD} "${LOG_DIR}/${t}" > "${file}"
done
