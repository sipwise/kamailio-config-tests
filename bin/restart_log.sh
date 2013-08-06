#!/bin/bash
invoke-rc.d kamailio-proxy stop
if [[ $(ps aux | grep kamailio.proxy | wc -l) -ne 1 ]]; then
  echo "$(date) - killing kamailio-proxy"
  for pid in $(ps aux | grep ^kamailio| grep kamailio.proxy | cut -d' ' -f2 | xargs); do
    kill -9 $pid
  done
fi
rm -rf /var/log/ngcp/kamailio-proxy.log
rm -rf /var/log/ngcp/sems.log
rm -rf /var/log/ngcp/kamailio-lb.log
invoke-rc.d rsyslog restart
invoke-rc.d kamailio-proxy start
if [[ $(ps aux | grep kamailio.proxy | wc -l) -eq 1 ]]; then
  exit 1
fi