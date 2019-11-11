#!/usr/bin/python3
#
# Copyright: 2013-2015 Sipwise Development Team <support@sipwise.com>
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
import asyncio
import logging
import io
import argparse
import aioxmpp
from yaml import load
try:
    from yaml import CLoader as Loader
except ImportError:
    from yaml import Loader

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)

console_handler = logging.StreamHandler()
console_handler.setLevel(logging.CRITICAL)
console_handler.setFormatter(
    logging.Formatter('[%(levelname)s](%(name)s): %(message)s')
)
logger.addHandler(console_handler)


def load_yaml(filepath):
    output = None
    with io.open(filepath, 'r') as file:
        output = load(file, Loader=Loader)
    file.close()
    return output


# def test_disco(client):
#     sd = client.summon(aioxmpp.DiscoClient)

#     server_info = yield from sd.query_info(
#         client.local_jid.replace(localpart=None, resource=None)
#     )

#     console_handler.info("disco: {}".format(server_info))


async def do(server, jid, password):
    client = aioxmpp.Client(
        jid,
        aioxmpp.make_security_layer(password),
        override_peer=[
            (server, 5222, aioxmpp.connector.STARTTLSConnector())
        ],
        logger=logger,
    )

    async with client.connected() as stream:
        logger.debug("connected")
        # test_disco(jid, stream)


async def main(args):
    logger.debug("debug on")
    scen = load_yaml(args.scenario)
    domains = [x for x in scen['domains']]
    domain = domains[0]
    logger.debug("domains:{}".format(domains))
    subs = [x for x in scen['subscribers'][domain]]
    sub = subs[0]
    logger.debug("subs:{}".format(subs))
    jid_str = "{}@{}".format(subs[0], domain)
    jid = aioxmpp.JID.fromstr(jid_str)
    password = scen['subscribers'][domain][sub]['password']
    logger.debug("server:{} jid:{} pass:{}".format(
        args.server, jid, password))
    await do(args.server, jid, password)
    logger.info("done")


def set_log_level_from_verbose(args):
    if not args.verbose:
        console_handler.setLevel('ERROR')
    elif args.verbose == 1:
        console_handler.setLevel('WARNING')
    elif args.verbose == 2:
        console_handler.setLevel('INFO')
    elif args.verbose >= 3:
        console_handler.setLevel('DEBUG')
    else:
        logger.critical("UNEXPLAINED NEGATIVE COUNT!")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='test sipwise vjud module')
    parser.add_argument('server',
                        help='prosody server')
    parser.add_argument('scenario',
                        help='scenario.yml file')
    parser.add_argument(
        "-v",
        "--verbose",
        action="count",
        default=0,
        help="Verbosity (-v, -vv, etc)")

    args = parser.parse_args()
    set_log_level_from_verbose(args)
    asyncio.run(main(args), debug=True)
