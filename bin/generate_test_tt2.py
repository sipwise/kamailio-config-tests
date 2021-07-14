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
import sys
from pathlib import Path
import os
import logging
import re
import argparse
import subprocess
from yaml import load

try:
    from yaml import CLoader as Loader
except ImportError:
    from yaml import Loader


def load_yaml(filepath):
    output = None
    with open(filepath, "r") as file:
        output = load(file, Loader=Loader)
    return output


def load_msg(filepath):
    mark = re.compile(r"^-+ .+")
    recv = re.compile(r"^(TCP|UDP) message received .+")
    res = []
    msg = []
    flag = False

    with open(filepath, "r") as file:
        line = file.readline()
        while line:
            if mark.match(line):
                if flag and len(msg) > 0:
                    res.append(msg)
                    msg = []
                flag = False
            elif recv.match(line):
                line = file.readline()  # eat next empty line
                flag = True
            elif flag:
                msg.append(line)
            line = file.readline()
    if flag and len(msg) > 0:
        res.append(msg)
        msg = []
    return res


def is_zero(matchobj):
    if matchobj.group(1) == "0":
        return ": 0"
    return r": \d+"


class Generator:
    common_hdrs = set(["Via", "Route", "Call-ID", "Expires", "Max-Forwards"])
    hdr_re = re.compile(r"^([\w-]+): .+")

    @classmethod
    def get_filters(cls, args):
        filters = set()
        if args.filter_common:
            cls.common_hdrs = set(args.filter_common)
        if args.filter:
            filters = set(args.filter)
        return cls.common_hdrs | filters

    @classmethod
    def generate_rules(self, ids):
        rules = []
        id_dom = ids["domains"][0]
        server_ip = ids["server_ip"]

        def sip_rule(subs, tt, field):
            str_val = str(subs[field])
            if str_val.startswith("00"):
                r = (
                    r"(sip|tel):{}([^\d])".format(subs[field]),
                    r"\1:[% {}.{} %]\2".format(tt, field),
                )
                rules.append(r)
                logging.info("rule:[{0}]=>[{1}]".format(r[0], r[1]))
            else:
                rules.append(
                    (
                        r"(sip|tel):(\\\+|00)?{}([^\d])".format(subs[field]),
                        r"\1:\2[% {}.{} %]\3".format(tt, field),
                    )
                )

        def sdp_rule(val, tt):
            rules.append(
                (
                    r"^c=IN IP(\d) {}".format(val),
                    r"c=IN IP\1 [% {} %]".format(tt),
                )
            )
            rules.append(
                (
                    r"^o=(.+) \d+ \d+ IN IP(\d) {}".format(val),
                    r"o=\1 \\d+ \\d+ IN IP\2 [% {} %]".format(tt),
                )
            )

        def add_sip(subs, tt):
            sip_rule(subs, tt, "username")
            if "devid" in subs:
                if subs["username"] != subs["devid"]:
                    sip_rule(subs, tt, "devid")

        def add_sip_full(subs, tt):
            rules.append(
                (
                    r"(sip|tel):(\\\+|00)?{}@{}:{}".format(
                        subs["username"], subs["ip"], subs["port"]
                    ),
                    r"\1:\2[% {0}.username %]@"
                    "[% {0}.ip %]:[% {0}.port %]".format(tt),
                )
            )
            rules.append(
                (
                    r"sip:{}:{}([^\d])".format(subs["ip"], subs["port"]),
                    r"sip:[% {0}.ip %]:[% {0}.port %]\1".format(tt),
                )
            )

        def add_socket(scen, tt):
            rules.append(
                (
                    r";socket=udp:{}:{}([^;>]+)".format(
                        scen["ip"], scen["port"]
                    ),
                    r";socket=udp:[% {0}.ip %]:[% {0}.port %]\1".format(tt),
                )
            )
            sdp_rule(scen["ip"], f"{tt}.ip")
            rules.append(
                (
                    r"^m=audio {} (.+)".format(scen["mport"]),
                    r"m=audio [% {}.mport %] \1".format(tt),
                )
            )

        # server_ip rules
        rules.append(
            (
                r";socket=(sip|udp):{}:5060".format(server_ip),
                r";socket=\1:[% server_ip %]:5060",
            )
        )
        rules.append(
            (r"sip:([^@]+@){}".format(server_ip), r"sip:\1[% server_ip %]")
        )
        rules.append((r"sip:{}".format(server_ip), f"sip:[% server_ip %]"))
        sdp_rule(server_ip, "server_ip")

        # priority on full match
        for idx, scen in enumerate(ids["scenarios"]):
            add_sip_full(scen, f"scenarios.{idx}")
            add_socket(scen, f"scenarios.{idx}")
            for jdx, resp in enumerate(scen["responders"]):
                add_sip_full(resp, f"scenarios.{idx}.responders.{jdx}")
                add_socket(resp, f"scenarios.{idx}.responders.{jdx}")
        for idx, scen in enumerate(ids["scenarios"]):
            add_sip(scen, f"scenarios.{idx}")
            for jdx, resp in enumerate(scen["responders"]):
                add_sip(resp, f"scenarios.{idx}.responders.{jdx}")
        for key in ids[id_dom]:
            sip_rule(ids[id_dom][key], f"{id_dom}.{key}", "phone_number")
        return rules

    def __init__(self, _hdrs, _msg, _ids):
        # ignore case for headers
        self.hdrs = [hdr.lower() for hdr in _hdrs]
        self.msgs = _msg
        self.ids = _ids
        self.ids_rules = self.generate_rules(_ids)

    @classmethod
    def get_header(self, line):
        m = self.hdr_re.match(line)
        if m:
            # ignore case for header
            return m.group(1).lower()

    def filter_hdr(self, line):
        hdr = self.get_header(line)
        if hdr and hdr in self.hdrs:
            return True, hdr
        return False, hdr

    def subst_common(self, line, hdr):
        rules = []
        if hdr is None:
            rules.append((r"^a=rtcp:\d+", r"a=rtcp:\\d+"))
            rules.append((r"^m=audio \d+ (.+)", r"m=audio \\d+ \1"))
        elif hdr in ["from", "to"]:
            rules.append((r";tag=[^;>]+", r";tag=[\\w-]+"))
        elif hdr in ["www-authenticate", "proxy-authenticate"]:
            rules.append((r"nonce=\"[^\"]+", 'nonce="[^"]+'))
        elif hdr in ["server", "user-agent"]:
            rules.append(
                (
                    r": Sipwise NGCP (Proxy|Application|PBX|LB).+",
                    r": Sipwise NGCP \1",
                )
            )
        elif hdr == "content-length":
            rules.append((r":\s+(\d+)", is_zero))
        elif hdr == "record-route":
            rules.append((r";did=[^;>]+", r";did=[^;]+"))
            rules.append((r";ftag=[^;>]+", r";ftag=[^;]+"))
            rules.append((r";aset=[^;>]+", r";aset=\\d+"))
            rules.append((r";vsf=[^;>]+", r";vsf=[^;]+"))
        elif hdr == "contact":
            rules.append((r"expires=[1-9]\d*", r"expires=\\d+"))
            rules.append((r";ngcpct=[^;>]+", r";ngcpct=[^;]+"))
        for rule in rules:
            line = re.sub(rule[0], rule[1], line, flags=re.IGNORECASE)
        return line

    def subst_ids(self, line, hdr):
        for rule in self.ids_rules:
            line = re.sub(rule[0], rule[1], line)
        return line

    @classmethod
    def escape_line(self, line):
        for char in ["*", "+", "?", "(", ")", "[", "]"]:
            line = line.replace(f"{char}", r"\{}".format(char))
        return line

    def process_msg(self, msg):
        res = []
        for line in msg:
            line = line.replace("\n", "")
            # escape special characters
            line = self.escape_line(line)
            ok, hdr = self.filter_hdr(line)
            if ok:
                continue
            l_ids = self.subst_ids(line, hdr)
            l = self.subst_common(l_ids, hdr)
            # remove empty lines
            if len(l) > 0:
                if line != l:
                    logging.info("line:{} => {}".format(line, l))
                res.append(l)
        return res

    def run(self):
        res = []
        for msg in self.msgs:
            res.append(self.process_msg(msg))
        return res


def main(args):
    msgs = load_msg(args.sipp_msg)
    ids = load_yaml(args.scen_ids)
    gen = Generator(Generator.get_filters(args), msgs, ids)
    print("messages:")
    for msg in gen.run():
        sys.stdout.write("- - '")
        sys.stdout.write(msg[0])
        sys.stdout.write("'\n")
        for idx, line in enumerate(msg[1:]):
            sys.stdout.write("  - '")
            sys.stdout.write(line)
            sys.stdout.write("'\n")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="generate test_yml.tt2 files from sipp msg file"
    )
    parser.add_argument(
        "scen_ids", help="path to the scenario_ids.yml file", type=Path
    )
    parser.add_argument(
        "sipp_msg", help="path to the sipp msg file", type=Path
    )
    parser.add_argument("--filter", nargs="?", help="remove this header")
    parser.add_argument("--filter-common", help="filter common headers")
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
