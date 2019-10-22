#!/usr/bin/python3
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
import logging
import os
import os.path
import pyinotify
import sys
import argparse
import signal

BASE_DIR = "/usr/share/kamailio-config-tests"
if 'BASE_DIR' in os.environ:
    BASE_DIR = os.environ['BASE_DIR']
filelog = os.path.join(BASE_DIR, 'log', 'pid_watcher.log')
logging.basicConfig(
    filename=filelog, level=logging.DEBUG, format='%(asctime)s %(message)s')

base_path = "/run"

"""
files we want to watch
"""
services = [
    'kamailio/kamailio.lb.pid',
    'kamailio/kamailio.proxy.pid',
    'ngcp-sems/ngcp-sems.pid',
    'ngcp-witnessd.pid'
]

watched_dirs = [
    '/run/kamailio',
    '/run/ngcp-sems',
    '/run'
]

watched = {}


def sigterm_handler(_signo, _stack_frame):
    logging.info("Process aborted")
    sys.exit(2)


class Handler(pyinotify.ProcessEvent):

    def my_init(self, watched):
        self.watched = watched

    def check_done(self):
        logging.info("All OK, done")
        sys.exit(0)

    def check_all(self):
        all = True
        for k, v in self.watched.items():
            all = (all and (v['created'] or v['modified']))
            logging.info("checking: %s[%s] all:%s" % (k, v, all))
        return all

    def process_IN_CREATE(self, event):
        if event.pathname in watched:
            watched[event.pathname]['created'] = True
            logging.info("created %s" % event.pathname)
            if self.check_all():
                self.check_done()

    def process_IN_IGNORED(self, event):
        if event.pathname in watched:
            watched[event.pathname]['deleted'] = True
            logging.info("deleted %s" % event.pathname)

    def process_IN_MODIFY(self, event):
        if event.pathname in watched:
            watched[event.pathname]['modified'] = True
            logging.info("modified %s" % event.pathname)
            if self.check_all():
                self.check_done()
# for debug
#    def process_default(self, event):
#        if watched.has_key(event.pathname):
#            print event

# catch SIGTERM signal
signal.signal(signal.SIGTERM, sigterm_handler)

parser = argparse.ArgumentParser(
    description='watch some pids to detect restarts')
parser.add_argument('--pbx', dest='pbx', action='store_true',
                    help='pbx is enabled')

args = parser.parse_args()

if args.pbx:
    watched_dirs += [
        '/run/sems-pbx',
        '/run/fastcgi',
    ]
    services += [
        'sems-pbx/sems-pbx.pid',
        'fastcgi/ngcp-panel.pid',
    ]

logging.info("PID watcher started")
wm = pyinotify.WatchManager()
handler = Handler(watched=watched)
notifier = pyinotify.Notifier(wm, default_proc_fun=handler)
for service in services:
    service_pid = os.path.join(base_path, service)
    logging.info("Watching %s" % service_pid)
    watched[service_pid] = {
        'deleted': False, 'created': False, 'modified': False}
    wm.add_watch(service_pid, pyinotify.IN_IGNORED)
for d in watched_dirs:
    wm.add_watch(d, pyinotify.ALL_EVENTS)

logging.info("start loop")
notifier.loop()
