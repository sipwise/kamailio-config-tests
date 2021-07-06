#!/bin/bash
RUN_DIR="$(dirname "$0")"
export BASE_DIR=${BASE_DIR:-$RUN_DIR}
BIN_DIR="${BASE_DIR}/bin"
PROFILE="${PROFILE:-}"
GROUP="${GROUP:-scenarios}"
RETRANS=""
CDR=""
CHECK_TYPE=all

usage() {
  echo "Usage: get_results.sh [-hcgGr] [-f FILE] [-p PROFILE] [-x GROUP] [-S <all|cfgt|sipp>] [-R number]"
  echo -e "\\t-p CE|PRO default is autodetect"
  echo -e "\\t-g generate png flow graphs if test fails"
  echo -e "\\t-G generate png all flow graphs"
  echo -e "\\t-h this help"
  echo -e "\\t-r fix retransmission issues"
  echo -e "\\t-R choose how many messages before and after to check"
  echo -e "\\t-c enable cdr validation"
  echo -e "\\t-x set GROUP scenario. Default: scenarios"
  echo -e "\\t-f scenarios file"
  echo -e "\\t-S check type. Default: all (cfgt, sipp)"
  echo "BASE_DIR:${BASE_DIR}"
  echo "BIN_DIR:${BIN_DIR}"
}

get_scenarios() {
  if [ -n "${SCEN_FILE}" ]; then
    echo "$(date) - scenarios from file"
    while read -r t; do
      SCEN+=( "${t}" )
      echo -e "\\t* ${t}"
    done < "${SCEN_FILE}"
  else
    while read -r t; do
      SCEN+=( "${t}" )
    done < <("${BIN_DIR}/get_scenarios.sh" -p "${PROFILE}" -x "${GROUP}")
  fi
  if [[ ${#SCEN[@]} == 0 ]]; then
    echo "$(date) no scenarios found"
    exit 1
  fi
}

while getopts 'hf:gGp:rR:cx:S:' opt; do
  case $opt in
    h) usage; exit 0;;
    G) GRAPH="-G";;
    g) GRAPH="-g";;
    r) RETRANS="-r";;
    R) RETRANS="-r -w ${OPTARG}";;
    c) CDR="-c";;
    p) PROFILE=${OPTARG};;
    x) GROUP=${OPTARG};;
    f) SCEN_FILE=${OPTARG};;
    S) CHECK_TYPE=${OPTARG};;
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

check_old() {
  echo "$(date) - ================================================================================="
  echo "$(date) - ----- ${CHECK_TYPE} checks ----- "
  echo "${SCEN[@]}" |  tr ' ' '\n' \
     | parallel "${BIN_DIR}/check.sh ${GRAPH} -T${CHECK_TYPE} -C -R ${OPTS} ${RETRANS} ${CDR} -p ${PROFILE} -s ${GROUP}"
  status=$?
  echo "$(date) - All done[${status}]"
}

check_sipp() {
  echo "$(date) - ================================================================================="
  echo "$(date) - ---- sipp checks ----- "
  echo "${SCEN[@]}" |  tr ' ' '\n' \
     | parallel "${BIN_DIR}/check_sipp.sh -p ${PROFILE} -s ${GROUP}"
  status=$?
  echo "$(date) - All done[${status}]"
}

case "${CHECK_TYPE}" in
  all|cfgt) check_old;;
  sipp) check_sipp;;
  *) echo "unknown check type"; exit 1;;
esac

tap_cmd=()
for t in "${SCEN[@]}" ; do
  tap_check=$(find "result/${GROUP}/${t}" -name '*.tap' 2>/dev/null)
  if [ -n "${tap_check}" ]; then
    tap_cmd+=( "result/${GROUP}/${t}/"*tap )
  fi
done
prove -f -Q "${tap_cmd[@]}"|tee "result/${GROUP}/prove.log"
grep 'Failed:' "result/${GROUP}/prove.log"|awk -F/ '{print $3}'|uniq > "result/${GROUP}/result_failed.txt"
exit ${status}
