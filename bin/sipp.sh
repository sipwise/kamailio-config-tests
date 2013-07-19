#!/bin/bash

function usage
{
  echo "Usage: sipp.sh [-p PORT] [-m MPORT] [-t TIMEOUT] [-r] scenario.xml"
  echo "Options:"
  echo -e "\t-p: sip port. default 50602/50603(responder)"
  echo -e "\t-m: media port"
  echo -e "\t-t: timeout. default 10/25(responder)"
  echo "Arguments:"
  echo -e "\t sipp_scenario.xml file"
}

while getopts 'hrp:m:t:' opt; do
  case $opt in
    h) usage; exit 0;;
    r) RESP=1;;
    p) PORT=$OPTARG;;
    m) MPORT=$OPTARG;;
    t) TIMEOUT=$OPTARG;;
  esac
done
shift $(($OPTIND - 1))

if [[ $# -ne 1 ]]; then
  echo "Wrong number of arguments"
  usage
  exit 1
fi
if [ ! -f $1 ]; then
	echo "No $1 file found"
	usage
	exit 1
fi
BASE_DIR="$(dirname $1)"
IP="127.0.0.1"
MAX="5000"

if [ -z ${RESP} ]; then
  if [ ! -z ${MPORT} ]; then
    MPORT_ARG="-mp ${MPORT}"
  fi
  PORT=${PORT:-"50602"}
  TIMEOUT=${TIMEOUT:-"10"}
  #echo "Running sipp SCENARIO=$1 IP=${IP} PORT=${PORT} MPORT_ARG=${MPORT_ARG} TIMEOUT=${TIMEOUT}"
  sipp -max_socket $MAX -inf ${BASE_DIR}/../callee.csv -inf ${BASE_DIR}/../caller.csv -sf $1 -i $IP \
    -nd -t ul -p $PORT $IP -m 1 ${MPORT_ARG} -timeout ${TIMEOUT} -timeout_error -trace_err &> /dev/null
  status=$?
else
  if [ ! -z ${MPORT} ]; then
    MPORT_ARG="-rtp_echo -mp ${MPORT}"
  fi
  PORT=${PORT:-"50603"}
  TIMEOUT=${TIMEOUT:-"25"}
  #echo "Running RESP sipp SCENARIO=$1 IP=${IP} PORT=${PORT} MPORT_ARG=${MPORT_ARG} TIMEOUT=${TIMEOUT}"
  sipp -max_socket $MAX -inf ${BASE_DIR}/../callee.csv -sf $1 -i $IP \
    -nd -t ul -p $PORT $IP -m 1 ${MPORT_ARG} -timeout ${TIMEOUT} -timeout_error -trace_err &> /dev/null
  status=$?
fi

exit $status
#EOF
