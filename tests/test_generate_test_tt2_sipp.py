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
import sys
import logging
import filecmp
import difflib

IDS_FILE = "tests/fixtures/{}/scenario_ids.yml"
MSG_FILE = "tests/fixtures/{}/sipp_scenario{}.msg"
TT2_FILE = "tests/fixtures/{}/sipp_scenario{}_test.yml.tt2"


def check_filecontent(a, b):
    with open(a, "r") as fa, open(b, "r") as fb:
        lines_a = fa.readlines()
        lines_b = fb.readlines()
    diff = difflib.unified_diff(lines_a, lines_b, a, str(b))
    sys.stderr.write("diff:\n")
    sys.stderr.writelines(diff)
    return filecmp.cmp(a, b)


def test_ok_auth_fail(generate_test_tt2_file, caplog):
    caplog.set_level(logging.DEBUG)
    res = generate_test_tt2_file(
        IDS_FILE.format("auth_fail"), MSG_FILE.format("auth_fail", "00")
    )

    assert check_filecontent(TT2_FILE.format("auth_fail", "00"), res.out_file)
    assert res.returncode == 0


def test_ok_incoming_foreign_dom(generate_test_tt2_file, caplog):
    caplog.set_level(logging.DEBUG)
    res = generate_test_tt2_file(
        IDS_FILE.format("incoming_foreign_dom"),
        MSG_FILE.format("incoming_foreign_dom", "00"),
    )

    assert check_filecontent(
        TT2_FILE.format("incoming_foreign_dom", "00"), res.out_file
    )
    assert res.returncode == 0


def test_ok_incoming_foreign_dom_resp(generate_test_tt2_file, caplog):
    caplog.set_level(logging.DEBUG)
    res = generate_test_tt2_file(
        IDS_FILE.format("incoming_foreign_dom"),
        MSG_FILE.format("incoming_foreign_dom", "_responder00"),
    )

    assert check_filecontent(
        TT2_FILE.format("incoming_foreign_dom", "_responder00"), res.out_file
    )
    assert res.returncode == 0


def test_ok_invite_redirect_tel_uri(generate_test_tt2_file, caplog):
    caplog.set_level(logging.DEBUG)
    res = generate_test_tt2_file(
        IDS_FILE.format("invite_redirect_tel_uri"),
        MSG_FILE.format("invite_redirect_tel_uri", "00"),
    )

    assert check_filecontent(
        TT2_FILE.format("invite_redirect_tel_uri", "00"), res.out_file
    )
    assert res.returncode == 0


def test_invite_redirect_tel_uri_resp(generate_test_tt2_file, caplog):
    caplog.set_level(logging.DEBUG)
    res = generate_test_tt2_file(
        IDS_FILE.format("invite_redirect_tel_uri"),
        MSG_FILE.format("invite_redirect_tel_uri", "_responder00"),
    )

    assert check_filecontent(
        TT2_FILE.format("invite_redirect_tel_uri", "_responder00"),
        res.out_file,
    )
    assert res.returncode == 0

    res = generate_test_tt2_file(
        IDS_FILE.format("invite_redirect_tel_uri"),
        MSG_FILE.format("invite_redirect_tel_uri", "_responder01"),
    )

    assert check_filecontent(
        TT2_FILE.format("invite_redirect_tel_uri", "_responder01"),
        res.out_file,
    )
    assert res.returncode == 0


def test_ok_incoming_hih(generate_test_tt2_file, caplog):
    caplog.set_level(logging.DEBUG)
    res = generate_test_tt2_file(
        IDS_FILE.format("incoming_hih"), MSG_FILE.format("incoming_hih", "00")
    )

    assert check_filecontent(
        TT2_FILE.format("incoming_hih", "00"), res.out_file
    )
    assert res.returncode == 0


def test_incoming_hih_resp(generate_test_tt2_file, caplog):
    caplog.set_level(logging.DEBUG)
    res = generate_test_tt2_file(
        IDS_FILE.format("incoming_hih"),
        MSG_FILE.format("incoming_hih", "_responder01"),
    )

    assert check_filecontent(
        TT2_FILE.format("incoming_hih", "_responder01"), res.out_file
    )
    assert res.returncode == 0


def test_mix(generate_test_tt2_file, caplog):
    caplog.set_level(logging.DEBUG)
    res = generate_test_tt2_file(
        IDS_FILE.format("mix"), MSG_FILE.format("mix", "00")
    )

    assert check_filecontent(TT2_FILE.format("mix", "00"), res.out_file)
    assert res.returncode == 0


def test_mix_alias(generate_test_tt2_file, caplog):
    caplog.set_level(logging.DEBUG)
    res = generate_test_tt2_file(
        IDS_FILE.format("mix"), MSG_FILE.format("mix", "01")
    )

    assert check_filecontent(TT2_FILE.format("mix", "01"), res.out_file)
    assert res.returncode == 0


