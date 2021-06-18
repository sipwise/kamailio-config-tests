#!/bin/bash
set -e
RUN_DIR="$(dirname "$0")"
export BASE_DIR=${BASE_DIR:-$RUN_DIR}
# Set up the environment, to use local perl modules
export PERL5LIB="${BASE_DIR}/lib"
BIN_DIR="${BASE_DIR}/bin"
GROUP="${GROUP:-scenarios}"
PROFILE="${PROFILE:-}"
CLEAN=false
TIMEOUT=${TIMEOUT:-300}

usage() {
  echo "Usage: set_config.sh [-cht] [-x GROUP] [-p PROFILE]"
  echo "Options:"
  echo -e "\\t-p CE|PRO default is autodetect"
  echo -e "\t-x set GROUP scenario. Default: scenarios"
  echo -e "\\t-c clean config"
  echo -e "\\t-t set timeout in secs for pid_watcher.py [PRO]. Default: 300"
  echo -e "\t-h this help"

  echo "BASE_DIR:${BASE_DIR}"
  echo "BIN_DIR:${BIN_DIR}"
}

while getopts 'chp:t:x:' opt; do
  case $opt in
    c) CLEAN=true;;
    h) usage; exit 0;;
    p) PROFILE=${OPTARG};;
    t) TIMEOUT=${OPTARG};;
    x) GROUP=${OPTARG};;
    *) echo "Unknown option ${opt}"; usage; exit 1;;
  esac
done
shift $((OPTIND - 1))

if [ -z "${PROFILE}" ]; then
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

if [ "${GROUP}" = "scenarios_pbx" ] ; then
  PIDWATCH_OPTS=('--pbx')
  # hack for pid_watcher ( sems-pbx was not active )
  mkdir -p /run/sems-pbx/
  touch /run/sems-pbx/sems-pbx.pid
  chown -R sems-pbx:sems-pbx /run/sems-pbx/
else
  PIDWATCH_OPTS=()
fi

error_flag=0

clean() {
  echo "$(date) - Removed apicert.pem"
  rm -f "${BASE_DIR}/apicert.pem"
  echo "$(date) - Setting config debug off"
  "${BIN_DIR}/config_debug.pl" -g "${GROUP}" "${BASE_DIR}/config.yml" off
  echo "$(date) - Setting network config off"
  "${BIN_DIR}/network_config.pl" -g "${GROUP}" "${BASE_DIR}/config.yml" off
  dummy_ip=$(ip addr show dummy0 | grep inet | awk '{print $2}' | head -1)
  if [ -n "${dummy_ip}" ]; then
    echo "$(date) - stop dummy0 interface"
    ifdown dummy0
  fi
  if lsmod | grep -q dummy ; then
    echo "$(date) - remove dummy module"
    rmmod dummy
  fi
  if ! ngcpcfg --summary-only apply "config debug off via kamailio-config-tests" ; then
    echo "$(date) - ngcpcfg apply returned $?"
    error_flag=4
  fi
  echo "$(date) - Setting config[${GROUP}] debug off. Done[${error_flag}]"
}

config() {
  echo "$(date) - Removed apicert.pem"
  rm -f "${BASE_DIR}/apicert.pem"
  echo "$(date) - Setting config debug on"
  "${BIN_DIR}/config_debug.pl" -c 5 -g "${GROUP}" "${BASE_DIR}/config.yml" on
  echo "$(date) - Setting network config"
  "${BIN_DIR}/network_config.pl" -g "${GROUP}" "${BASE_DIR}/config.yml" on
  if [ "${PROFILE}" == "PRO" ]; then
    echo "$(date) - Exec pid_watcher with timeout[${TIMEOUT}]"
    # shellcheck disable=SC2086
    ( timeout "${TIMEOUT}" "${BIN_DIR}/pid_watcher.py" ${PIDWATCH_OPTS[*]} )&
  fi
  echo "$(date) - Config files"
  "${BIN_DIR}/config_files.sh" "${GROUP}"
  cd /etc/ngcp-config || exit 3
  if ! ngcpcfg --summary-only apply "config debug on via kamailio-config-tests" ; then
    echo "$(date) - ngcpcfg apply returned $?"
    clean
    error_flag=4
  fi
  if ! lsmod | grep -q dummy ; then
    echo "$(date) - add dummy module"
    modprobe dummy
  fi
  dummy_ip=$(ip addr show dummy0 | grep inet | awk '{print $2}' | head -1)
  if [ -z "${dummy_ip}" ]; then
    echo "$(date) - start dummy0 interface"
    ifup dummy0
  fi

  if [ "${PROFILE}" == "PRO" ]; then
    echo "$(date) - waiting for pid_watcher[$!] result"
    if ! wait "$!" ; then
      echo "$(date) - error on apply config. Some expected service didn't restart"
      echo "$(date) - check log/pid_watcher.log for details"
      clean
      error_flag=1
    fi
  fi
  echo "$(date) - Setting config[${GROUP}] debug on. Done[${error_flag}]"
}

if ${CLEAN} ; then
  clean
else
  config
fi

exit ${error_flag}
