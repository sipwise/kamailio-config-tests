#!/bin/sh
invoke-rc.d kamailio-proxy stop
rm -rf /var/log/ngcp/kamailio-proxy.log
rm -rf /var/log/ngcp/sems.log
rm -rf /var/log/ngcp/kamailio-lb.log
invoke-rc.d rsyslog restart
invoke-rc.d kamailio-proxy start
