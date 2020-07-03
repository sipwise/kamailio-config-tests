#!/bin/bash
SKIP_CONFIG=false
PROFILE="${PROFILE:-CE}"
GROUP="${GROUP:-scenarios}"

usage() {
  echo "Usage: bench.sh [-p PROFILE] [-C] [num_runs]"
  echo "Options:"
  echo -e "\t-p CE|PRO default is CE"
  echo -e "\t-C skips configuration of the environment"
  echo -e "\t-x set GROUP scenario. Default: scenarios"
  echo -e "\t-h this help"
  echo -e "num_runs default is 20"
}

while getopts 'hCp:x:' opt; do
  case $opt in
    h) usage; exit 0;;
    C) SKIP_CONFIG=true;;
    p) PROFILE=${OPTARG};;
    x) GROUP=${OPTARG};;
	*) echo "Unknown option $opt"; usage; exit 1;;
  esac
done
shift $((OPTIND - 1))

if [ "${PROFILE}" != "CE" ] && [ "${PROFILE}" != "PRO" ]; then
  echo "PROFILE ${PROFILE} unknown"
  usage
  exit 2
fi

NUM=${1:-20}
RUN_OPS=(-C -c -r -p"${PROFILE}" -x"${GROUP}")

# clean previous
rm -rf log_* result_*

BASE_DIR=$(pwd)
export BASE_DIR

if ! "${SKIP_CONFIG}" ; then
	export PERL5LIB="${BASE_DIR}/lib"
	echo "add configuration for tests"
	./bin/config_debug.pl -g "${GROUP}" on
	(
    cd /etc/ngcp-config || true
    ngcpcfg apply "k-c-t ${GROUP} on"
  )
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
	echo "remove configuration for tests"
	./bin/config_debug.pl -g"${GROUP}" off
	(
    cd /etc/ngcp-config || true
    ngcpcfg apply "k-c-t ${GROUP} off"
  )
fi