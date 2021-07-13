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
import re
import argparse
import subprocess
from yaml import load, dump

try:
    from yaml import CLoader as Loader, CDumper as Dumper
except ImportError:
    from yaml import Loader, Dumper


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
    return r": \\d+"


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

        def add_sip_username(val, tt):
            rules.append(
                (r"<sip:{}@".format(val), r"<sip:[% {} %]@".format(tt))
            )

        for subs in ids[id_dom]:
            add_sip_username(
                ids[id_dom][subs]["phone_number"],
                r"{}.{}.phone_number".format(id_dom, subs),
            )
        for idx, scen in enumerate(ids["scenarios"]):
            add_sip_username(
                scen["username"], r"scenarios.{}.username".format(idx)
            )
            if scen["devid"] != scen["username"]:
                add_sip_username(
                    scen["devid"], r"scenarios.{}.devid".format(idx)
                )
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
            pass
        elif hdr in ["from", "to"]:
            rules.append((r";tag=[^;]+", r";tag=[\\w-]+"))
        elif hdr == "www-authenticate":
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
        for rule in rules:
            line = re.sub(rule[0], rule[1], line, flags=re.IGNORECASE)
        return line

    def subst_ids(self, line, hdr):
        for rule in self.ids_rules:
            line = re.sub(rule[0], rule[1], line)
        return line

    def process_msg(self, msg):
        res = []
        for line in msg:
            ok, hdr = self.filter_hdr(line)
            if ok:
                continue
            l_common = self.subst_common(line, hdr)
            l_ids = self.subst_ids(l_common, hdr)
            if line != l_ids:
                logging.info("line:{} => {}".format(line, l_ids))
            l = l_ids.replace("\n", "")
            if len(l) > 0:
                res.append(l)
        return res

    def __str__(self):
        res = {"messages": []}
        for msg in self.msgs:
            res["messages"].append(self.process_msg(msg))
        return dump(res, Dumper=Dumper)


def main(args):
    msgs = load_msg(args.sipp_msg)
    ids = load_yaml(args.scen_ids)
    g = Generator(Generator.get_filters(args), msgs, ids)
    print(g)


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
