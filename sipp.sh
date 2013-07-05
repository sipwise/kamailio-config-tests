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

while getopts 'rd:' opt; do
  case $opt in
    r) RESP=1;;
    d) DOMAIN=$OPTARG
  esac
done
shift $(($OPTIND - 1))

if [[ $# -ne 1 ]]; then
	echo "Usage: sipp.sh [-d domain] [-r] scenario.xml"
	exit 1
fi
if [ ! -f $1 ]; then
	echo "No $1 file found"
	exit 1
fi
BASE_DIR=$(dirname $1)
IP="127.0.0.1"
DOMAIN=${DOMAIN:-"spce.test"}

set_domain 1

if [ -z ${RESP} ]; then
  PORT="50603"
  sipp -inf ${BASE_DIR}/../callee.csv -inf ${BASE_DIR}/../caller.csv -sf $1 -i $IP \
    -nd -t ul -p $PORT $IP -m 1 -timeout 15 -timeout_error -trace_err
else
  PORT="50602"
  sipp -inf ${BASE_DIR}/../callee.csv -sf $1 -i $IP \
    -nd -t ul -p $PORT $IP -m 1 -timeout 14 -timeout_error -trace_err
fi

set_domain 0
#EOF
