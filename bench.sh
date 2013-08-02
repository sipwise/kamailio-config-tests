#!/bin/bash
NUM=${1:-20}
for i in $(seq $NUM); do
  BASE_DIR=$(pwd) ./run_tests.sh -c &> /tmp/run_tests.log
  if [[ $? -ne 0 ]]; then
  	echo "ERROR run_tests $i"
  	break
  fi
  BASE_DIR=$(pwd) ./get_results.sh &> /tmp/get_results.log
  if [[ $? -ne 0 ]]; then
  	echo "ERROR get_results $i"
  	break
  fi
  echo "$i done ok"
  # keep everything
  mv log log_$i 
  mv result result_$i
done