def test_mix_resp(generate_test_tt2_file, caplog):
    caplog.set_level(logging.DEBUG)
    res = generate_test_tt2_file(
        IDS_FILE.format("mix"), MSG_FILE.format("mix", "_responder00")
    )

    assert check_filecontent(
        TT2_FILE.format("mix", "_responder00"), res.out_file
    )
    assert res.returncode == 0


def test_ok_invite_alias_devid(generate_test_tt2_file, caplog):
    caplog.set_level(logging.DEBUG)
    for i in range(0, 3):
        res = generate_test_tt2_file(
            IDS_FILE.format("invite_alias_devid"),
            MSG_FILE.format("invite_alias_devid", f"0{i}"),
        )

        assert check_filecontent(
            TT2_FILE.format("invite_alias_devid", f"0{i}"), res.out_file
        )
        assert res.returncode == 0


def test_invite_alias_devid_resp(generate_test_tt2_file, caplog):
    caplog.set_level(logging.DEBUG)
    res = generate_test_tt2_file(
        IDS_FILE.format("invite_alias_devid"),
        MSG_FILE.format("invite_alias_devid", "_responder02"),
    )

    assert check_filecontent(
        TT2_FILE.format("invite_alias_devid", "_responder02"), res.out_file
    )
    assert res.returncode == 0


def test_ok_incoming_peer(generate_test_tt2_file, caplog):
    caplog.set_level(logging.DEBUG)
    res = generate_test_tt2_file(
        IDS_FILE.format("incoming_peer"),
        MSG_FILE.format("incoming_peer", "00"),
    )

    assert check_filecontent(
        TT2_FILE.format("incoming_peer", "00"), res.out_file
    )
    assert res.returncode == 0


def test_incoming_peer_resp(generate_test_tt2_file, caplog):
    caplog.set_level(logging.DEBUG)
    res = generate_test_tt2_file(
        IDS_FILE.format("incoming_peer"),
        MSG_FILE.format("incoming_peer", "_responder00"),
    )

    assert check_filecontent(
        TT2_FILE.format("incoming_peer", "_responder00"), res.out_file
    )
    assert res.returncode == 0


def test_ok_incoming_shared_line(generate_test_tt2_file, caplog):
    caplog.set_level(logging.DEBUG)
    res = generate_test_tt2_file(
        IDS_FILE.format("incoming_shared_line"),
        MSG_FILE.format("incoming_shared_line", "00"),
    )

    assert check_filecontent(
        TT2_FILE.format("incoming_shared_line", "00"), res.out_file
    )
    assert res.returncode == 0

    res = generate_test_tt2_file(
        IDS_FILE.format("incoming_shared_line"),
        MSG_FILE.format("incoming_shared_line", "01"),
    )

    assert check_filecontent(
        TT2_FILE.format("incoming_shared_line", "01"), res.out_file
    )
    assert res.returncode == 0

    res = generate_test_tt2_file(
        IDS_FILE.format("incoming_shared_line"),
        MSG_FILE.format("incoming_shared_line", "02"),
    )

    assert check_filecontent(
        TT2_FILE.format("incoming_shared_line", "02"), res.out_file
    )
    assert res.returncode == 0


def test_incoming_shared_line_resp(generate_test_tt2_file, caplog):
    caplog.set_level(logging.DEBUG)
    res = generate_test_tt2_file(
        IDS_FILE.format("incoming_shared_line"),
        MSG_FILE.format("incoming_shared_line", "_responder00"),
    )

    assert check_filecontent(
        TT2_FILE.format("incoming_shared_line", "_responder00"),
        res.out_file,
    )
    assert res.returncode == 0

    res = generate_test_tt2_file(
        IDS_FILE.format("incoming_shared_line"),
        MSG_FILE.format("incoming_shared_line", "_responder01"),
    )

    assert check_filecontent(
        TT2_FILE.format("incoming_shared_line", "_responder01"),
        res.out_file,
    )
    assert res.returncode == 0

    res = generate_test_tt2_file(
        IDS_FILE.format("incoming_shared_line"),
        MSG_FILE.format("incoming_shared_line", "_responder02"),
    )

    assert check_filecontent(
        TT2_FILE.format("incoming_shared_line", "_responder02"),
        res.out_file,
    )
    assert res.returncode == 0

    res = generate_test_tt2_file(
        IDS_FILE.format("incoming_shared_line"),
        MSG_FILE.format("incoming_shared_line", "_responder03"),
    )

    assert check_filecontent(
        TT2_FILE.format("incoming_shared_line", "_responder03"),
        res.out_file,
    )
    assert res.returncode == 0
