#!/usr/bin/env perl
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
use 5.014;
use strict;
use warnings;
use YAML;
use Cwd 'abs_path';
use Data::Dumper;
use Getopt::Long;

sub usage
{
  my $output = "usage: show_flow.pl [-h] file.yml\n";
  $output .= "\tOptions:\n";
  $output .= "-h --help: this help\n";
  $output .= "-y --yml: yaml output\n";
  return $output
}

my $yml = '';
my $help = 0;
GetOptions ("y|yml+" => \$yml, "h|help" => \$help)
  or die("Error in command line arguments\n".usage());

if($#ARGV!=0 || $help)
{
  die(usage())
}
my $filename = abs_path($ARGV[0]);
my $ylog = YAML::LoadFile($filename);

foreach my $i (@{$ylog->{'flow'}})
{
  foreach my $key (keys %{$i})
  {
    if($yml) { print "- ".$key.":\n"; }
    else { print "$key\n"; }
  }
}
#EOF
