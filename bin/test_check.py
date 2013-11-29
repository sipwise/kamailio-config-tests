#!/usr/bin/env python
#
# Copyright: 2013 Sipwise Development Team <support@sipwise.com>
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
from check import XAvp, Test, check_flow, check_flow_vars, check_sip, check_sip_out
import yaml
import unittest

class TestXAvp(unittest.TestCase):

  def setUp(self):
    self.name = 'test'
    self.data = [
      {'koko': [1]},
      {'koko': [1, 2]},
      {'lolo': [3], 'lola': [7]},
    ]
    self.xavp = XAvp('$xavp(%s)' % self.name, self.data)

  def test_init(self):
    self.assertEqual(self.name, self.xavp._name)
    self.assertItemsEqual(self.data, self.xavp._data)

  def test_init_wrong_type(self):
    self.assertRaises(Exception, self.xavp, '$var(whatever)', None)

  def test_parse_type(self):
    self.assertRaisesRegexp(Exception, 'no xavp', XAvp.parse, '$var(whatever)')
    self.assertRaisesRegexp(Exception, 'no xavp', XAvp.parse, '$fU')

  def test_get_wrong_name(self):
    self.assertRaises(KeyError, self.xavp.get, '$xavp(otro)')
    self.assertRaises(KeyError, self.xavp.get, '$xavp(otro[0])')
    self.assertRaises(KeyError, self.xavp.get, '$xavp(otro=>whatever)')
    self.assertRaises(KeyError, self.xavp.get, '$xavp(otro[0]=>whatever)')

  def test_get_wrong_nindx(self):
    self.assertRaises(IndexError, self.xavp.get, '$xavp(test[10]=>koko)')
    self.assertRaises(IndexError, self.xavp.get, '$xavp(test[10]=>koko[1])')

  def test_get_wrong_kindx(self):
    self.assertRaises(IndexError, self.xavp.get, '$xavp(test[0]=>koko[1])')
    self.assertRaises(IndexError, self.xavp.get, '$xavp(test[1]=>koko[10])')

  def test_get_value(self):
    self.assertEqual(self.xavp.get('$xavp(test=>koko)'), 1)
    self.assertEqual(self.xavp.get('$xavp(test[1]=>koko[1])'), 2)
    self.assertEqual(self.xavp.get('$xavp(test[2]=>lola[0])'), 7)

  def test_get_value_all(self):
    self.assertItemsEqual(self.xavp.get('$xavp(test[1]=>koko[*])'), [1,2])

class TestCheckFlowVars(unittest.TestCase):

  def setUp(self):
    self.ctest = Test()
    self.check_ok = [
      { 'R0': { '$xavp(v0)':
                 [{
                   'k0': [1],
                   'k1': ['a', 'b', 'fuckthisshit']
                  },
                  {
                   'k0': [1,2],
                   'k1': ['a',]
                  },
                 ],
                'fU': 'testpep',
              },
      },
      { 'R1': { '$xavp(v0)': [{'k0': [1,2]}] }},
    ]
    self.scen_noxavp = [
      { 'R0': {'fU': 'testpep'} },
      { 'R1': {} },
    ]
    self.scen = [
      { 'R0': { '$xavp(v0[0]=>k0[0])': 1,
                '$xavp(v0[0]=>k1[0])': 'a',
                '$xavp(v0[0]=>k1[2])': '^f',
                '$var(no)': 'None',
                '$xavp(nono=>koko)': 'None',
                '$xavp(v0=>k10)': 'None',
                '$xavp(v0[1]=>k0[1])': '\d+'}
              },
      { 'R1': {'$xavp(v0[1]=>k0[0])': 1} },
    ]

  def testXAvp(self):
    data = self.check_ok[0]['R0']['$xavp(v0)']
    xavp = XAvp('$xavp(v0)', data)

    self.assertEqual(xavp.get('$xavp(v0=>k0)'), 1)
    self.assertEqual(xavp.get('$xavp(v0=>k1[*])'), ['a','b', 'fuckthisshit'])
    self.assertEqual(xavp.get('$xavp(v0[1]=>k0[1])'), 2)
    self.assertEqual(xavp.get('$xavp(v0[1]=>k1[*])'), ['a'])

  def testFlow_noxavp(self):
    check_flow(self.scen_noxavp, self.check_ok, self.ctest)
    self.assertFalse(self.ctest.isError())

  def testFlowVars_noxavp(self):
    check_flow_vars('RO', self.scen_noxavp[0]['R0'], self.check_ok[0]['R0'], self.ctest)
    print self.ctest
    self.assertFalse(self.ctest.isError())

  def testFlowVars_xavp(self):
    check_flow_vars('RO', self.scen[0]['R0'], self.check_ok[0]['R0'], self.ctest)
    print self.ctest
    self.assertFalse(self.ctest.isError())

