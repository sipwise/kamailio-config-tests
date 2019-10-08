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


class XAvp:

    """ Class to simulate the xavp """

    def __init__(self, name, data):
        result = re.match('\$xavp\((\w+)\)', name)
        try:
            self._name = result.group(1)
        except:
            raise Exception('not a xavp')
        self._data = data

    def get(self, str):
        info = XAvp.parse(str)

        if self._name != info['name']:
            raise KeyError(
                'diferent name. name:%s != %s' % (self._name, info['name'])
            )

        nsize = len(self._data)
        if nsize <= info['nindx']:
            raise IndexError('%s has %d elements' % (self._name, nsize))

        if info['key'] in self._data[info['nindx']]:
            values = self._data[info['nindx']][info['key']]
        else:
            raise KeyError('no %s key found' % info['key'])

        if info['kindx'] == '*':
            return values

        ksize = len(values)
        if ksize <= info['kindx']:
            raise IndexError('%s has %d elements not %s' %
                             (info['key'], ksize, info['kindx']))

        return values[info['kindx']]

    @classmethod
    def parse(cls, str):
        pattern_nindx = '(\[(?P<%s>\d+)\])?' % 'nindx'
        pattern_kindx = '(\[(?P<%s>\d+|\*+)\])?' % 'kindx'
        pattern = '\$xavp\((?P<name>\w+)%s(=>(?P<key>\w+)%s)?\)' % (
            pattern_nindx, pattern_kindx)
        result = re.match(pattern, str)
        if result is not None:
            try:
                nindx = int(result.group('nindx'))
            except:
                nindx = 0
            try:
                kindx = int(result.group('kindx'))
            except:
                if result.group('kindx') == '*':
                    kindx = '*'
                else:
                    kindx = 0
            return {
                'name': result.group('name'),
                'nindx': nindx,
                'key': result.group('key'),
                'kindx': kindx}
        else:
            raise Exception('no xavp')


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


def check_flow_vars(sk, sv, cv, test):
    """ check the vars on a flow level"""
    for k in sv.keys():
        logging.debug("check k:'%s'" % k)
        if(k not in cv):
            try:
                info = XAvp.parse(k)
                search_key = '$xavp(%s)' % info['name']
                if(search_key not in cv):
                    raise Exception("search_key: %s info:%s" %
                                    (search_key, info))
                xavp = XAvp(search_key, cv[search_key])
                val = xavp.get(k)
                logging.debug("testing %s == %s" % (sv[k], val))
                test.test(sv[k], val,
                          'flow[%s] expected %s == %s but is %s' %
                          (sk, k, sv[k], val),
                          'flow[%s] %s' % (sk, k))
            except LookupError as err:
                if(sv[k] == 'None'):
                    test.ok('flow[%s] %s is not there' % (sk, k))
                else:
                    test.error('LookupError with %s. Error:%s' % (k, err))
            except Exception as err:
                if(sv[k] == 'None'):
                    test.ok('flow[%s] %s is not there' % (sk, k))
                else:
                    test.error(
                        'Expected var %s on flow[%s]. %s' % (k, sk, err))
        else:
            logging.debug("sv[k]:'%s' cv[k]:'%s'" % (sv[k], cv[k]))
            test.test(sv[k], cv[k], 'flow[%s] expected %s == %s but is %s' % (
                sk, k, sv[k], cv[k]), 'flow[%s] %s' % (sk, k))


def check_flow(scen, check, test):
    """ checks the flow and the vars inside"""
    for i in range(len(scen)):
        (sk, sv) = scen[i].popitem()
        try:
            (ck, cv) = check[i].popitem()
        except:
            test.error('wrong flow. Expected: %s but is nothing there' % sk)
            continue
        if(sk != ck):
            test.error('wrong flow. Expected: %s but is %s' % (sk, ck))
            continue
        if sv is None:
            test.ok('flow[%s] no var to check' % sk)
            continue
        else:
            test.ok('flow[%s]' % sk)
        check_flow_vars(sk, sv, cv, test)
    if(len(check) > len(scen)):
        l = []
        for i in check:
            for k in i.keys():
                l.append(k)
        test.error('Expected to end but there are more flows %s' % l)


def check_sip(scen, msg, test):
    if isinstance(msg, list):
        if len(msg) != 1:
            test.error('sip_in len != 1')
            return
        else:
            msg = msg[0]
    for rule in scen:
        if rule.startswith('_:NOT:_'):
            flag = False
            rule = rule[7:]
            msg_ok = '%s not match'
            msg_ko = '%s match'
        else:
            flag = True
            msg_ok = '%s match'
            msg_ko = '%s not match'
        result = re.search(rule, msg)
        if (result is not None) == flag:
            test.ok(msg_ok % rule)
            continue
        test.comment('result:%s' % result)
        test.error(msg_ko % rule)


def check_sip_out(scen, msgs, test):
    num_msgs = len(msgs)
    num_scen = len(scen)
    for i in (range(num_scen)):
        test.comment("sip_out %d" % i)
        if(i < num_msgs):
            check_sip(scen[i], msgs[i], test)
        else:
            test.error("sip_out[%d] does not exist" % i)
    if (num_scen != num_msgs):
        test.error("we expected %d out messages but we have %d" %
                   (num_scen, num_msgs))


def usage():
    print('Usage: check.py [-h] [-d] [-j] [-y] scenario_file test.yml')
    print('-h: this help')
    print('-d: debug')


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


def main():
    # default -y
    load_check = load_yaml

    try:
        opts, args = getopt.getopt(
            sys.argv[1:], "hyjd", ["help", "yaml", "json", "debug"])
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
        check = {'flow': [], 'sip_in': '', 'sip_out': []}
        test.error("Error loading file:%s" % args[1])

    test.comment('check flow')
    check_flow(scen['flow'], check['flow'], test)
    test.comment('check sip_in')
    check_sip(scen['sip_in'], check['sip_in'], test)
    test.comment('check sip_out')
    check_sip_out(scen['sip_out'], check['sip_out'], test)
    print(test)
    if test.isError():
        sys.exit(1)

if __name__ == "__main__":
    main()
