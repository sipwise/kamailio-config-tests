#!/usr/bin/env perl
#
# Copyright: 2023 Sipwise Development Team <support@sipwise.com>
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
use Cwd 'abs_path';
use Data::Dump qw(dump);
use Getopt::Long;
use English;
use utf8;
use JSON;

sub usage
{
  my $output = "usage: show_value_flow.pl [-h] file.json var\n";
  $output .= "\tOptions:\n";
  $output .= "-h --help: this help\n";
  return $output
}

my $help = 0;
GetOptions ("h|help" => \$help)
  or die("Error in command line arguments\n".usage());

if($#ARGV!=1 || $help)
{
  die("wrong number of arguments[$#ARGV]\n".usage())
}
my $filename = abs_path($ARGV[0]);
my $var_name = $ARGV[1];
my $inlog;
my $json;
{
  local $INPUT_RECORD_SEPARATOR = undef; #Enable 'slurp' mode
  open my $fh, "<", $filename;
  $json = <$fh>;
  close $fh;
}
$inlog = decode_json($json);

foreach my $i (@{$inlog->{'flow'}})
{
  foreach my $route_name (keys %{$i}) {
    if (defined $i->{$route_name}->{$var_name}) {
      print "${route_name}:${var_name}:", dump($i->{$route_name}->{$var_name}), "\n";
    } else {
      print "${route_name}\n";
    }
  }
}
#EOF
