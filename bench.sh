#!/bin/bash
NUM=${1:-20}
# clean previous
rm -rf log_* result_*
echo "$(date) - Starting $NUM tests"
for i in $(seq $NUM); do
  BASE_DIR=$(pwd) ./run_tests.sh -c &> /tmp/run_tests.log
  status=$?
  if [[ $status -ne 0 ]]; then
  	echo "$(date) - ERROR[$status] run_tests $i"
  	break
  fi
  BASE_DIR=$(pwd) ./get_results.sh &> /tmp/get_results.log
  status=$?
  if [[ $status -ne 0 ]]; then
  	echo "$(date) - ERROR[$status] get_results $i"
  	break
  fi
  echo "$(date) - $i done ok"
  # keep everything
  mv log log_$i 
  mv result result_$i
done
