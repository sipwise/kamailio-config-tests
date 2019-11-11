#!/bin/bash
RUN_DIR="$(dirname "$0")"
export BASE_DIR=${BASE_DIR:-$RUN_DIR}
# Set up the environment, to use local perl modules
export PERL5LIB="${BASE_DIR}/lib"
BIN_DIR="${BASE_DIR}/bin"
GROUP="${GROUP:-xmpp}"
PROFILE="CE"
OPTS=(-D)
DOMAIN="spce.test"
TIMEOUT=${TIMEOUT:-300}
SHOW_SCENARIOS=false
SKIP_CONFIG=false
error_flag=0

get_scenarios() {
  local t
  local flag
  flag=0
  if [ -n "${SCENARIOS}" ]; then
    for t in ${SCENARIOS}; do
      if [ ! -d "${BASE_DIR}/${GROUP}/${t}" ]; then
        echo "$(date) - scenario: $t at ${GROUP} not found"
        flag=1
      fi
    done
    if [ ${flag} != 0 ]; then
      exit 1
    fi
  else
    SCENARIOS=$(find "${BASE_DIR}/${GROUP}/" -depth -maxdepth 1 -mindepth 1 \
      -type d -exec basename {} \; | grep -v templates | sort)
  fi
}

cfg_debug_off() {
  if ! "${SKIP_CONFIG}" ; then
    echo "$(date) - Removed apicert.pem"
    rm -f "${BASE_DIR}/apicert.pem"
    echo "$(date) - Setting config debug off"
    "${BIN_DIR}/config_debug.pl" -g "${GROUP}" off ${DOMAIN}
    if ! ngcpcfg apply "config debug off via kamailio-config-tests" ; then
      echo "$(date) - ngcpcfg apply returned $?"
      error_flag=4
    fi
    echo "$(date) - Setting config debug off. Done[${error_flag}]"
  fi
}


usage() {
  echo "Usage: run_xmpp_test.sh [-p PROFILE] [-C] [-t]"
  echo "Options:"
  echo -e "\\t-p CE|PRO default is CE"
  echo -e "\\t-l print available SCENARIOS in GROUP"
  echo -e "\\t-C skips configuration of the environment"
  echo -e "\\t-t set timeout in secs for pid_watcher.py [PRO]. Default: 300"
  echo -e "\\t-h this help"

  echo "BASE_DIR:${BASE_DIR}"
  echo "BIN_DIR:${BIN_DIR}"
}

while getopts 'hlCp:t:' opt; do
  case $opt in
    h) usage; exit 0;;
    l) SHOW_SCENARIOS=true;;
    C) SKIP_CONFIG=true;;
    p) PROFILE=${OPTARG};;
    t) TIMEOUT=${OPTARG};;
    *) echo "unknown option ${opt}"; exit 1;;
  esac
done
shift $((OPTIND - 1))

if [[ $# -ne 0 ]]; then
  echo "Wrong number or arguments"
  usage
  exit 1
fi

if "${SHOW_SCENARIOS}"  ; then
  get_scenarios
  echo "${SCENARIOS}"
  exit 0
fi

if [ "${PROFILE}" != "CE" ] && [ "${PROFILE}" != "PRO" ]; then
  echo "PROFILE ${PROFILE} unknown"
  usage
  exit 2
fi

if ! "${SKIP_CONFIG}" ; then
  echo "$(date) - Setting config debug on"
  "${BIN_DIR}/config_debug.pl" -g "${GROUP}" on ${DOMAIN}
  if ! ngcpcfg apply "config debug on via kamailio-config-tests" ; then
    echo "$(date) - ngcp apply returned $?"
    echo "$(date) - Done[3]"
    cfg_debug_off
    exit 3
  fi
  echo "$(date) - Setting config debug on. Done[${error_flag}]."
fi

get_scenarios

for t in ${SCENARIOS}; do
  echo "$(date) - ================================================================================="
  echo "$(date) - Run [${GROUP}/${PROFILE}]: ${t}"

  if ! "${BIN_DIR}/check_xmpp.sh" "${OPTS[@]}" -d "${DOMAIN}" -p "${PROFILE}" "${t}" ; then
    echo "ERROR: ${t}"
    error_flag=1
  fi

  echo "$(date) - ================================================================================="
done

cfg_debug_off

echo "$(date) - Done[${error_flag}]"
exit ${error_flag}
