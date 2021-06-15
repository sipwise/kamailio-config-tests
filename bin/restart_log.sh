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
#ngcp-kamcmd proxy dbg.reset_msgid
BASE_LOG="/var/log/ngcp"
LOGS=()
LOGS+=( "kamailio-proxy.log" )
LOGS+=( "sems.log" )
LOGS+=( "sems-b2b.log" )
LOGS+=( "kamailio-lb.log" )
LOGS+=( "rtp.log" )

# shellcheck disable=SC2086
(cd ${BASE_LOG} || exit 2; rm -rf ${LOGS[*]})
service rsyslog restart

log_ref="panel.log"
if ! [ -f "${BASE_LOG}/${log_ref}" ] ; then
  log_ref="panel-fcgi.log"
fi

for l in ${LOGS[*]} ; do
  touch --reference="${BASE_LOG}/${log_ref}" "${BASE_LOG}/$l"
done
