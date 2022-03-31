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
MSG_FILE = "tests/fixtures/{}/{}.json"
TT2_FILE = "tests/fixtures/{}/{}_test.yml.tt2"


def check_filecontent(a, b):
    with open(a, "r") as fa, open(b, "r") as fb:
        lines_a = fa.readlines()
        lines_b = fb.readlines()
    diff = difflib.unified_diff(lines_a, lines_b, a, str(b))
    sys.stderr.write("diff:\n")
    sys.stderr.writelines(diff)
    return filecmp.cmp(a, b)


def test_invite_alias(generate_test_tt2_file, caplog):
    caplog.set_level(logging.DEBUG)
    scenario = "invite_alias"
    for id in ["0002", "0003", "0006", "0017", "0018"]:
        res = generate_test_tt2_file(
            "--type=cfgt",
            IDS_FILE.format(scenario),
            MSG_FILE.format(scenario, id),
        )

        assert check_filecontent(TT2_FILE.format(scenario, id), res.out_file)
        assert res.returncode == 0
