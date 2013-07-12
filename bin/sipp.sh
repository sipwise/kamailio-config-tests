#!/bin/bash

function set_domain
{
  if [[ $1 -eq 1 ]]; then
    p="s/DOMAIN/${DOMAIN}/"
  else
    p="s/${DOMAIN}/DOMAIN/"
  fi
  for i in e r; do 
    if [ -f "${BASE_DIR}/../calle$i.csv" ]; then
      sed -e "$p" -i ${BASE_DIR}/../calle$i.csv
    else
      echo "No ${BASE_DIR}/../calle$i.csv file found"
      exit 1
    fi
  done
}

function usage
{
  echo "Usage: sipp.sh [-d domain] [-p PORT] [-m MPORT] [-t TIMEOUT] [-r] scenario.xml"
  echo "Options:"
  echo -e "\t-d: DOMAIN. default: spce.test"
  echo -e "\t-p: sip port. default 50602/50603(responder)"
  echo -e "\t-m: media port. default 6002/6003(responder)"
  echo -e "\t-t: timeout. default 10/25(responder)"
  echo "Arguments:"
  echo -e "\t sipp_scenario.xml file"
}

while getopts 'hrp:m:t:d:' opt; do
  case $opt in
    h) usage; exit 0;;
    r) RESP=1;;
    p) PORT=$OPTARG;;
    m) MPORT=$OPTARG;;
    t) TIMEOUT=$OPTARG;;
    d) DOMAIN=$OPTARG;;
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
BASE_DIR=$(dirname $1)
IP="127.0.0.1"
DOMAIN=${DOMAIN:-"spce.test"}
MAX="5000"
set_domain 1

if [ -z ${RESP} ]; then
  MPORT=${PORT:-"6002"}
  PORT=${PORT:-"50602"}
  TIMEOUT=${TIMEOUT:-"10"}
  sipp -max_socket $MAX -inf ${BASE_DIR}/../callee.csv -inf ${BASE_DIR}/../caller.csv -sf $1 -i $IP \
    -nd -t ul -p $PORT $IP -m 1 -mp ${MPORT} -timeout ${TIMEOUT} -timeout_error -trace_err
else
  MPORT=${PORT:-"6003"}
  PORT=${PORT:-"50603"}
  TIMEOUT=${TIMEOUT:-"25"}
  sipp -max_socket $MAX -inf ${BASE_DIR}/../callee.csv -sf $1 -i $IP \
    -nd -t ul -p $PORT $IP -m 1 -rtp_echo -mp ${MPORT} -timeout ${TIMEOUT} -timeout_error -trace_err
fi

set_domain 0
#EOF
