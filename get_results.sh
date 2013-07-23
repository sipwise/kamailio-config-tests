#!/bin/bash
BASE_DIR="${BASE_DIR:-/usr/local/src/kamailio-config-tests}"
BIN_DIR="${BASE_DIR}/bin"
LOG_DIR="${BASE_DIR}/log"
RESULT_DIR="${BASE_DIR}/result"
PROFILE="CE"
DOMAIN="spce.test"

function usage
{
  echo "Usage: get_results.sh [-p PROFILE] [-h] [-g]"
  echo "-p CE|PRO default is CE"
  echo "-g generate png flow graphs"
  echo "-h this help"

  echo "BASE_DIR:${BASE_DIR}"
  echo "BIN_DIR:${BIN_DIR}"
}

while getopts 'hcp:' opt; do
  case $opt in
    h) usage; exit 0;;
    g) GRAPH="-G";;
    p) PROFILE=$OPTARG;;
  esac
done
shift $(($OPTIND - 1))

if [[ $# -ne 0 ]]; then
  echo "Wrong number or arguments"
  usage
  exit 1
fi

if [ "${PROFILE}" != "CE" ] && [ "${PROFILE}" != "PRO" ]; then
  echo "PROFILE ${PROFILE} unknown"
  usage
  exit 2
fi

echo "$(date) - Clean result dir"
rm -rf ${RESULT_DIR}

for t in $(find ${BASE_DIR}/scenarios/ -depth -maxdepth 1 -mindepth 1 -type d | sort); do
  echo "$(date) - Testing[${PROFILE}]: $(basename $t) ================================================="
  echo $(basename $t) | parallel "${BIN_DIR}/check.sh ${GRAPH} -C -d ${DOMAIN} -p ${PROFILE}"
done

echo "$(date) - All done"
