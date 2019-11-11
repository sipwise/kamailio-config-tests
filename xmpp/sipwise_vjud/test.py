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
import argparse
import aioxmpp
from yaml import load
try:
    from yaml import CLoader as Loader
except:
    from yaml import Loader

def load_yaml(filepath):
    output = None
    with io.open(filepath, 'r') as file:
        output = load(file, Loader=Loader)
    file.close()
    return output

def main():

    parser = argparse.ArgumentParser(description='Process some integers.')
    parser.add_argument('scenario',
                    help='scenario.yml file')
    args = parser.parse_args()

    scen = load_yaml(args['scenario'])

if __name__ == "__main__":
    main()

