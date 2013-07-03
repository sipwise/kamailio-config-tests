#!/bin/bash
if [[ $# -ne 1 ]]; then
	echo "Usage: sipp.sh scenario.xml"
	exit 1
fi
if [ ! -f $1 ]; then
	echo "No $1 file found"
	exit 1
fi
BASE_DIR=$(dirname $1)
IP="127.0.0.1"
PORT="50603"
sipp -inf ${BASE_DIR}/../callee.csv -inf ${BASE_DIR}/../caller.csv -sf $1 -i $IP \
  -nd -t ul -p $PORT $IP -m 1 -timeout 15 -timeout_error -trace_err