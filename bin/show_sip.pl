#!/usr/bin/env perl
#
# Copyright: 2020 Sipwise Development Team <support@sipwise.com>
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
use Data::Dumper;
use Getopt::Long;
use English;
use utf8;
use JSON;

sub usage
{
  my $output = "usage: show_sip.pl [-h] file\n";
  $output .= "\tOptions:\n";
  $output .= "-h --help: this help\n";
  $output .= "-i --sip_in: print sip_in\n";
  $output .= "-o --sip_out: print sip_out\n";
  $output .= "by default prints both\n";
  return $output
}

my $help = 0;
my $json_in = 0;
my $in = 0;
my $out = 0;
GetOptions ("h|help" => \$help, "i|sip_in" => \$in, "o|sip_out" => \$out)
  or die("Error in command line arguments\n".usage());

if($#ARGV!=0 || $help)
{
  die(usage())
}
if(!$in && !$out) {
  # default behaviour
  $in = 1;
  $out = 1;
}
my $filename = abs_path($ARGV[0]);
my $json;
{
  local $INPUT_RECORD_SEPARATOR = undef; #Enable 'slurp' mode
  open my $fh, "<", $filename;
  $json = <$fh>;
  close $fh;
}
my $inlog = decode_json($json);

if($in) {
  print "=== sip_in ===\n";
  foreach my $i (@{$inlog->{'sip_in'}})
  {
    print "$i\n---\n";
  }
}
if($out) {
  print "=== sip_out ===\n";
  foreach my $i (@{$inlog->{'sip_out'}})
  {
    print "$i\n---\n"
  }
}
#EOF
