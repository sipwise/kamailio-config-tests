#!/bin/sh
#ngcpcfg build /etc/kamailio/proxy/
invoke-rc.d kamailio-proxy stop
rm -rf /var/log/ngcp/kamailio-proxy.log
invoke-rc.d rsyslog restart
invoke-rc.d kamailio-proxy start
