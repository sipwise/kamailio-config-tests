#!/bin/bash
set -e

GROUP=${1:-scenarios}
BASE_DIR="${BASE_DIR:-/usr/share/kamailio-config-tests}"

if ! [ -d "${BASE_DIR}/${GROUP}" ]; then
	echo "${BASE_DIR}/${GROUP} dir not found" >&2
	exit 1
fi

case ${GROUP} in
  scenarios)
    mkdir -p /etc/kamailio/stir/
    cp "${BASE_DIR}/${GROUP}/invite-peerout-stir.scenarios.test.key" \
      /etc/kamailio/stir/
    chown -R kamailio:kamailio /etc/kamailio/stir/
    echo "$(date) - Added stir file keys"
    ;;
  *)
	echo "$(date) - Nothing to do here"
	;;
esac
