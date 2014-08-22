#!/usr/bin/env python
"""
 Copyright: 2014 Sipwise Development Team <support@sipwise.com>

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This package is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program. If not, see <http://www.gnu.org/licenses/>.

 On Debian systems, the complete text of the GNU General
 Public License version 3 can be found in "/usr/share/common-licenses/GPL-3".
"""
import sys
import os.path
import pyinotify

base_path = "/var/run"

"""
files we want to watch
"""
services = [
    'kamailio/kamailio.lb.pid',
    'kamailio/kamailio.proxy.pid',
    'ngcp-sems/ngcp-sems.pid',
    'collectdmon.pid'
]

services_stop = [
    'rate-o-mat.pid',
]

watched_dirs = [
    '/var/run/kamailio',
    '/var/run/ngcp-sems',
    '/var/run'
]

watched = {}

class Handler(pyinotify.ProcessEvent):
    def my_init(self, watched):
        self.watched = watched

    def check_all(self):
        all = True
        for k,v in self.watched.iteritems():
            all = (all and (v['created'] or v['modified'] or v['deleted']))
            print "checking: %s[%s] all:%s" % (k,v, all)
        return all

    def process_IN_CREATE(self, event):
        if watched.has_key(event.pathname):
            watched[event.pathname]['created'] = True
            print "created %s" % event.pathname
            if self.check_all():
                sys.exit(0)

    def process_IN_IGNORED(self, event):
        if watched.has_key(event.pathname):
            watched[event.pathname]['deleted'] = True
            print "deleted %s" % event.pathname

    def process_IN_MODIFY(self, event):
        if watched.has_key(event.pathname):
            watched[event.pathname]['modified'] = True
            print "modified %s" % event.pathname

    def process_IN_DELETE(self, event):
        if watched.has_key(event.pathname+'_del'):
            watched[event.pathname+'_del']['deleted'] = True
            print "deleted %s" % event.pathname
# for debug
#    def process_default(self, event):
#        if watched.has_key(event.pathname):
#            print event

wm = pyinotify.WatchManager()
handler = Handler(watched=watched)
notifier = pyinotify.Notifier(wm, default_proc_fun=handler)
for service in services:
    service_pid = os.path.join(base_path, service)
    print "Watching %s" % service_pid
    watched[service_pid] = {'deleted': False, 'created': False, 'modified': False }
    wm.add_watch(service_pid, pyinotify.IN_IGNORED)

for service in services_stop:
    service_pid = os.path.join(base_path, service)
    print "Watching %s" % service_pid
    watched[service_pid+'_del'] = {'deleted': False, 'created': False, 'modified': False }
    wm.add_watch(service_pid, pyinotify.IN_IGNORED)

for d in watched_dirs:
    wm.add_watch(d, pyinotify.ALL_EVENTS)

notifier.loop()
