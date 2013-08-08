#!/bin/bash
ngcp-sercmd proxy dbg.reset_msgid
rm -rf /var/log/ngcp/kamailio-proxy.log
rm -rf /var/log/ngcp/sems.log
rm -rf /var/log/ngcp/kamailio-lb.log
invoke-rc.d rsyslog restart
