#!/usr/bin/env python
"""
 Copyright: 2015 Sipwise Development Team <support@sipwise.com>

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
from twisted.internet import reactor, endpoints
from txjason import handler
from txjason.netstring import JSONRPCServerFactory
import json
import logging
import os
import os.path

BASE_DIR = "/usr/share/kamailio-config-tests"
if 'BASE_DIR' in os.environ:
    BASE_DIR = os.environ['BASE_DIR']
logging.basicConfig(level=logging.DEBUG)

class CfgtTest(object):

    def __init__(self, base=None):
        if base is None:
            self.base = os.path.join(BASE_DIR, 'log')
        else:
            self.base = base
        logging.info("BASE_DIR: %s" % self.base)

    def add(self, uuid, msgid, flow, sip_in, sip_out):
        dir_test = os.path.join(self.base, uuid)
        if not os.path.exists(dir_test):
            logging.info("%s created" % dir_test)
            os.mkdir(dir_test)
        values = {
            'uuid': uuid,
            'msgid': msgid,
            'sip_in': sip_in,
            'sip_out': sip_out,
            'flow': flow,
        }
        datafile = os.path.join(dir_test, "%s.json" % msgid)
        with open(datafile, 'w') as jsonfile:
            res = json.dump(values, jsonfile, indent=2,
                      separators=(',', ': '))
        logging.info("%s created" % datafile)
        return True


class CfgtRPCJSON(handler.Handler):

    def __init__(self):
        self.cfgt = CfgtTest()
        super(CfgtRPCJSON, self).__init__()

    @handler.exportRPC()
    def echo(self, param):
        logging.info("echo")
        print param
        return True

    @handler.exportRPC()
    def cfgtest(self, uuid, msgid, flow, sip_in, sip_out):
        logging.info("received %s:%d" % (uuid, msgid))
        self.cfgt.add(uuid, msgid, flow, sip_in, sip_out)
        return True

factory = JSONRPCServerFactory()
factory.addHandler(CfgtRPCJSON())

endpoints.serverFromString(reactor, "tcp:8990").listen(factory)
reactor.run()
