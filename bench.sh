#!/bin/bash
SKIP_CONFIG=false
PROFILE="${PROFILE:-}"
GROUP="${GROUP:-scenarios}"
CAPTURE=false
SINGLE_CAPTURE=false
PROV_TYPE=step

usage() {
  echo "Usage: bench.sh [-p PROFILE] [-C] [num_runs]"
  echo "Options:"
  echo -e "\\t-p CE|PRO default is autodetect"
  echo -e "\\t-C skips configuration of the environment"
  echo -e "\\t-k capture messages with tcpdump, per scenario"
  echo -e "\\t-K capture messages with tcpdump. One big file for all scenarios"
  echo -e "\\t-x set GROUP scenario. Default: scenarios"
  echo -e "\\t-P provisioning, default:step"
  echo -e "\\t-h this help"
  echo -e "num_runs default is 20"
}

while getopts 'hCkKP:p:x:' opt; do
  case $opt in
    h) usage; exit 0;;
    C) SKIP_CONFIG=true;;
    k) SINGLE_CAPTURE=true;;
    K) CAPTURE=true;;
    p) PROFILE=${OPTARG};;
    P) PROV_TYPE=${OPTARG};;
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

if ! "${SKIP_CONFIG}" ; then
  "${BASE_DIR}/set_config.sh" -x "${GROUP}" -p "${PROFILE}"
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
  ./get_results.sh -r -x"${GROUP}" | tee /tmp/get_results.log
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
  "${BASE_DIR}/set_config.sh" -c -x "${GROUP}" -p "${PROFILE}"
fi
