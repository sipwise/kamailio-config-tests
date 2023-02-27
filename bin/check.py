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
import io
import sys
import re
import argparse
import json
import logging
from enum import Flag

from yaml import load

try:
    from yaml import CLoader as Loader
except ImportError:
    from yaml import Loader


class XAvp:

    """Class to simulate the xavp"""

    def __init__(self, name, data):
        result = re.match(r"\$xavp\(([\w\:-]+)\)", name)
        try:
            self._name = result.group(1)
        except Exception:
            raise Exception("not a xavp")
        self._data = data

    def get(self, str):
        info = XAvp.parse(str)

        if self._name != info["name"]:
            msg = "diferent name. name:{} != {}"
            raise KeyError(msg.format(self._name, info["name"]))

        nsize = len(self._data)
        if nsize <= info["nindx"]:
            raise IndexError("%s has %d elements" % (self._name, nsize))

        if info["key"] in self._data[info["nindx"]]:
            values = self._data[info["nindx"]][info["key"]]
        else:
            raise KeyError("no %s key found" % info["key"])

        if info["kindx"] == "*":
            return values

        ksize = len(values)
        if ksize <= info["kindx"]:
            msg = "{} has {} elements not {}"
            raise IndexError(msg.format(info["key"], ksize, info["kindx"]))

        return values[info["kindx"]]

    @classmethod
    def parse(cls, str):
        pattern_nindx = r"(\[(?P<%s>\d+)\])?" % "nindx"
        pattern_kindx = r"(\[(?P<%s>\d+|\*+)\])?" % "kindx"
        pattern = r"\$xavp\((?P<name>[\w\:-]+)%s(=>(?P<key>[\w\:-]+)%s)?\)" % (
            pattern_nindx,
            pattern_kindx,
        )
        result = re.match(pattern, str)
        if result is not None:
            try:
                nindx = int(result.group("nindx"))
            except Exception:
                nindx = 0
            try:
                kindx = int(result.group("kindx"))
            except Exception:
                if result.group("kindx") == "*":
                    kindx = "*"
                else:
                    kindx = 0
            return {
                "name": result.group("name"),
                "nindx": nindx,
                "key": result.group("key"),
                "kindx": kindx,
            }
        else:
            raise Exception("no xavp")


class Section(Flag):
    FLOW = 2
    FLOW_VARS = 4
    SIP_IN = 8
    SIP_OUT = 16


class Test:

    """Class to create TAP output"""

    def __init__(self):
        self._step = []
        self._errflag = Section(0)

    def comment(self, msg):
        """Add a comment"""
        self._step.append({"result": None, "msg_ok": msg})

    def ok(self, msg=None):
        """Add a ok result"""
        self._step.append({"result": True, "msg_ok": msg})

    def error(self, section, msg_err):
        """Add an error result"""
        self._step.append({"result": False, "msg_err": msg_err})
        self._errflag |= section

    @classmethod
    def compare(cls, val0, val1):
        logging.debug(
            "val0:[%s]:'%s' val1:[%s]:'%s'"
            % (type(val0), str(val0), type(val1), str(val1))
        )
        if isinstance(val0, str):
            if re.search(val0, str(val1)) is not None:
                return True
            else:
                return False
        elif isinstance(val0, int):
            try:
                result = val0 == int(val1)
            except Exception:
                result = False
        elif isinstance(val0, list) and isinstance(val1, list):
            size = len(val0)
            if size != len(val1):
                return False
            result = True
            for k in range(size):
                try:
                    result = result and cls.compare(val0[k], val1[k])
                except Exception as e:
                    logging.debug(e)
                    return False
        else:
            result = val0 == val1
        return result

    def test(self, section, value_expected, value, msg_err, msg_ok=None):
        """Test two values and add the result"""
        result = Test.compare(value_expected, value)
        val = {"result": result, "msg_err": msg_err, "msg_ok": msg_ok}
        self._step.append(val)
        if not result:
            self._errflag |= section

    def isError(self):
        return self._errflag.value != 0

    def _num_tests(self):
        """get the num of tests"""
        test = 0
        for s in self._step:
            if s["result"] is not None:
                test = test + 1
        return test

    def __str__(self):
        """get the TAP output"""
        output = "1..%s\n" % self._num_tests()
        test = 1
        for s in self._step:
            if s["result"] is None:
                output += "# %s\n" % s["msg_ok"]
                continue
            elif s["result"]:
                if s["msg_ok"] is not None:
                    output += "ok %d - %s\n" % (test, s["msg_ok"])
                else:
                    output += "ok %d\n" % test
            else:
                output += "not ok %d - ERROR: %s\n" % (test, s["msg_err"])
            test = test + 1
        return output


