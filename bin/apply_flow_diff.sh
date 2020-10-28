#!/bin/bash
die()
{
  echo "ERROR: $1" >&2
  exit "${2:-1}"
}

log_info()
{
  echo "INFO: $*"
}
BASE_DIR="${BASE_DIR:-/usr/share/kamailio-config-tests}"
GROUP="${GROUP:-scenarios}"

usage() {
  echo "Usage: apply_flow_diff.sh [-x <group>] <scenario>"
  echo "Options:"
  echo -e "\t-x set GROUP scenario. Default: scenarios"
  echo -e "\t-h this help"
}

while getopts 'hx' opt; do
  case $opt in
    h) usage; exit 0;;
    x) GROUP=${OPTARG};;
    *) usage; exit 1;;
  esac
done
shift $((OPTIND - 1))

if [[ $# -ne 1 ]]; then
  echo "Wrong number or arguments"
  usage
  exit 1
fi

SCEN="$1"
RESULT_DIR=${BASE_DIR}/result/${GROUP}/${SCEN}
TEST_DIR=${BASE_DIR}/${GROUP}/${SCEN}

cd "${TEST_DIR}" || die "${TEST_DIR} not found"
find "${RESULT_DIR}" -name '0*_test.diff' | sort -r | while read -r dfile ; do
	tfile=$(basename "${dfile}" .diff).yml.tt2
	patch -p1 "${tfile}" "${dfile}"
done