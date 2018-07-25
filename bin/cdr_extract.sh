#!/bin/bash
#
# Copyright: 2013-2016 Sipwise Development Team <support@sipwise.com>
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


START_TIME=""


# sipwise password for mysql connections
. /etc/mysql/sipwise.cnf


usage() {
  echo "Usage: check.sh [-h] -t START_TIME -s [GROUP] check_name"
  echo "Options:"
  echo -e "\t-t Tests start time in order to better tune the mysql query."
  echo -e "\t-s scenario group. Default: scenarios"
  echo "Arguments:"
  echo -e "\tcheck_name. Scenario name to check. This is the name of the directory on GROUP dir."
}

while getopts 'ht:s:' opt; do
  case $opt in
    h) usage; exit 0;;
    t) START_TIME=$OPTARG;;
    s) GROUP=$OPTARG;;
  esac
done
shift $((OPTIND - 1))

if [[ $# != 1 ]]; then
  echo "Wrong number of arguments"
  usage
  exit 1
fi

if [ -n "${START_TIME}" ]; then
  echo "Start time not defined"
  usage
  exit 1
fi


GROUP="${GROUP:-scenarios}"
NAME_CHECK="$1"
BASE_DIR="${BASE_DIR:-/usr/share/kamailio-config-tests}"
LOG_DIR="${BASE_DIR}/log/${GROUP}/${NAME_CHECK}"


echo "$(date) - Exporting generated CDRs"
mysql -usipwise -p"${SIPWISE_DB_PASSWORD}" accounting \
      -e "select * from cdr where call_id like 'NGCP\%${NAME_CHECK}\%%' and start_time > unix_timestamp(${START_TIME}) order by id desc limit 3\G" > "${LOG_DIR}/cdr.txt" || true
echo "$(date) - Done"


exit 0
#EOF
