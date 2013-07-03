#!/usr/bin/env python
import io, sys, re
from yaml import load
from pprint import pprint
try:
  from yaml import CLoader as Loader
except:
  from yaml import Loader

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
    for k in sv.iterkeys():
      if(not cv.has_key(k)):
        test.error('Expected var %d on flow[%s]' % (k,sk))
      else:
        test.test(sv[k], cv[k], 'flow[%s] expected %s == %s but is %s' % (sk, k, sv[k], cv[k]), 'flow[%s] %s' % (sk, k))
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
