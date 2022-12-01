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
import json
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


def load_sipp_msg(filepath):
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


def load_json(filepath):
    output = None
    with open(filepath, "r") as file:
        output = json.load(file)
    return output


def is_zero(matchobj):
    if matchobj.group(1) == "0":
        return r":\s+0"
    return r":\s+\d+"


class Generator:
    common_hdrs = set(["Via", "Route", "Call-ID", "Expires", "Max-Forwards"])
    hdr_re = re.compile(r"^([\w-]+): .+")

    def __init__(self, _hdrs, _ids):
        # ignore case for headers
        self.hdrs = [hdr.lower() for hdr in _hdrs]
        self.ids = _ids
        self.ids_rules = self.generate_rules(_ids)

    @classmethod
    def get_filters(cls, args):
        filters = set()
        if args.filter_common:
            cls.common_hdrs = set(args.filter_common)
        if args.filter:
            filters = set(args.filter)
        return cls.common_hdrs | filters

    @classmethod
    def generate_rules(self, ids) -> list:
        rules = []
        id_dom = ids["domains"][0]
        try:
            server_ip = ids["server_ip"]
        except KeyError:
            server_ip = False

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
            rules.append(
                (
                    r"\"{}\"".format(subs[field]),
                    '"[% {}.{} %]"'.format(tt, field),
                )
            )
            rules.append(
                (
                    r"primary={}([^0-9]+|$)".format(subs[field]),
                    r"primary=[% {}.{} %]\1".format(tt, field),
                )
            )
            rules.append(
                (
                    r"alias={}([^0-9]+|$)".format(subs[field]),
                    r"alias=[% {}.{} %]\1".format(tt, field),
                )
            )
            rules.append(
                (
                    r"P-First-Calle(e|r)-(U|N)PN: {}".format(subs[field]),
                    r"P-First-Calle\1-\2PN: [% {}.{} %]".format(tt, field),
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
                    r"sip:([^@]+@)?{}:{}([^\d])".format(
                        subs["ip"], subs["port"]
                    ),
                    r"sip:\1[% {0}.ip %]:[% {0}.port %]\2".format(tt),
                )
            )
            rules.append(
                (
                    r"sip:([^@]+@)?{}([^:])".format(subs["ip"]),
                    r"sip:\1[% {0}.ip %]\2".format(tt),
                )
            )

        def add_socket(scen, tt):
            rules.append(
                (
                    r";socket=(udp|tcp):{}:{}([^;>]+)".format(
                        scen["ip"], scen["port"]
                    ),
                    r";socket=\1:[% {0}.ip %]:[% {0}.port %]\2".format(tt),
                )
            )
            sdp_rule(scen["ip"], f"{tt}.ip")
            rules.append(
                (
                    r"^m=audio {} (.+)".format(scen["mport"]),
                    r"m=audio [% {}.mport %] \1".format(tt),
                )
            )
            rules.append(
                (
                    r";ip={};port={}(;?)".format(scen["ip"], scen["port"]),
                    r";ip=[% {0}.ip %];port=[% {0}.port %]\1".format(tt),
                )
            )

        if server_ip:
            rules.append(
                (
                    r";socket=(sip|udp|tcp):{}:5060".format(server_ip),
                    r";socket=\1:[% server_ip %]:5060",
                )
            )
            rules.append(
                (r"sip:([^@]+@){}".format(server_ip), r"sip:\1[% server_ip %]")
            )
            rules.append((r"sip:{}".format(server_ip), f"sip:[% server_ip %]"))
            rules.append(
                (
                    r"(udp|tcp):{}:5060".format(server_ip),
                    r"\1:[% server_ip %]:5060",
                )
            )
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
            subs = ids[id_dom][key]
            sip_rule(subs, f"{id_dom}.{key}", "phone_number")
            if "pbx_extension" in subs:
                sip_rule(subs, f"{id_dom}.{key}", "pbx_extension")
                rules.append(
                    (
                        r"^(P-.+-PBX-Ext): (.+)",
                        r"\1: [% {} %]".format(
                            f"{id_dom}.{key}.pbx_extension"
                        ),
                    )
                )
            if "pbx_phone_number" in subs:
                sip_rule(subs, f"{id_dom}.{key}", "pbx_phone_number")
            if "alias_numbers" in subs:
                for idx, alias in enumerate(subs["alias_numbers"]):
                    sip_rule(
                        alias,
                        f"{id_dom}.{key}.alias_numbers.{idx}",
                        "phone_number",
                    )
        if "phone_numbers" in ids["extra_info"]:
            numbers = ids["extra_info"]["phone_numbers"]
            for idx, phone_number in enumerate(numbers):
                sip_rule(numbers, f"extra_info.phone_numbers", idx)
        return rules

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

    def generate_common_rules(self, hdr):
        rules = []
        if hdr is None:
            rules.append((r"^a=rtcp:\d+", r"a=rtcp:\\d+"))
            rules.append((r"^m=audio \d+ (.+)", r"m=audio \\d+ \1"))
            rules.append(
                (r"<\\\?xml version=\"[^\"]+\"\\\?><dialog-info .+", "")
            )
            rules.append((r";alias=[^; ]+", r";alias=[^; ]+"))
        elif hdr in ["from", "to"]:
            rules.append((r";tag=[^;>]+", r";tag=[\\w-]+"))
        elif hdr in [
            "www-authenticate",
            "authorization",
            "proxy-authenticate",
            "proxy-authorization",
        ]:
            rules.append((r"nonce=\"[^\"]+", 'nonce="[^"]+'))
            rules.append((r"response=\"[^\"]+", 'response="[^"]+'))
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
            rules.append((r";vst=[^;>]+", r";vst=[^;]+"))
        elif hdr == "contact":
            rules.append((r"expires=[1-9]\d*", r"expires=\\d+"))
            rules.append((r";ngcpct=[^;>]+", r";ngcpct=[^;]+"))
            rules.append((r";alias=[^;>]+", r";alias=[^;]+"))
        elif hdr == "cseq":
            rules.append((r":\s+\d+", r": \\d+"))
        elif hdr == "subscription-state":
            rules.append((r";expires=[1-9]\d*", r";expires=\\d+"))
        elif hdr == "sip-if-match":
            rules.append((r": (.+)", ":"))
        return rules

    def subst_common(self, line: str, hdr: str) -> str:
        rules = self.generate_common_rules(hdr)

        for rule in rules:
            line = re.sub(rule[0], rule[1], line, flags=re.IGNORECASE)
        return line

    def subst_ids(self, line: str, hdr: str) -> str:
        for rule in self.ids_rules:
            line = re.sub(rule[0], rule[1], line, flags=re.IGNORECASE)
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
            if len(line) == 0:
                continue
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

    def run(self, info: list):
        res = []
        for msg in info:
            res.append(self.process_msg(msg))
        return res


