#!/usr/bin/env python
import io, sys, re
from yaml import load
from pprint import pprint
try:
  from yaml import CLoader as Loader
except:
  from yaml import Loader

class XAvp:
  """ Class to simulate the xavp """
  _data = []
  _name = ""

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
    if  nsize <= info['nindx']:
      raise IndexError('%s has %d elements' % (self._name, nsize))

    if self._data[info['nindx']].has_key(info['key']):
      values = self._data[info['nindx']][info['key']]
    else:
      raise KeyError('no %s key found' % info['key'] )

    if info['kindx'] == '*':
      return values;

    ksize = len(values)
    if ksize <= info['kindx']:
      raise IndexError('%s has %d elements not %s' % (info['key'], ksize, info['kindx']))

    return values[info['kindx']]

  @classmethod
  def parse(cls, str):
    pattern_nindx = '(\[(?P<%s>\d+)\])?' % 'nindx'
    pattern_kindx = '(\[(?P<%s>\d+|\*+)\])?' % 'kindx'
    pattern = '\$xavp\((?P<name>\w+)%s(=>(?P<key>\w+)%s)?\)'  % (pattern_nindx, pattern_kindx)
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
      return {'name': result.group('name'), 'nindx': nindx, 'key': result.group('key'), 'kindx': kindx }
    else:
      raise Exception('no xavp')

class Test:
  """ Class to create TAP output """
  _step = []
  _errflag = False

  def comment(self, msg):
    """ Add a comment """
    self._step.append({'result': None, 'msg_ok': msg})

  def ok(self, msg = None):
    """ Add a ok result """
    self._step.append({'result': True, 'msg_ok': msg})

  def error(self, msg_err):
    """ Add an error result"""
    self._step.append({'result': False, 'msg_err': msg_err})
    self._errflag = True

  def test(self, value_expected, value, msg_err, msg_ok = None):
    """ Test two values and add the result"""
    result = (value_expected == value)
    self._step.append({'result': result, 'msg_err': msg_err, 'msg_ok': msg_ok})
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
        output += "not ok %d - %s\n" % (test, s['msg_err'])
      test = test + 1
    return output

def check_flow_vars(sk, sv, ck, cv, test):
  """ check the vars on a flow level"""
  for k in sv.iterkeys():
    if(not cv.has_key(k)):
      test.error('Expected var %d on flow[%s]' % (k,sk))
    else:
      test.test(sv[k], cv[k], 'flow[%s] expected %s == %s but is %s' % (sk, k, sv[k], cv[k]), 'flow[%s] %s' % (sk, k))

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
    check_flow_vars(sk, sv, ck, cv, test)
  if(len(check)>len(scen)):
    l = []
    for i in check:
      for k in i.keys():
        l.append(k)
    test.error('Expected to end but there are more flows %s' % l)

def check_sip(scen, msg, test):
  for rule in scen:
    result = re.search(rule, msg)
    if result is not None:
      test.ok('%s match' % rule)
      continue
    test.error('%s not match' % rule)

def check_sip_out(scen, msgs, test):
  num_msgs = len(msgs)
  for i in (range(len(scen))):
    if(i<num_msgs):
      check_sip(scen[i], msgs[i], test)
    else:
      test.error("sip_out[%d] does not exist" % i)

if __name__ == '__main__':
  if(len(sys.argv)!=3):
    print 'Usage: check.py scenario.yml test.yml'
    sys.exit(1)

  with io.open(sys.argv[1], 'r') as file:
    scen = load(file, Loader=Loader)
  file.close()

  with io.open(sys.argv[2], 'r') as file:
    check = load(file, Loader=Loader)
  file.close()

  test = Test()

  test.comment('check flow')
  check_flow(scen['flow'], check['flow'], test)
  test.comment('check sip_in')
  check_sip(scen['sip_in'], check['sip_in'], test)
  test.comment('check sip_out')
  check_sip_out(scen['sip_out'], check['sip_out'], test)
  print test
  if test.isError():
    sys.exit(1)
