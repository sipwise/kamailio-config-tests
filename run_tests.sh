#!/bin/bash
BASE_DIR="/usr/local/src/log_parser"

while getopts 'ct' opt; do
  case $opt in
    c) SKIP=1;;
    t) TEST=1;;
  esac
done

if [ -z $SKIP ]; then
  ${BASE_DIR}/config_debug.pl
  ngcpcfg apply
fi

rm -rf ${BASE_DIR}/result/*

for t in $(find ${BASE_DIR}/scenarios/ -depth -maxdepth 1 -mindepth 1 -type d ); do
  echo "Run: $(basename $t)"
  if [ -z $TEST ]; then
    bash ${BASE_DIR}/scenarios/check.sh $(basename $t)
  fi
done

if [ -z $SKIP ]; then
  ${BASE_DIR}/config_debug.pl off
  ngcpcfg apply
fi
