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

from yaml import load

try:
    from yaml import CLoader as Loader
except ImportError:
    from yaml import Loader


class Test:

    """ Class to create TAP output """

    def __init__(self):
        self._step = []
        self._errflag = False

    def comment(self, msg):
        """ Add a comment """
        self._step.append({"result": None, "msg_ok": msg})

    def ok(self, msg=None):
        """ Add a ok result """
        self._step.append({"result": True, "msg_ok": msg})

    def error(self, msg_err):
        """ Add an error result"""
        self._step.append({"result": False, "msg_err": msg_err})
        self._errflag = True

    @classmethod
    def compare(cls, val0, val1):
        logging.debug(
            "val0:[{}]:'{}' val1:[{}]:'{}'".format(
                type(val0), str(val0), type(val1), str(val1)
            )
        )
        if isinstance(val0, str):
            if re.search(val0, str(val1)) is not None:
                return True
            else:
                return False
        elif isinstance(val0, int):
            try:
                result = val0 == int(val1)
            except ValueError:
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

    def test(self, value_expected, value, msg_err, msg_ok=None):
        """ Test two values and add the result"""
        result = Test.compare(value_expected, value)
        self._step.append(
            {"result": result, "msg_err": msg_err, "msg_ok": msg_ok}
        )
        if not result:
            self._errflag = True

    def isError(self):
        return self._errflag

    def _num_tests(self):
        """get the num of tests"""
        test = 0
        for s in self._step:
            if s["result"] is not None:
                test = test + 1
        return test

    def __str__(self):
        """get the TAP output"""
        output = "1..{}\n".format(self._num_tests())
        test = 1
        for s in self._step:
            if s["result"] is None:
                output += "# {}\n".format(s["msg_ok"])
                continue
            elif s["result"]:
                if s["msg_ok"] is not None:
                    output += "ok {} - {}\n".format(test, s["msg_ok"])
                else:
                    output += "ok {}\n".format(test)
            else:
                output += "not ok {} - ERROR: {}\n".format(test, s["msg_err"])
            test = test + 1
        return output


def check_single_cdr_recursive(scen, msg):
    validated = True
    comments = []
    oks = []
    match_msg = ["{}:{} not match {}", "{}:{} match {}"]
    for rule, value in scen.items():
        value = str(value)
        if rule not in msg:
            validated = False
            break
        if value.startswith("_:NOT:_"):
            flag = False
            value = value[7:]
            ok_idx = 0
            ko_idx = 1
        else:
            flag = True
            ok_idx = 1
            ko_idx = 0
        result = re.search(value, msg[rule])
        if (result is not None) == flag:
            ok_str = match_msg[ok_idx].format(rule, msg[rule], value)
            oks.append(ok_str)
            comments.append(ok_str)
            continue
        else:
            comments.append(match_msg[ko_idx].format(rule, msg[rule], value))
        validated = False
        break
    return validated, comments, oks


def check_cdr_recursive(scen, msgs, test):
    num_scen = len(scen)  # Expected CDRs
    num_msgs = len(msgs)  # Result CDRs
    for i in range(num_scen):
        test.comment("cdr {}".format(i))
        found = False
        for message in msgs:
            test.comment("comparing with cdr id {}".format(message["id"]))
            valid, comments, oks = check_single_cdr_recursive(
                scen[i], message
            )
            for msg in comments:
                test.comment(msg)
            # if expected and result CDRs fully matches -> exit loop
            if valid:
                for ok in oks:
                    test.ok(ok)
                msgs.remove(message)
                found = True
                break
            # Otherwise, continue with the following one
        if not found:
            test.error("cdr[{}] does not find a correct match".format(i))
    if num_scen != num_msgs:
        test.error(
            "we expected {} cdr but we have {}".format(num_scen, num_msgs)
        )


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


def load_text(filepath):
    output = {"cdr": []}
    row = {}
    with open(filepath, "r") as file:
        line = file.readline()
        while line:
            if line.startswith("**********"):
                if len(row) > 0:
                    output["cdr"].append(row)
                row = {}
            else:
                elements = line.split(": ")
                if len(elements) == 2:
                    row[elements[0].strip()] = elements[1].strip()
                elif len(elements) == 1:
                    row[elements[0].strip()] = ""
            line = file.readline()
        if len(row) > 0:
            output["cdr"].append(row)
    file.close()
    return output


def main(args):
    # default -y
    load_check = load_yaml

    if args.yaml:
        load_check = load_yaml
    elif args.json:
        load_check = load_json
    elif args.text:
        load_check = load_text
    if args.debug:
        logging.basicConfig(level=logging.DEBUG)

    scen = load_yaml(args.yml_file)

    test = Test()

    try:
        check = load_check(args.cdr_file)
    except Exception:
        check = {"cdr": []}
        test.error("Error loading file:%s" % args.cdr_file)

    test.comment("check cdr record")
    check_cdr_recursive(scen["cdr"], check["cdr"], test)
    print(test)
    if test.isError():
        sys.exit(1)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="generate TAP result for CDR"
    )
    grp = parser.add_mutually_exclusive_group()
    grp.add_argument(
        "-y", "--yaml", action="store_true", help="YAML cdr_file"
    )
    grp.add_argument(
        "-j", "--json", action="store_true", help="JSON cdr_file"
    )
    grp.add_argument(
        "-t", "--text", action="store_true", help="TEXT cdr_file"
    )
    parser.add_argument("yml_file", help="YAML file with checks")
    parser.add_argument("cdr_file", help="CDR file")
    parser.add_argument("-d", "--debug", action="store_true")
    args = parser.parse_args()
    main(args)
