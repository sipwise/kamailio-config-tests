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
LOGS="/var/log/ngcp/kamailio-proxy.log /var/log/ngcp/sems.log \
 /var/log/ngcp/sems-pbx.log /var/log/ngcp/kamailio-lb.log"
# shellcheck disable=SC2086
rm -rf $LOGS
service rsyslog restart
for l in $LOGS ; do
  touch --reference=/var/log/ngcp/panel.log "$l"
done
