#!/usr/bin/python3
#
# Copyright: 2013-2020 Sipwise Development Team <support@sipwise.com>
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
import junitxml
import unittest
import re

lib_path = os.path.abspath("bin")
sys.path.append(lib_path)
from check import Section  # noqa
from check import check_sip, check_sip_out  # noqa
from check import XAvp, Test, check_flow, check_flow_vars  # noqa
from check import load_json, load_yaml  # noqa

not_ok = re.compile("^not ok.*", re.MULTILINE)


class TestXAvp(unittest.TestCase):
    def setUp(self):
        self.name = "test"
        self.data = [
            {"koko": [1]}, {"koko": [1, 2]}, {"lolo": [3], "lola": [7]}
        ]
        self.xavp = XAvp("$xavp(%s)" % self.name, self.data)

    def test_init(self):
        self.assertEqual(self.name, self.xavp._name)
        self.assertCountEqual(self.data, self.xavp._data)

    def test_init_wrong_type(self):
        self.assertRaises(Exception, self.xavp, "$var(whatever)", None)

    def test_parse_type(self):
        self.assertRaisesRegex(
            Exception, "no xavp", XAvp.parse, "$var(whatever)"
        )
        self.assertRaisesRegex(Exception, "no xavp", XAvp.parse, "$fU")

    def test_get_wrong_name(self):
        self.assertRaises(KeyError, self.xavp.get, "$xavp(otro)")
        self.assertRaises(KeyError, self.xavp.get, "$xavp(otro[0])")
        self.assertRaises(KeyError, self.xavp.get, "$xavp(otro=>whatever)")
        self.assertRaises(KeyError, self.xavp.get, "$xavp(otro[0]=>whatever)")

    def test_get_wrong_nindx(self):
        self.assertRaises(IndexError, self.xavp.get, "$xavp(test[10]=>koko)")
        self.assertRaises(
            IndexError, self.xavp.get, "$xavp(test[10]=>koko[1])"
        )

    def test_get_wrong_kindx(self):
        self.assertRaises(IndexError, self.xavp.get, "$xavp(test[0]=>koko[1])")
        self.assertRaises(
            IndexError, self.xavp.get, "$xavp(test[1]=>koko[10])"
        )

    def test_get_value(self):
        self.assertEqual(self.xavp.get("$xavp(test=>koko)"), 1)
        self.assertEqual(self.xavp.get("$xavp(test[1]=>koko[1])"), 2)
        self.assertEqual(self.xavp.get("$xavp(test[2]=>lola[0])"), 7)

    def test_get_value_all(self):
        self.assertCountEqual(self.xavp.get("$xavp(test[1]=>koko[*])"), [1, 2])


