#!/usr/bin/python3
#
# Copyright: 2021 Sipwise Development Team <support@sipwise.com>
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
from pathlib import Path
import os
import logging
import io
import argparse
import subprocess
from yaml import load, dump

try:
    from yaml import CLoader as Loader, CDumper as Dumper
except ImportError:
    from yaml import Loader, Dumper


def executeAndReturnOutput(command, env=os.environ):
    p = subprocess.Popen(
        command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=env
    )
    stdoutdata, stderrdata = p.communicate()
    return p.returncode, stdoutdata.decode(), stderrdata.decode()


def save_yaml(obj, filepath):
    with io.open(filepath, "w") as file:
        dump(obj, file, Dumper=Dumper)
    file.close()


def load_yaml(filepath):
    output = None
    with io.open(filepath, "r") as file:
        output = load(file, Loader=Loader)
    file.close()
    return output


def get_nodename():
    ok, nodename, err = executeAndReturnOutput("ngcp-nodename")
    if ok != 0:
        logging.error("can not get nodename")
        raise Exception(err)

    nodename = nodename.strip()

    if nodename == "spce":
        nodename = "self"
    logging.info("detected nodename:{}".format(nodename))
    return nodename


def detect_ip(network, nodename, _type, exclude=[]):
    host = network["hosts"][nodename]

    for iface in host["interfaces"]:
        if iface in exclude:
            continue
        if _type in host[iface]["type"]:
            ip = host[iface]["ip"]
            if "shared_ip" in host[iface] and host[iface]["shared_ip"]:
                if len(host[iface]["shared_ip"]) > 0:
                    ip = host[iface]["shared_ip"][0]
            logging.info(
                "type:{} detected IP:{} on iface:{}".format(_type, ip, iface)
            )
            return ip

    raise Exception("can not detect {} IP".format(_type))


def get_lb(network, nodename):
    return detect_ip(network, nodename, "sip_ext", exclude=["lo"])


def main(args):
    config = load_yaml(args.config)
    network = load_yaml(args.network)

    nodename = get_nodename()

    if args.lb_ip is None:
        args.lb_ip = get_lb(network, nodename)
    else:
        logging.info("using lb_ip:{} from args".format(args.lb_ip))
    if args.peer_ip:
        logging.info("using peer_ip:{} from args".format(args.peer_ip))
        config["peer"]["ip"] = args.peer_ip
    if args.sip_ip:
        logging.info("using sip_ip:{} from args".format(args.sip_ip))
        config["sip"]["ip"] = args.sip_ip

    if args.sip_ip and args.sip_ip == args.peer_ip:
        raise Exception("peer_ip can not be the same as sip_ip")

    config["kamailio"]["lb"]["ip"] = args.lb_ip
    save_yaml(config, args.config)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="detect and set network configs."
    )
    parser.add_argument(
        "config", help="path to the k-c-t config.yml", type=Path
    )
    parser.add_argument(
        "network", help="path to the NGCP network.yml", type=Path
    )
    parser.add_argument("--lb-ip", help="kamailio lb sip_ext IP")
    parser.add_argument("--sip-ip", help="sip IP")
    parser.add_argument("--peer-ip", help="peer IP")
    parser.add_argument(
        "--verbose",
        "-v",
        help="verbose mode",
        action="store_const",
        dest="loglevel",
        const=logging.INFO,
    )
    args = parser.parse_args()
    logging.basicConfig(level=args.loglevel)
    main(args)
