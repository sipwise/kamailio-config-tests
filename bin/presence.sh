#!/bin/bash
#
# Copyright: 2013 Sipwise Development Team <support@sipwise.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This package is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# On Debian systems, the complete text of the GNU General
# Public License version 3 can be found in "/usr/share/common-licenses/GPL-3".
#
BASE_DIR="${BASE_DIR:-/usr/share/kamailio-config-tests}"
DIR="${BASE_DIR}/scenarios"

clean() {
  find "${DIR}" -type f -name 'presence_*.xml' -exec rm {} \;
}

usage() {
  echo "Usage: generate_tests.sh [-h] [-c] [-d directory] digest presence_file.xml"
  echo "Options:"
  echo -e "\tc: clean. Removes all generated presence files"
  echo -e "\td: directory"
  echo -e "\th: this help"
  echo "Args:"
  echo -e "\tdigest: testuserX@domain:password"
}

while getopts 'hcd:' opt; do
  case $opt in
    h) usage; exit 0;;
    c) clean; exit 0;;
    d) DIR=$OPTARG;;
  esac
done
shift $((OPTIND - 1))

if [[ $# -ne 2 ]]; then
  echo "Wrong number or arguments"
  usage
  exit 1
fi

if ! [ -e "${2}" ]; then
    echo "No ${2} file found"
    exit 1
fi
# subscriber part
subs=$(echo "$1"|cut -f1 -d:)
if ! curl -T "$2" -X PUT --digest -k -u "$1" \
  "https://127.0.0.1:1080/xcap/pres-rules/users/sip:${subs}/presrules";
then
	echo "error sending xcap info"
	exit 1
fi
#EOF
