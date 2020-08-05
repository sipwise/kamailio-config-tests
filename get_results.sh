#!/bin/bash
RUN_DIR="$(dirname "$0")"
export BASE_DIR=${BASE_DIR:-$RUN_DIR}
BIN_DIR="${BASE_DIR}/bin"
PROFILE="${PROFILE:-}"
DOMAIN="spce.test"
GROUP="${GROUP:-scenarios}"
RETRANS=""
CDR=""

usage() {
  echo "Usage: get_results.sh [-p PROFILE] [-h] [-g]"
  echo -e "\\t-p CE|PRO default is autodetect"
  echo -e "\\t-g generate png flow graphs if test fails"
  echo -e "\\t-G generate png all flow graphs"
  echo -e "\\t-h this help"
  echo -e "\\t-P parse only will disable test"
  echo -e "\\t-T test only will disable parse"
  echo -e "\\t-r fix retransmission issues"
  echo -e "\\t-c enable cdr validation"
  echo -e "\\t-x set GROUP scenario. Default: scenarios"
  echo "BASE_DIR:${BASE_DIR}"
  echo "BIN_DIR:${BIN_DIR}"
}

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
        echo "$(date) - scenario: ${t}/scenario.yml at ${GROUP} not found"
        flag=true
      else
        filter_scenario "${t}" && SCEN+=( "${t}" )
      fi
    done
    ${flag} && exit 1
  else
    while read -r t; do
      t=$(basename "${t}")
      filter_scenario "${t}" && SCEN+=( "${t}" )
    done < <(find "${BASE_DIR}/${GROUP}/" -name scenario.yml \
      -type f -exec dirname {} \; | sort)
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

get_scenarios

echo "${SCEN[@]}" |  tr ' ' '\n' \
 | parallel "${BIN_DIR}/check.sh ${GRAPH} -C -R ${OPTS} ${RETRANS} ${CDR} -d ${DOMAIN} -p ${PROFILE} -s ${GROUP}"
status=$?
echo "$(date) - All done[${status}]"
tap_cmd=()
for t in "${SCEN[@]}" ; do
  tap_cmd+=( "result/${GROUP}/${t}/"*tap )
done
prove -f -Q "${tap_cmd[@]}"
exit ${status}