class TestCheckSipIn(unittest.TestCase):

  def setUp(self):
    self.ctest = Test()
    self.msg ="""REGISTER sip:testuser1003@spce.test SIP/2.0
Via: SIP/2.0/UDP 127.0.0.1;branch=z9hG4bK3969.2f1956baf914fd272ada0363d9577b29.0
Via: SIP/2.0/UDP 127.126.0.1:50602;rport=50602;branch=z9hG4bK-24881-1-3
From: <sip:testuser1003@spce.test>;tag=24881SIPpTag001
To: "TestBria" <sip:testuser1003@spce.test>
Call-ID: 1-24881@127.126.0.1
CSeq: 4 REGISTER
Authorization: Digest username="testuser1003",realm="spce.test",uri="sip:127.0.0.1:5060",nonce="Una661J2ub8hRdmjTwus8Habu3n6G/By",response="c1b8da80c3d05f8d4da478128f94907a",algorithm=MD5
Contact: "TestBria" <sip:testuser1003@127.126.0.1:50602;ob>;reg-id=1;+sip.instance="<urn:uuid:C3DD6013-20E8-40E3-8EA2-5849B02ED0C4>"
Contact: "TestBria" <sip:testuser1003@127.126.0.1:6666;ob>;expires=0
Expires: 600
Max-Forwards: 16
Content-Length: 0
P-NGCP-Src-Ip: 127.126.0.1
P-NGCP-Src-Port: 50602
P-NGCP-Src-Proto: udp
P-NGCP-Src-Af: 4
P-Sock-Info: udp:127.0.0.1:5060
Path: <sip:lb@127.0.0.1;lr;socket=sip:127.0.0.1:5060>"""

  def testSipIn(self):
    sip_in = yaml.load("""
- '^REGISTER'
- 'Contact: "TestBria" <sip:testuser1003@127.126.0.1:50602;ob>;reg-id=1;\+sip.instance="<urn:uuid:C3DD6013-20E8-40E3-8EA2-5849B02ED0C4>"'
- 'Contact: "TestBria" <sip:testuser1003@127.126.0.1:6666;ob>;expires=0'
- 'Content-Length: 0'
- 'Expires: \d+'
- '_:NOT:_Expires: 0'
- 'Authorization: Digest username="testuser1003"'""")
    check_sip(sip_in, self.msg, self.ctest)
    print self.ctest
    self.assertFalse(self.ctest.isError())

class TestCheckSipOut(unittest.TestCase):

  def setUp(self):
    self.ctest = Test()
    self.msg =  yaml.load("""
- |+
  SIP/2.0 100 Trying
  Via: SIP/2.0/UDP 127.0.0.1;branch=z9hG4bK3969.2f1956baf914fd272ada0363d9577b29.0
  Via: SIP/2.0/UDP 127.126.0.1:50602;rport=50602;branch=z9hG4bK-24881-1-3
  From: <sip:testuser1003@spce.test>;tag=24881SIPpTag001
  To: "TestBria" <sip:testuser1003@spce.test>
  Call-ID: 1-24881@127.126.0.1
  CSeq: 4 REGISTER
  P-Out-Socket: udp:127.0.0.1:5060
  Server: Sipwise NGCP Proxy 2.X
  Content-Length: 0

- |+
  SIP/2.0 200 OK
  Via: SIP/2.0/UDP 127.0.0.1;branch=z9hG4bK3969.2f1956baf914fd272ada0363d9577b29.0;rport=5060
  Via: SIP/2.0/UDP 127.126.0.1:50602;rport=50602;branch=z9hG4bK-24881-1-3
  From: <sip:testuser1003@spce.test>;tag=24881SIPpTag001
  To: "TestBria" <sip:testuser1003@spce.test>;tag=1d24a28a0bded6c40d31e6db8aab9ac6.504e
  Call-ID: 1-24881@127.126.0.1
  CSeq: 4 REGISTER
  P-Out-Socket: udp:127.0.0.1:5060
  P-NGCP-Authorization: testuser1003@spce.test
  P-NGCP-Authorized: 1
  P-Caller-UUID: 2cc06244-5a63-46cd-aee9-1d804d314371
  Contact: <sip:testuser1003@127.126.0.1:50602;ob>;expires=600;+sip.instance="<urn:uuid:C3DD6013-20E8-40E3-8EA2-5849B02ED0C4>";reg-id=1
  Server: Sipwise NGCP Proxy 2.X
  Content-Length: 0""")

  def testSipOut(self):
    sip_out = yaml.load("""
- [
    '^SIP/2.0 100 Trying',
    'Content-Length: 0'
  ]
- [
    '^SIP/2.0 200 OK',
    'Contact: <sip:testuser1003@127.126.0.1:50602;ob>;expires=600;\+sip.instance="<urn:uuid:C3DD6013-20E8-40E3-8EA2-5849B02ED0C4>";reg-id=1',
    'Content-Length: 0',
    'P-NGCP-Authorization: testuser1003@',
    'P-NGCP-Authorized: 1',
    '_:NOT:_Contact: <sip:testuser1003@127.126.0.1:6666;ob>;expires=\d+'
  ]""")
    check_sip_out(sip_out, self.msg, self.ctest)
    print self.ctest
    self.assertFalse(self.ctest.isError())

if __name__ == '__main__':
    unittest.main()