def check_flow_vars(sk, sv, cv, test):
    """check the vars on a flow level"""
    sec = Section.FLOW_VARS
    for k in sv.keys():
        logging.debug("check k:'%s'" % k)
        if k not in cv:
            try:
                info = XAvp.parse(k)
                search_key = "$xavp(%s)" % info["name"]
                if search_key not in cv:
                    msg = "search_key: {} info:{}"
                    raise Exception(msg.format(search_key, info))
                xavp = XAvp(search_key, cv[search_key])
                val = xavp.get(k)
                logging.debug("testing %s == %s" % (sv[k], val))
                msg_err = "flow[{}] expected {} == {} but is {}"
                test.test(
                    sec,
                    sv[k],
                    val,
                    msg_err.format(sk, k, sv[k], val),
                    "flow[{}] {}".format(sk, k),
                )
            except LookupError as err:
                if sv[k] == "None":
                    test.ok("flow[%s] %s is not there" % (sk, k))
                else:
                    test.error(sec, "LookupError with %s. Error:%s" % (k, err))
            except Exception as err:
                if sv[k] == "None":
                    test.ok("flow[%s] %s is not there" % (sk, k))
                else:
                    msg = "Expected var {} on flow[{}]. {}"
                    test.error(sec, msg.format(k, sk, err))
        else:
            logging.debug("sv[k]:'%s' cv[k]:'%s'" % (sv[k], cv[k]))
            msg_err = "flow[{}] expected {} == {} but is {}"
            test.test(
                sec,
                sv[k],
                cv[k],
                msg_err.format(sk, k, sv[k], cv[k]),
                "flow[%s] %s" % (sk, k),
            )


def check_flow(scen, check, test):
    """checks the flow and the vars inside"""
    sec = Section.FLOW
    for i in range(len(scen)):
        (sk, sv) = scen[i].popitem()
        try:
            (ck, cv) = check[i].popitem()
        except Exception:
            msg = "wrong flow. Expected: {} but is nothing there"
            test.error(sec, msg.format(sk))
            continue
        if sk != ck:
            test.error(sec, "wrong flow. Expected: %s but is %s" % (sk, ck))
            continue
        if sv is None:
            test.ok("flow[%s] no var to check" % sk)
            continue
        else:
            test.ok("flow[%s]" % sk)
        check_flow_vars(sk, sv, cv, test)
    if len(check) > len(scen):
        line = []
        for i in check:
            for k in i.keys():
                line.append(k)
        test.error(sec, "Expected to end but there are more flows %s" % line)


def check_sip(sec, scen, msg, test):
    if isinstance(msg, list):
        if len(msg) != 1:
            test.error(sec, "sip_in len != 1")
            return
        else:
            msg = msg[0]
    for rule in scen:
        if rule.startswith("_:NOT:_"):
            flag = False
            rule = rule[7:]
            msg_ok = "%s not match"
            msg_ko = "%s match"
        else:
            flag = True
            msg_ok = "%s match"
            msg_ko = "%s not match"
        result = re.search(rule, msg)
        if (result is not None) == flag:
            test.ok(msg_ok % rule)
            continue
        test.comment("result:%s" % result)
        test.error(sec, msg_ko % rule)


def check_sip_out(sec, scen, msgs, test):
    num_msgs = len(msgs)
    num_scen = len(scen)
    for i in range(num_scen):
        test.comment("sip_out %d" % i)
        if i < num_msgs:
            check_sip(sec, scen[i], msgs[i], test)
        else:
            test.error(sec, "sip_out[%d] does not exist" % i)
    if num_scen != num_msgs:
        msg = "we expected {} out messages but we have {}"
        test.error(sec, msg.format(num_scen, num_msgs))


def load_yaml(filepath):
    output = None
    with io.open(filepath, "r") as file:
        output = load(file, Loader=Loader)
    file.close()
    return output


def load_json(filepath):
    output = None
    with io.open(filepath, "r") as file:
        output = json.load(file)
    file.close()
    return output


def main(args):
    if args.debug:
        logging.basicConfig(level=logging.DEBUG)

    scen = load_yaml(args.test_yaml_file)

    test = Test()

    try:
        check = load_json(args.kam_file)
    except Exception:
        check = {"flow": [], "sip_in": "", "sip_out": []}
        test.error(Section.FLOW, "Error loading file:%s" % args.kam_file)

    test.comment("check flow")
    check_flow(scen["flow"], check["flow"], test)
    test.comment("check sip_in")
    check_sip(Section.SIP_IN, scen["sip_in"], check["sip_in"], test)
    test.comment("check sip_out")
    check_sip_out(Section.SIP_OUT, scen["sip_out"], check["sip_out"], test)
    test.comment(test._errflag)
    print(test)
    if test.isError():
        sys.exit(test._errflag.value)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="generate TAP result")
    parser.add_argument("test_yaml_file", help="YAML file with checks")
    parser.add_argument("kam_file", help="JSON cfgt kamailio file")
    parser.add_argument("-d", "--debug", action="store_true")
    args = parser.parse_args()
    main(args)
