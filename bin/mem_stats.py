#!/usr/bin/python3
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
import argparse
import csv
import os
import sys
import xmlrpc.client

KAM_URL = 'http://127.0.0.1:5062'
KAM_LINES = 10

proxy = xmlrpc.client.ServerProxy(KAM_URL)


def get_headers(l, prefix):
    res = []
    for i in l:
        res.append("%s%s" % (prefix, i))
    return res


def sum_row(s, r):
    for i in ['used', 'real_used', 'free']:
        s[i] = s[i] + r[i]


def save_data(datafile, headers, prefix, res):
    show_headers = get_headers(headers, prefix)
    with open(datafile, 'w+') as csvfile:
        spamwriter = csv.writer(csvfile)
        spamwriter.writerow(show_headers)
        spamwriter = csv.DictWriter(csvfile,
                                    headers, extrasaction='ignore')
        for row in res:
            spamwriter.writerow(row)


def get_pvm(private_file):
    res = [{'pid': 'SUM', 'used': 0, 'real_used': 0, 'free': 0}, ]
    headers = ['pid', 'used', 'real_used', 'free']
    prefix = 'rss_'
    try:
        for i in range(KAM_LINES):
            row = proxy.pkg.stats("index", i)[0]
            res.append(row)
            sum_row(res[0], row)
    except xmlrpc.client.Fault as err:
        print("A fault occurred")
        print("Fault code: %d" % err.faultCode)
        print("Fault string: %s" % err.faultString)
        sys.exit(-1)
    except xmlrpc.client.ProtocolError as err:
        print("A protocol error occurred")
        print("URL: %s" % err.url)
        print("HTTP/HTTPS headers: %s" % err.headers)
        print("Error code: %d" % err.errcode)
        print("Error message: %s" % err.errmsg)
        sys.exit(-2)
    save_data(private_file, headers, prefix, res[:1])
    fileName, fileExtension = os.path.splitext(private_file)
    private_file_pp = '%s_per_pid%s' % (fileName, fileExtension)
    save_data(private_file_pp, headers, prefix, res[2:])


def get_shm(share_file):
    headers = ['used', 'real_used', 'max_used',
               'free', 'fragments', 'total'
               ]
    prefix = 'shared_'
    try:
        res = proxy.core.shmmem('b')
    except xmlrpc.client.Fault as err:
        print("A fault occurred")
        print("Fault code: %d" % err.faultCode)
        print("Fault string: %s" % err.faultString)
        sys.exit(-1)
    except xmlrpc.client.ProtocolError as err:
        print("A protocol error occurred")
        print("URL: %s" % err.url)
        print("HTTP/HTTPS headers: %s" % err.headers)
        print("Error code: %d" % err.errcode)
        print("Error message: %s" % err.errmsg)
        sys.exit(-2)
    save_data(share_file, headers, prefix, [res, ])


def main():
    parser = argparse.ArgumentParser(
        description='export to csv kamailio proxy stats.')
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
