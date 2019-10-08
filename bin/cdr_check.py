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
import getopt
import json
import logging

from yaml import load
from pprint import pprint
try:
    from yaml import CLoader as Loader
except:
    from yaml import Loader


class Test:

    """ Class to create TAP output """

    def __init__(self):
        self._step = []
        self._errflag = False

    def comment(self, msg):
        """ Add a comment """
        self._step.append({'result': None, 'msg_ok': msg})

    def ok(self, msg=None):
        """ Add a ok result """
        self._step.append({'result': True, 'msg_ok': msg})

    def error(self, msg_err):
        """ Add an error result"""
        self._step.append({'result': False, 'msg_err': msg_err})
        self._errflag = True

    @classmethod
    def compare(cls, val0, val1):
        logging.debug("val0:[%s]:'%s' val1:[%s]:'%s'" %
                      (type(val0), str(val0), type(val1),
                       str(val1)))
        if isinstance(val0, str):
            if re.search(val0, str(val1)) is not None:
                return True
            else:
                return False
        elif isinstance(val0, int):
            try:
                result = (val0 == int(val1))
            except:
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
            result = (val0 == val1)
        return result

    def test(self, value_expected, value, msg_err, msg_ok=None):
        """ Test two values and add the result"""
        result = Test.compare(value_expected, value)
        self._step.append(
            {'result': result, 'msg_err': msg_err, 'msg_ok': msg_ok})
        if not result:
            self._errflag = True

    def isError(self):
        return self._errflag

    def _num_tests(self):
        """get the num of tests"""
        test = 0
        for s in self._step:
            if (s['result'] is not None):
                test = test + 1
        return test

    def __str__(self):
        """get the TAP output"""
        output = "1..%s\n" % self._num_tests()
        test = 1
        for s in self._step:
            if (s['result'] is None):
                output += '# %s\n' % s['msg_ok']
                continue
            elif (s['result']):
                if (s['msg_ok'] is not None):
                    output += "ok %d - %s\n" % (test, s['msg_ok'])
                else:
                    output += "ok %d\n" % test
            else:
                output += "not ok %d - ERROR: %s\n" % (test, s['msg_err'])
            test = test + 1
        return output


def check_single_cdr(scen, msg, test):
    if isinstance(msg, list):
        if len(msg) != 1:
            test.error('cdr len != 1')
            return
        else:
            msg = msg[0]
    for rule, value in scen.items():
        value = str(value)
        if rule not in msg:
            test.error('%s not in cdr' % rule)
            continue
        if value.startswith('_:NOT:_'):
            flag = False
            value = value[7:]
            msg_ok = '%s not match'
            msg_ko = '%s match'
        else:
            flag = True
            msg_ok = '%s match'
            msg_ko = '%s not match'
        result = re.search(value, msg[rule])
        if (result is not None) == flag:
            test.ok(msg_ok % rule)
            continue
        test.comment('result: %s' % result)
        test.error(msg_ko % rule)


def check_cdr(scen, msgs, test):
    num_scen = len(scen)  # Expected CDRs
    num_msgs = len(msgs)  # Resulted CDRs
    for i in (range(num_scen)):
        test.comment("cdr %d" % i)
        if(i < num_msgs):
            check_single_cdr(scen[i], msgs[i], test)
        else:
            test.error("cdr[%d] does not exist" % i)
    if (num_scen != num_msgs):
        test.error("we expected %d cdr but we have %d" %
                   (num_scen, num_msgs))


def check_single_cdr_recursive(scen, msg):
    validated = True
    comments = []
    oks = []
    for rule, value in scen.items():
        value = str(value)
        if rule not in msg:
            validated = False
            break
        if value.startswith('_:NOT:_'):
            flag = False
            value = value[7:]
            msg_ok = '%s not match'
            msg_ko = '%s match'
        else:
            flag = True
            msg_ok = '%s match'
            msg_ko = '%s not match'
        result = re.search(value, msg[rule])
        if (result is not None) == flag:
            oks.append(msg_ok % rule)
            continue
        validated = False
        break
    return validated, comments, oks


def check_cdr_recursive(scen, msgs, test):
    num_scen = len(scen)  # Expected CDRs
    num_msgs = len(msgs)  # Result CDRs
    for i in (range(num_scen)):
        test.comment("cdr %d" % i)
        found = False
        for message in msgs:
            test.comment("comparing with cdr id %s" % message['id'])
            valid, comments, oks = check_single_cdr_recursive(scen[i], message)
            # if expected and result CDRs fully matches -> exit loop
            if valid:
                for comment in comments:
                    test.comment(comment)
                for ok in oks:
                    test.ok(ok)
                msgs.remove(message)
                found = True
                break
            # Otherwise, continue with the following one
        if not found:
            test.error("cdr[%d] does not find a correct match" % i)
    if (num_scen != num_msgs):
        test.error("we expected %d cdr but we have %d" %
                   (num_scen, num_msgs))


def usage():
    print('Usage: mysql_check.py [OPTIONS] cdr_file cdr_test.yml')
    print('-h: this help')
    print('-d: debug')
    print('-y: cdr_file in .yaml format')
    print('-j: cdr_file in .json format')
    print('-t: cdr_file in .text format')


def load_yaml(filepath):
    output = None
    with io.open(filepath, 'r') as file:
        output = load(file, Loader=Loader)
    file.close()
    return output


def load_json(filepath):
    output = None
    with io.open(filepath, 'r') as file:
        output = json.load(file)
    file.close()
    return output


def load_text(filepath):
    output = {'cdr': []}
    row = {}
    with open(filepath, 'r') as file:
        line = file.readline()
        while line:
            if line.startswith('**********'):
                if len(row) > 0:
                    output['cdr'].append(row)
                row = {}
            else:
                elements = line.split(': ')
                if len(elements) == 2:
                    row[elements[0].strip()] = elements[1].strip()
                elif len(elements) == 1:
                    row[elements[0].strip()] = ""
            line = file.readline()
        if len(row) > 0:
            output['cdr'].append(row)
    file.close()
    return output


def main():
    # default -y
    load_check = load_yaml

    try:
        opts, args = getopt.getopt(
            sys.argv[1:], "hyjtd", ["help", "yaml", "json", "text", "debug"])
    except getopt.GetoptError as err:
        # print help information and exit:
        print(str(err))  # will print something like "option -a not recognized"
        usage()
        sys.exit(2)
    for o, a in opts:
        if o in ("-h", "--help"):
            usage()
            sys.exit()
        elif o in ("-y", "--yaml"):
            load_check = load_yaml
        elif o in ("-j", "--json"):
            load_check = load_json
        elif o in ("-t", "--text"):
            load_check = load_text
        elif o in ("-d", "--debug"):
            logging.basicConfig(level=logging.DEBUG)
        else:
            assert False, "unhandled option"

    if(len(args) != 2):
        usage()
        sys.exit(1)

    scen = load_yaml(args[0])

    test = Test()

    try:
        check = load_check(args[1])
    except:
        check = {'cdr': []}
        test.error("Error loading file:%s" % args[1])

    test.comment('check cdr record')
    check_cdr_recursive(scen['cdr'], check['cdr'], test)
    print(test)
    if test.isError():
        sys.exit(1)

if __name__ == "__main__":
    main()
