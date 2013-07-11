#!/bin/bash
BASE_DIR="/usr/local/src/kamailio-config-tests"
BIN_DIR="${BASE_DIR}/bin"
LOG_DIR="${BASE_DIR}/log"
RESULT_DIR="${BASE_DIR}/result"
DOMAIN="spce.test"
PROFILE="$1"
TPAGE="/usr/bin/tpage"
error_flag=0

function clean
{
  find ${BASE_DIR}/scenarios/ -type f -name '*test.yml'  -exec rm {} \;
}

function usage
{
  echo "Usage: generate_tests.sh [-h] [-c] profile"
  echo "Options:"
  echo -e "\tc: clean. Removes all generated test files"
  echo -e "\th: this help"
  echo "Args:"
  echo -e "\tprofile: CE|PRO"
}

while getopts 'hc' opt; do
  case $opt in
    h) usage; exit 0;;
    c) clean; exit 0;;
  esac
done
shift $(($OPTIND - 1))

if [[ $# -ne 1 ]]; then
  echo "Wrong number or arguments"
  usage
  exit 1
fi

if [ "${PROFILE}" == "CE" ]; then
  TPAGE_ARGS=""
elif [ "${PROFILE}" == "PRO" ]; then
  TPAGE_ARGS="--define PRO=true"
else
  echo "PROFILE ${PROFILE} unknown"
  usage
  exit 2
fi

if [ ! -x ${TPAGE} ]; then
  echo "Cannot exec ${TPAGE}"
  usage
  exit 3
fi

for t in $(find ${BASE_DIR}/scenarios/ -not -regex '.+customtt.tt2' -type f -name '*.tt2' | sort); do
  template="$(basename $t)"
  destdir="$(dirname $t)"
  destfile="$(basename $t .tt2)"
  custom_template="$(basename $t .tt2).customtt.tt2"

  if [ -f "${destdir}/${custom_template}" ]; then
    echo "Custom detected"
    template=${custom_template}
  fi
  echo "generating: ${destdir}/${destfile}"
  ${TPAGE} ${TPAGE_ARGS} ${destdir}/${template} > ${destdir}/${destfile}
  if [ $? -ne 0 ]; then
    error_flag=1
  fi
done

exit $error_flag
#EOF
