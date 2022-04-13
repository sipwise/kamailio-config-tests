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
SKIP_CONFIG=false
PROFILE="${PROFILE:-}"
GROUP="${GROUP:-scenarios}"
CAPTURE=false
SINGLE_CAPTURE=false
PROV_TYPE=step
CHECK_TYPE=sipp
CFGT_OPTS=()

usage() {
  echo "Usage: bench.sh [-hCkK] [-p PROFILE] [-x GROUP] [-P <none|all|step>] [-S <all|cfgt|sipp>] num_runs"
  echo "Options:"
  echo -e "\\t-p CE|PRO default is autodetect"
  echo -e "\\t-C skips configuration of the environment"
  echo -e "\\t-k capture messages with tcpdump, per scenario"
  echo -e "\\t-K capture messages with tcpdump. One big file for all scenarios"
  echo -e "\\t-x set GROUP scenario. Default: scenarios"
  echo -e "\\t-P provisioning, default:step"
  echo -e "\\t-S check type. Default: sipp (all|cfgt|sipp)"
  echo -e "\\t-h this help"
  echo -e "num_runs default is 20"
}

while getopts 'hCkKP:p:S:x:' opt; do
  case $opt in
    h) usage; exit 0;;
    C) SKIP_CONFIG=true;;
    k) SINGLE_CAPTURE=true;;
    K) CAPTURE=true;;
    p) PROFILE=${OPTARG};;
    P) PROV_TYPE=${OPTARG};;
    S) CHECK_TYPE=${OPTARG};;
    x) GROUP=${OPTARG};;
	*) echo "Unknown option $opt"; usage; exit 1;;
  esac
done
shift $((OPTIND - 1))

if [ -z "${PROFILE}" ] ; then
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

case "${PROV_TYPE}" in
  full|step|none) ;;
  *) echo "provisioning type:${PROV_TYPE} unknown" >&2; exit 2
esac

NUM=${1:-20}
RUN_OPS=(-C -c -r -p"${PROFILE}" -x"${GROUP}" -P"${PROV_TYPE}")

if "${CAPTURE}" ; then
  RUN_OPS+=(-K)
elif "${SINGLE_CAPTURE}" ; then
  RUN_OPS+=(-k)
fi

# clean previous
rm -rf log_* result_*

BASE_DIR=$(pwd)
export BASE_DIR

case "${CHECK_TYPE}" in
  all|cfgt) CFG_OPTS+=(-T); RUN_OPS+=(-T) ;;
  sipp) ;;
  *) echo "check type:${CHECK_TYPE} unknown" >&2; exit 2;;
esac

if ! "${SKIP_CONFIG}" ; then
  CFG_OPTS+=(-x "${GROUP}" -p "${PROFILE}")
  # shellcheck disable=SC2086
  "${BASE_DIR}/set_config.sh" ${CFG_OPTS[*]}
fi

echo "$(date) - Starting $NUM tests"
set -o pipefail
for i in $(seq "$NUM"); do
  ./run_tests.sh "${RUN_OPS[@]}" | tee /tmp/run_tests.log
  status=$?
  if [[ $status -ne 0 ]]; then
  	echo "$(date) - ERROR[$status] run_tests $i"
  	break
  fi
  ./get_results.sh -S"${CHECK_TYPE}" -r -c -x"${GROUP}" | tee /tmp/get_results.log
  status=$?
  if [[ $status -ne 0 ]]; then
  	echo "$(date) - ERROR[$status] get_results $i"
  	break
  fi
  echo "$(date) - $i done ok"
  # keep everything
  mv log "log_$i"
  mv result "result_$i"
done
set +o pipefail

if ! "${SKIP_CONFIG}" ; then
  # shellcheck disable=SC2086
  "${BASE_DIR}/set_config.sh" -c ${CFG_OPTS[*]}
fi