class TestCheckFlowVars(unittest.TestCase):
    def setUp(self):
        self.ctest = Test()
        self.check_ok = [
            {
                "R0": {
                    "$xavp(v0)": [
                        {"k0": [1], "k1": ["a", "b", "fuckthisshit"]},
                        {"k0": [1, 2], "k1": ["a"]},
                    ],
                    "fU": "testpep",
                }
            },
            {"R1": {"$xavp(v0)": [{"k0": [1, 2]}]}},
        ]
        self.check_ko = [{"R0": {"$xavp(v0)": [{"k0": ["a", "b"]}]}}]
        self.scen_ko = [{"R0": {"$xavp(v0[0]=>k0[*])": ["a"]}}]
        self.scen_noxavp = [{"R0": {"fU": "testpep"}}, {"R1": {}}]
        self.scen = [
            {
                "R0": {
                    "$xavp(v0[0]=>k0[0])": 1,
                    "$xavp(v0[0]=>k1[0])": "a",
                    "$xavp(v0[0]=>k1[2])": "^f",
                    "$var(no)": "None",
                    "$xavp(nono=>koko)": "None",
                    "$xavp(v0=>k10)": "None",
                    "$xavp(v0[1]=>k0[1])": r"\d+",
                    "$xavp(v0[0]=>k1[*])": ["a", "b", "fuckthisshit"],
                }
            },
            {"R1": {"$xavp(v0[1]=>k0[0])": 1}},
        ]

    def testXAvp(self):
        data = self.check_ok[0]["R0"]["$xavp(v0)"]
        xavp = XAvp("$xavp(v0)", data)

        self.assertEqual(xavp.get("$xavp(v0=>k0)"), 1)
        self.assertEqual(
            xavp.get("$xavp(v0[0]=>k1[*])"), ["a", "b", "fuckthisshit"]
        )
        self.assertEqual(xavp.get("$xavp(v0[1]=>k0[1])"), 2)
        self.assertEqual(xavp.get("$xavp(v0[1]=>k1[*])"), ["a"])

    def testFlow_noxavp(self):
        check_flow(self.scen_noxavp, self.check_ok, self.ctest)
        self.assertFalse(self.ctest.isError())

    def testFlowVars_noxavp(self):
        check_flow_vars(
            "RO", self.scen_noxavp[0]["R0"], self.check_ok[0]["R0"], self.ctest
        )
        self.assertFalse(self.ctest.isError())

    def testFlowVars_xavp(self):
        check_flow_vars(
            "RO", self.scen[0]["R0"], self.check_ok[0]["R0"], self.ctest
        )
        self.assertFalse(self.ctest.isError())

    def testFlow_fail(self):
        check_flow(self.scen_ko, self.check_ko, self.ctest)
        tap = str(self.ctest)
        self.assertTrue(self.ctest.isError(), tap)
        self.assertIsNotNone(not_ok.search(tap), tap)

    def testFlowVars_fail(self):
        check_flow_vars(
            "RO", self.scen_ko[0]["R0"], self.check_ko[0]["R0"], self.ctest
        )
        tap = str(self.ctest)
        self.assertTrue(self.ctest.isError(), tap)
        self.assertIsNotNone(not_ok.search(tap), tap)


class TestCheckSipIn(unittest.TestCase):
    def setUp(self):
        self.ctest = Test()
        self.msg = open("./tests/fixtures/sip_in.txt", "r").read()

    def testSipIn(self):
        sip_in = load_yaml("./tests/fixtures/test_sip_in.yml")
        check_sip(Section.SIP_IN, sip_in, self.msg, self.ctest)
        self.assertFalse(self.ctest.isError())


class TestCheckSipOut(unittest.TestCase):
    def setUp(self):
        self.ctest = Test()
        self.msg = load_yaml("./tests/fixtures/sip_out.yml")

    def testSipOut(self):
        sip_out = load_yaml("./tests/fixtures/test_sip_out.yml")
        check_sip_out(Section.SIP_OUT, sip_out, self.msg, self.ctest)
        self.assertFalse(self.ctest.isError())


class TestJson(unittest.TestCase):
    def setUp(self):
        self.ctest = Test()

    def testFail(self):
        check = load_json("./tests/fixtures/fail.json")
        scen = load_yaml("./tests/fixtures/scen_fail.yml")
        check_flow(scen["flow"], check["flow"], self.ctest)
        tap = str(self.ctest)
        self.assertTrue(self.ctest.isError(), tap)
        self.assertIsNotNone(not_ok.search(tap), tap)


if __name__ == "__main__":

    suite = unittest.TestSuite()
    load = unittest.defaultTestLoader.loadTestsFromTestCase
    suite.addTest(load(TestXAvp))
    suite.addTest(load(TestCheckFlowVars))
    suite.addTest(load(TestCheckSipIn))
    suite.addTest(load(TestCheckSipOut))
    suite.addTest(load(TestJson))
    result = junitxml.JUnitXmlResult(sys.stdout)
    result.startTestRun()
    suite.run(result)
    result.stopTestRun()
