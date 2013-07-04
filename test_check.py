#!/usr/bin/env python
from check import XAvp
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

if __name__ == '__main__':
    unittest.main()