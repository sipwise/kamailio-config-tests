#!/usr/bin/python3
#
# Copyright: 2021-2022 Sipwise Development Team <support@sipwise.com>
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
import os
import sys
import logging
from collections import namedtuple


lib_path = os.path.abspath("bin")
sys.path.append(lib_path)

from generate_test_tt2 import load_sipp_msg, load_yaml  # noqa
from generate_test_tt2 import Generator  # noqa

Args = namedtuple(
    "GenratorArgs", ["scen_ids", "sipp_msg", "filter", "filter_common"]
)

IDS_FILE = "tests/fixtures/{}/scenario_ids.yml"
MSG_FILE = "tests/fixtures/{}/sipp_scenario{}.msg"


def test_load_sipp_msg():
    res = load_sipp_msg(MSG_FILE.format("auth_fail", "00"))

    for i in range(len(res)):
        print("res[{}][0]:{}".format(i, res[i][0]))

    assert len(res) == 5
    for i in range(4):
        assert res[i][0] == "SIP/2.0 401 Unauthorized\n"
        assert len(res[i]) == 11
    assert res[4][0] == "SIP/2.0 403 Try again later\n"
    assert len(res[4]) == 10
    for i in range(5):
        assert (
            res[i][2] == "From: <sip:testuser1003@"
            "auth-fail.scenarios.test>;tag=29092SIPpTag001\n"
        )


def test_get_header():
    hdr = Generator.get_header(
        "ViA: SIP/2.0/UDP 10.20.29.2:51602"
        ";rport=51602;branch=z9hG4bK-29092-1-6"
    )
    assert hdr == "via"
    assert Generator.get_header("not a header...no no via:") == None


def test_sipp_filter_hdr():
    msgs = load_sipp_msg(MSG_FILE.format("auth_fail", "00"))
    ids = load_yaml(IDS_FILE.format("auth_fail", "00"))
    g = Generator(Generator.common_hdrs, ids)
    assert g.filter_hdr(
        "ViA: SIP/2.0/UDP 10.20.29.2:51602;"
        "rport=51602;branch=z9hG4bK-29092-1-6"
    )
    assert g.filter_hdr("SIP/2.0 401 Unauthorized") == (False, None)
    assert g.filter_hdr("CSeq: 1 REGISTER") == (False, "cseq")


def test_process_sipp_msg():
    msgs = load_sipp_msg(MSG_FILE.format("auth_fail", "00"))
    ids = load_yaml(IDS_FILE.format("auth_fail", "00"))
    g = Generator(Generator.common_hdrs, ids)
    res = g.process_msg(msgs[0])
    assert len(res) == 7


def test_empty_args(generate_test_tt2):
    res = generate_test_tt2("--filter", "CSeq")
    assert res.returncode != 0


def test_hdrs_common():
    assert len(Generator.common_hdrs) == 5


def test_get_filters(generate_test_tt2):
    args = Args(None, None, ["CSeq", "WWW-Authenticate"], None)
    res = Generator.get_filters(args)

    assert res == set(
        [
            "CSeq",
            "WWW-Authenticate",
            "Via",
            "Route",
            "Call-ID",
            "Expires",
            "Max-Forwards",
        ]
    )
    assert Generator.common_hdrs == set(
        ["Via", "Route", "Call-ID", "Expires", "Max-Forwards"]
    )

    args = Args(None, None, None, None)
    res = Generator.get_filters(args)
    assert Generator.common_hdrs == set(
        ["Via", "Route", "Call-ID", "Expires", "Max-Forwards"]
    )
