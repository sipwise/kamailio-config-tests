#!/bin/bash
BASE_DIR="${BASE_DIR:-/usr/share/kamailio-config-tests}"
BIN_DIR="${BASE_DIR}/bin"
LOG_DIR="${BASE_DIR}/log"
RESULT_DIR="${BASE_DIR}/result"
PROFILE="CE"
DOMAIN="spce.test"

function usage
{
  echo "Usage: get_results.sh [-p PROFILE] [-h] [-g]"
  echo "-p CE|PRO default is CE"
  echo "-g generate png flow graphs if test fails"
  echo "-G generate png all flow graphs"
  echo "-h this help"
  echo "-P parse only will disable test"
  echo "-T test only will disable parse"
  echo "BASE_DIR:${BASE_DIR}"
  echo "BIN_DIR:${BIN_DIR}"
}

while getopts 'hgGp:TP' opt; do
  case $opt in
    h) usage; exit 0;;
    G) GRAPH="-G";;
    g) GRAPH="-g";;
    P) OPTS="-T";;
    T) OPTS="-P";;
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

find ${BASE_DIR}/scenarios/ -depth -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | grep -v templates| sort \
 | parallel "${BIN_DIR}/check.sh ${GRAPH} -C -R ${OPTS} -d ${DOMAIN} -p ${PROFILE}"
status=$?
echo "$(date) - All done[$status]"
exit $status
