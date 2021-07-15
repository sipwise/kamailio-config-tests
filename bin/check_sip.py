#!/usr/bin/python3
#
# Copyright: 2013-2021 Sipwise Development Team <support@sipwise.com>
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
from pathlib import Path

from yaml import load

try:
    from yaml import CLoader as Loader
except ImportError:
    from yaml import Loader


class Section(Flag):
    SIP = 32


class Test:

    """ Class to create TAP output """

    def __init__(self):
        self._step = []
        self._errflag = Section(0)

    def comment(self, msg):
        """ Add a comment """
        self._step.append({"result": None, "msg_ok": msg})

    def ok(self, msg=None):
        """ Add a ok result """
        self._step.append({"result": True, "msg_ok": msg})

    def error(self, section, msg_err):
        """ Add an error result"""
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
        """ Test two values and add the result"""
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


def check_sip_received(sec, scen, msgs, test):
    num_msgs = len(msgs)
    num_scen = len(scen)
    for i in range(num_scen):
        test.comment("messages %d" % i)
        if i < num_msgs:
            check_sip(sec, scen[i], msgs[i], test)
        else:
            test.error(sec, "messages[%d] does not exist" % i)
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


def convert_sippmsg_to_json(filepath):
    file_content = open(filepath, "r")
    c = file_content.read()

    # prepare a list of sipp generated messages (raw text now)
    content_list = c.split("-----------------------------------------------")
    content_list_received = []
    file_content.close()

    # now pick out only received sipp messages
    for each in content_list:
        if ("UDP message received" in each) or (
            "TCP message received" in each
        ):
            # delete all undesired lines from each memeber's raw text
            each = each.replace("\n\n\n", "\n").replace("\n\n", "\n")
            each = each.replace('"', '\\"')
            each = each.split("\n")[2:]

            i, arrLen = 0, len(each)
            while i < arrLen:
                each[i] = each[i] + "\\r\\n"
                i += 1

            # make a raw text now from list
            each = "".join(each)
            content_list_received.append(each)

    # add some eventual formatting to implement a JSON syntax
    i, arrLen = 0, len(content_list_received)
    while i < arrLen:
        content_list_received[i] = '"' + content_list_received[i] + '",'
        i += 1
    output = "".join(content_list_received)[:-1]
    return '{\n  "messages": [' + output + "]\n}"


def main(args):

    # convert sipp msg into json format, returns only received messages
    output = convert_sippmsg_to_json(args.msg_file)

    if args.debug:
        logging.basicConfig(level=logging.DEBUG)

    test = Test()
    try:
        scen = load_yaml(args.test_file)
    except Exception:
        scen = "message:\n  - ['']"
        test.error("Error loading yaml file:%s" % args[1])

    try:
        check = json.loads(output)
    except Exception:
        check = {"messages": ""}
        test.error("Error loading json file:%s" % args[1])

    test.comment("check sip messages")
    check_sip_received(Section.SIP, scen["messages"], check["messages"], test)

    print(test)
    if test.isError():
        sys.exit(test._errflag.value)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="generate TAP result")
    parser.add_argument("test_file", help="YAML file with checks")
    parser.add_argument("msg_file", help="sipp file")
    parser.add_argument("-d", "--debug", action="store_true")
    args = parser.parse_args()
    main(args)
