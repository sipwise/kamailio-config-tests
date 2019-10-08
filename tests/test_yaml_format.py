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
from yaml import load
import junitxml
import os
import sys
import unittest
import fnmatch
try:
    from yaml import CLoader as Loader
except ImportError:
    from yaml import Loader


class ParametrizedTestCase(unittest.TestCase):

    """ TestCase classes that want to be parametrized should
        inherit from this class.
        http://eli.thegreenplace.net/
        2011/08/02/python-unit-testing-parametrized-test-cases
    """

    def __init__(self, methodName='runTest', param=None):
        super(ParametrizedTestCase, self).__init__(methodName)
        self.param = param
        self.scenario = os.path.dirname(self.param)

    def id(self):
        return "%s_%s" % (super(ParametrizedTestCase, self).id(),
                          self.scenario)

    @staticmethod
    def parametrize(testcase_klass, param=None):
        """ Create a suite containing all tests taken from the given
            subclass, passing them the parameter 'param'.
        """
        testloader = unittest.TestLoader()
        testnames = testloader.getTestCaseNames(testcase_klass)
        suite = unittest.TestSuite()
        for name in testnames:
            suite.addTest(testcase_klass(name, param=param))
        return suite


class TestYmlLint(ParametrizedTestCase):

    def setUp(self):
        self.yaml = load(file(self.param, 'r'))

    def testFlow(self):
        self.assertTrue('flow' in self.yaml)
        self.assertIsInstance(self.yaml['flow'], list)

    def testSipIn(self):
        self.assertTrue('sip_in' in self.yaml)
        self.assertIsInstance(self.yaml['sip_in'], list)

    def testSipOut(self):
        self.assertTrue('sip_out' in self.yaml)
        self.assertIsInstance(self.yaml['sip_out'], list)


if __name__ == '__main__':
    assert len(sys.argv) == 2
    assert os.path.exists(sys.argv[1])
    suite = unittest.TestSuite()
    suite.addTest(
        ParametrizedTestCase.parametrize(TestYmlLint,
                                         param=sys.argv[1]))
    result = junitxml.JUnitXmlResult(sys.stdout)
    result.startTestRun()
    suite.run(result)
    result.stopTestRun()