def sipp_process(args):
    msgs = load_sipp_msg(args.input)
    ids = load_yaml(args.scen_ids)
    gen = Generator(Generator.get_filters(args), ids)
    print("messages:")
    for msg in gen.run(msgs):
        sys.stdout.write("- - '")
        sys.stdout.write(msg[0])
        sys.stdout.write("'\n")
        for idx, line in enumerate(msg[1:]):
            sys.stdout.write("  - '")
            sys.stdout.write(line)
            sys.stdout.write("'\n")


def get_msgs(info: list):
    """transform JSON sip msg in list of lines"""
    res = []
    for msg in info:
        res.append(msg.split("\r\n"))
    return res


class CFGTGenerator(Generator):
    def generate_rules(self, ids) -> list:
        id_dom = ids["domains"][0]
        rules = super(CFGTGenerator, self).generate_rules(ids)

        def add_ngcp(scen, tt):
            rules.append(
                (
                    r"^P-NGCP-(Auth|Src)-I(p|P): {}".format(scen["ip"]),
                    r"P-NGCP-\1-I\2: [% {0}.ip %]".format(tt),
                )
            )
            rules.append(
                (
                    r"^P-NGCP-Src-Port: {}".format(scen["port"]),
                    r"P-NGCP-Src-Port: [% {0}.port %]".format(tt),
                )
            )

        def add_ngcp_info(subs, tt):
            rules.append(
                (
                    r"^P(-Prev)?-Calle(r|e)-U(UID): {}".format(subs["uuid"]),
                    r"P\1-Calle\2-U\3: [% {0}.uuid %]".format(tt),
                )
            )

        def add_customer_info(cust, tt):
            rules.append(
                (
                    r"(a|b)_park_domain={}([^\d])?".format(cust["id"]),
                    r"\1_park_domain=[% {0}.id %]\2".format(tt),
                )
            )
            rules.append(
                (
                    r"^P-([^:]+): {}$".format(cust["id"]),
                    r"P-\1: [% {0}.id %]".format(tt),
                )
            )

        for idx, scen in enumerate(ids["scenarios"]):
            add_ngcp(scen, f"scenarios.{idx}")
            for jdx, resp in enumerate(scen["responders"]):
                add_ngcp(resp, f"scenarios.{idx}.responders.{jdx}")
        for key in ids[id_dom]:
            subs = ids[id_dom][key]
            add_ngcp_info(subs, f"{id_dom}.{key}")
        if "customers" in ids.keys():
            for customer_key in ids["customers"]:
                customer = ids[customer_key]
                add_customer_info(customer, f"{customer_key}")
        return rules

    def generate_common_rules(self, hdr: str) -> list:
        rules = super(CFGTGenerator, self).generate_common_rules(hdr)
        if hdr == "p-lb-uptime":
            rules.append((r":\s+(\d+)", is_zero))
        return rules


def cfgt_process(args):
    info = load_json(args.input)
    ids = load_yaml(args.scen_ids)
    gen = CFGTGenerator(Generator.get_filters(args), ids)
    print("flow:")
    for flow in info["flow"]:
        for key in flow.keys():
            print(f"  - {key}:")
    print("sip_in:")
    msgs = get_msgs(info["sip_in"])
    for msg in gen.run(msgs):
        for line in msg:
            print(f"  - '{line}'")
    if len(info["sip_out"]) > 0:
        print("sip_out:")
        msgs = get_msgs(info["sip_out"])
        for msg in gen.run(msgs):
            print("  - [")
            for line in msg:
                print(f"      '{line}',")
            print("    ]")
    else:
        print("sip_out: []")


def main(args):
    if args.type == "sipp":
        sipp_process(args)
    else:
        cfgt_process(args)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="generate test_yml.tt2 files")
    parser.add_argument(
        "scen_ids", help="path to the scenario_ids.yml file", type=Path
    )
    parser.add_argument("input", help="path to the input file", type=Path)
    parser.add_argument("--filter", nargs="?", help="remove this header")
    parser.add_argument("--filter-common", help="filter common headers")
    parser.add_argument(
        "--type",
        "-t",
        choices=["sipp", "cfgt"],
        default="sipp",
        help="type of input file",
    )
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
