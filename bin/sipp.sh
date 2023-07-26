#!/bin/bash
#
# Copyright: 2013-2020 Sipwise Development Team <support@sipwise.com>
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
usage() {
  echo "Usage: sipp.sh [-p PORT] [-m MPORT] [-t TIMEOUT] [-r] [-T TRANSPORT] [-L LOGTYPE] scenario.xml"
  echo "Options:"
  echo -e "\\t-p: sip port. default 50602/50603(responder)"
  echo -e "\\t-m: media port"
  echo -e "\\t-t: timeout. default 10/25(responder)"
  echo -e "\\t-i: IP. default 127.0.0.1"
  echo -e "\\t-I: SIP_SERVER IP. default 127.0.0.1"
  echo -e "\\t-T: transport [UDP|TCP] default UDP"
  echo -e "\\t-r: responder"
  echo -e "\\t-b: run sipp in background (responder)"
  echo -e "\\t-l: log_message_file"
  echo -e "\\t-e: err_file"
  echo -e "\\t-L [caller|responder|all|none]: produce sipp logfile for <log> directive inside <action> (default none)"

  echo "Arguments:"
  echo -e "\\t sipp_scenario.xml file"
}

while getopts 'hrp:m:t:I:i:T:bl:e:L:' opt; do
  case $opt in
    h) usage; exit 0;;
    r) RESP=1;;
    p) PORT=$OPTARG;;
    m) MPORT=$OPTARG;;
    t) TIMEOUT=$OPTARG;;
    I) IP_SERVER=$OPTARG;;
    i) IP=$OPTARG;;
    T) TRANSPORT=${OPTARG,,};;
    b) BACK="-bg";;
    l) LOG_FILE=${OPTARG};;
    e) ERR_FILE=${OPTARG};;
    L) case $OPTARG in
        "none") ;;
        "responders") TRACE_LOGS_RESPONDER=" -trace_logs" ;;
        "caller") TRACE_LOGS_CALLER=" -trace_logs";;
        "all") TRACE_LOGS_RESPONDER=" -trace_logs" ; TRACE_LOGS_CALLER=" -trace_logs" ;;
        *) echo "unknown LOGTYPE '$OPTARG'"; usage; exit 0 ;;
       esac
       ;;
    *) usage; exit 0;;
  esac
done
shift $((OPTIND - 1))

if [[ $# -ne 1 ]]; then
  echo "Wrong number of arguments"
  usage
  exit 1
fi
if ! [ -f "$1" ]; then
	echo "No $1 file found"
	usage
	exit 1
fi
BASE_DIR="$(dirname "$1")"
IP=${IP:-"127.0.0.1"}
IP_SERVER=${IP_SERVER:-"127.0.0.1"}
MAX="5000"

if [ -n "${LOG_FILE}" ]; then
  MSG_LOG="-trace_msg -message_file ${LOG_FILE}"
fi

if [ -n "${ERR_FILE}" ]; then
  ERR_LOG="-trace_err -error_file ${ERR_FILE}"
else
  ERR_LOG="-trace_err"
fi

if [ "${TRANSPORT}" == "tcp" ]; then
    TRANSPORT_ARG="-t t1"
else
    TRANSPORT_ARG="-t u1"
fi
# shellcheck disable=SC2086
{
if [ -z "${RESP}" ]; then
  if [ -n "${MPORT}" ]; then
    MPORT_ARG="-mp ${MPORT}"
  fi
  PORT=${PORT:-"50602"}
  TIMEOUT=${TIMEOUT:-"15"}

  TRACE_LOGS_CMS=""
  if [ -n "$TRACE_LOGS_CALLER" ] && [ -n "$LOG_FILE" ]; then
    LOGDIR=$(dirname "$LOG_FILE")
    TRACE_LOGFILE=$(basename "$LOG_FILE")
    TRACE_LOGFILE_NOEXT="${TRACE_LOGFILE%.*}"
    TRACE_LOGS_CMS="$TRACE_LOGS_CALLER -log_file $LOGDIR/$TRACE_LOGFILE_NOEXT.log"
  fi

  sipp -max_socket $MAX ${TRANSPORT_ARG} ${MSG_LOG} ${ERR_LOG} \
    -inf "${BASE_DIR}/callee.csv" -inf "${BASE_DIR}/caller.csv" \
    -sf "$1" -i "$IP" -p "$PORT" \
    -nr -nd -m 1 ${MPORT_ARG} \
    -timeout "${TIMEOUT}" -timeout_error${TRACE_LOGS_CMS} \
    "$IP_SERVER" &> /dev/null
  status=$?
else
  if [ -n "${MPORT}" ]; then
    MPORT_ARG="-rtp_echo -mp ${MPORT}"
  fi
  PORT=${PORT:-"50603"}
  TIMEOUT=${TIMEOUT:-"25"}

  if [ -z "${BACK}" ]; then
    sipp -max_socket $MAX ${TRANSPORT_ARG} ${MSG_LOG} ${ERR_LOG} \
      -inf "${BASE_DIR}/callee.csv" -inf "${BASE_DIR}/caller.csv" \
      -sf "$1" -i "$IP" -p "$PORT" \
      -nr -nd -m 1 ${MPORT_ARG} \
      -timeout "${TIMEOUT}" -timeout_error \
      "$IP_SERVER" &> /dev/null
    status=$?
  else
    TRACE_LOGS_CMS=""
    if [ -n "$TRACE_LOGS_RESPONDER" ] && [ -n "$LOG_FILE" ]; then
    LOGDIR=$(dirname "$LOG_FILE")
    TRACE_LOGFILE=$(basename "$LOG_FILE")
    TRACE_LOGFILE_NOEXT="${TRACE_LOGFILE%.*}"
    TRACE_LOGS_CMS="$TRACE_LOGS_RESPONDER -log_file $LOGDIR/$TRACE_LOGFILE_NOEXT.log"
    fi
    tmp=$(sipp $BACK -max_socket $MAX ${TRANSPORT_ARG} ${MSG_LOG} ${ERR_LOG} \
      -inf "${BASE_DIR}/callee.csv" -inf "${BASE_DIR}/caller.csv" \
      -sf "$1" -i "$IP" -p "$PORT" \
      -nr -nd -m 1 ${MPORT_ARG} \
      -timeout "${TIMEOUT}" -timeout_error${TRACE_LOGS_CMS} \
      "$IP_SERVER")
    # shellcheck disable=SC2046
    echo "$tmp" | cut -d= -f2 | sed -e 's_\[__' -e 's_\]__'
    status=0
  fi
fi
}
exit $status
#EOF
