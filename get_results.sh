#!/bin/bash
RUN_DIR="$(dirname "$0")"
export BASE_DIR=${BASE_DIR:-$RUN_DIR}
BIN_DIR="${BASE_DIR}/bin"
PROFILE="${PROFILE:-CE}"
DOMAIN="spce.test"
GROUP="${GROUP:-scenarios}"
RETRANS=""
CDR=""

usage() {
  echo "Usage: get_results.sh [-p PROFILE] [-h] [-g]"
  echo "-p CE|PRO default is CE"
  echo "-g generate png flow graphs if test fails"
  echo "-G generate png all flow graphs"
  echo "-h this help"
  echo "-P parse only will disable test"
  echo "-T test only will disable parse"
  echo "-r fix retransmission issues"
  echo "-c enable cdr validation"
  echo "-x set GROUP scenario. Default: scenarios"
  echo "BASE_DIR:${BASE_DIR}"
  echo "BIN_DIR:${BIN_DIR}"
}

get_scenarios() {
  local t
  local flag
  flag=0
  if [ -n "${SCENARIOS}" ]; then
    for t in ${SCENARIOS}; do
      if [ ! -d "${BASE_DIR}/${GROUP}/${t}" ]; then
        echo "$(date) - scenario: $t not found"
        flag=1
      fi
    done
    if [ $flag != 0 ]; then
      exit 1
    fi
  else
    SCENARIOS=$(find "${BASE_DIR}/${GROUP}/" -depth -maxdepth 1 -mindepth 1 \
      -type d -exec basename {} \; | grep -v templates | sort)
  fi
}

while getopts 'hgGp:TPrcx:' opt; do
  case $opt in
    h) usage; exit 0;;
    G) GRAPH="-G";;
    g) GRAPH="-g";;
    P) OPTS="-T";;
    T) OPTS="-P";;
    r) RETRANS="-r";;
    c) CDR="-c";;
    p) PROFILE=${OPTARG};;
    x) GROUP=${OPTARG};;
    *) usage; exit 1;;
  esac
done
shift $((OPTIND-1))

if [[ $# -ne 0 ]]; then
  echo "Wrong number or arguments"
  usage
  exit 1
fi

ngcp_type=$(command -v ngcp-type)
if [ -n "${ngcp_type}" ]; then
  case $(${ngcp_type}) in
    sppro|carrier) PROFILE=PRO;;
    ce) PROFILE=CE;;
    *) ;;
  esac
  echo "ngcp-type: profile ${PROFILE}"
fi
if [ "${PROFILE}" != "CE" ] && [ "${PROFILE}" != "PRO" ]; then
  echo "PROFILE ${PROFILE} unknown"
  usage
  exit 2
fi

get_scenarios

echo "${SCENARIOS}" |  tr ' ' '\n' \
 | parallel "${BIN_DIR}/check.sh ${GRAPH} -C -R ${OPTS} ${RETRANS} ${CDR} -d ${DOMAIN} -p ${PROFILE} -s ${GROUP}"
status=$?
echo "$(date) - All done[${status}]"
exit ${status}
