#!/usr/bin/env python
#
# Copyright: 2014 Sipwise Development Team <support@sipwise.com>
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
import sys, os, csv, argparse
import xmlrpclib

KAM_URL='http://127.0.0.1:5062'
KAM_LINES=10

proxy = xmlrpclib.ServerProxy(KAM_URL)

def get_headers(l):
    res = {}
    for i in l:
        res[i] = i
    return res

def sum_row(s, r):
    for i in ['used', 'real_used', 'free']:
        s[i] = s[i] + r[i];

def get_pvm(private_file):
    res = [{'pid':'SUM', 'used':0, 'real_used':0, 'free':0},]
    headers = ['pid', 'used', 'real_used', 'free']
    write_headers = False
    try:
        for i in range(KAM_LINES):
            row = proxy.pkg.stats("index", i)[0]
            res.append(row)
            sum_row(res[0], row)
    except xmlrpclib.Fault as err:
        print "A fault occurred"
        print "Fault code: %d" % err.faultCode
        print "Fault string: %s" % err.faultString
        sys.exit(-1)
    except xmlrpclib.ProtocolError as err:
        print "A protocol error occurred"
        print "URL: %s" % err.url
        print "HTTP/HTTPS headers: %s" % err.headers
        print "Error code: %d" % err.errcode
        print "Error message: %s" % err.errmsg
        sys.exit(-2)
    if not os.path.isfile(private_file):
        write_headers = True
    with open(private_file, 'a+') as csvfile:
        spamwriter = csv.DictWriter(csvfile,
            headers, extrasaction='ignore')
        if write_headers:
            spamwriter.writerow(get_headers(headers))
        for row in res:
            spamwriter.writerow(row)

def get_shm(share_file):
    write_headers = False
    try:
        res = proxy.core.shmmem('b')
    except xmlrpclib.Fault as err:
        print "A fault occurred"
        print "Fault code: %d" % err.faultCode
        print "Fault string: %s" % err.faultString
        sys.exit(-1)
    except xmlrpclib.ProtocolError as err:
        print "A protocol error occurred"
        print "URL: %s" % err.url
        print "HTTP/HTTPS headers: %s" % err.headers
        print "Error code: %d" % err.errcode
        print "Error message: %s" % err.errmsg
        sys.exit(-2)
    if not os.path.isfile(share_file):
        write_headers = True
    with open(share_file, 'a+') as csvfile:
        spamwriter = csv.DictWriter(csvfile,
            res.keys())
        if write_headers:
            spamwriter.writerow(get_headers(res.keys()))
        spamwriter.writerow(res)

def main():
    parser = argparse.ArgumentParser(description='export to csv kamailio proxy stats.')
    parser.add_argument('--private_file', '-P', nargs='?', default='pvm.csv',
                   help='path to the private csv file')
    parser.add_argument('--share_file', '-S', nargs='?', default='shm.csv',
                   help='path to the share csv file')
    parser.add_argument('--rpc_url', nargs='?', default=KAM_URL,
                   help='rpc URL of kamailio. Default:%s' % KAM_URL)
    args = parser.parse_args()

    get_pvm(args.private_file)
    get_shm(args.share_file)

if __name__ == "__main__":
  main()
