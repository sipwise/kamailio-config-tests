#!/usr/bin/env python
from check import XAvp, Test, check_flow, check_flow_vars
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
                '$xavp(v0=>k10)': 'None'}
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

if __name__ == '__main__':
    unittest.main()