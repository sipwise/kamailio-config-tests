#!/usr/bin/env python
"""
 Testing client

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
from twisted.internet import reactor
from twisted.internet import endpoints
from txjason.netstring import JSONRPCClientFactory


endpoint = endpoints.TCP4ClientEndpoint(reactor, '127.0.0.1', 8990)
client = JSONRPCClientFactory(endpoint, reactor=reactor)

d = client.notifyRemote(
    'echo', 'hola server')

d = client.notifyRemote(
    'cfgtest', 'UUID0', 1, '{"hola": "adios"}', "a lot", "small")

d = client.notifyRemote(
    'echo', 'adios server')

reactor.run()
