#!/bin/bash
RUN_DIR="$(dirname "$0")"
export BASE_DIR=${BASE_DIR:-$RUN_DIR}
# Set up the environment, to use local perl modules
export PERL5LIB="${BASE_DIR}/lib"
BIN_DIR="${BASE_DIR}/bin"
GROUP="${GROUP:-scenarios}"
DOMAIN="spce.test"

usage() {
  echo "Usage: set_config.sh [-h] [-x GROUP]"
  echo "Options:"
  echo -e "\t-x set GROUP scenario. Default: scenarios"
  echo -e "\t-h this help"

  echo "BASE_DIR:${BASE_DIR}"
  echo "BIN_DIR:${BIN_DIR}"
}

while getopts 'hx:' opt; do
  case $opt in
    h) usage; exit 0;;
    x) GROUP=${OPTARG};;
    *) echo "Unknown option ${opt}"; usage; exit 1;;
  esac
done
shift $((OPTIND - 1))

error_flag=0

echo "$(date) - Removed apicert.pem"
rm -f "${BASE_DIR}/apicert.pem"
echo "$(date) - Setting config debug on"
"${BIN_DIR}/config_debug.pl" -g "${GROUP}" on ${DOMAIN}
cd /etc/ngcp-config || exit 3
if ! ngcpcfg apply "config debug on via kamailio-config-tests" ; then
  echo "$(date) - ngcpcfg apply returned $?"
  error_flag=4
fi
echo "$(date) - Setting config[${GROUP}] debug on. Done[${error_flag}]"

exit ${error_flag}

