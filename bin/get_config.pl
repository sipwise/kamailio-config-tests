#!/usr/bin/perl
#
# Copyright: 2021 Sipwise Development Team <support@sipwise.com>
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
use strict;
use warnings;
use English;
use Getopt::Long;
use Cwd 'abs_path';
use YAML::XS qw(DumpFile LoadFile);

sub usage
{
  my $output = "usage: $PROGRAM_NAME [-h] config.yml\n";
  $output .= "Options:\n";
  $output .= "\t-h: this help\n";
  return $output
}

my $help = 0;
GetOptions (
    "h|help" => \$help,
) or die("Error in command line arguments\n".usage());

die(usage()) unless (!$help);
die("Wrong number of arguments[$#ARGV]\n".usage()) unless ($#ARGV == 0);

my $data = LoadFile(abs_path($ARGV[0]));

# network
my $sip = $data->{sip};
print "$sip->{ip}\n";
print "$sip->{port}\n";
print "$sip->{mport}\n";

#peer
my $peer = $data->{peer};
print "$peer->{ip}\n";
print "$peer->{port}\n";
print "$peer->{mport}\n";

# phone
my $phone = $data->{phone};
print "$phone->{cc}\n";
print "$phone->{ac}\n";
print "$phone->{sn}\n";
