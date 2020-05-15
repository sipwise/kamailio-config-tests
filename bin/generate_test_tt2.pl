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
use YAML::XS qw(LoadFile);
use Getopt::Long;
use English;
use utf8;
use JSON;

sub usage
{
  my $output = "usage: generate_test_tt2.pl [-h] [-f Header] file\n";
  $output .= "\tOptions:\n";
  $output .= "-h --help: this help\n";
  $output .= "-f --filter: remove this header ( can be used multiple times )\n";
  return $output
}

my @headers;
sub filter_header
{
  my $line = $_[0];
  foreach my $header (@headers) {
    if ($line =~ /${header}:/i) {
      return 1;
    }
  }
  return undef;
}

my $yml = '';
my $help = 0;
GetOptions ("h|help" => \$help, "f|filter=s" => \@headers)
  or die("Error in command line arguments\n".usage());

if($#ARGV!=0 || $help)
{
  die(usage())
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
print "flow:\n";
foreach my $i (@{$inlog->{'flow'}})
{
  foreach my $key (keys %{$i})
  {
    print "  - ".$key.":\n";
  }
}
print "sip_in:\n";
foreach my $i (@{$inlog->{'sip_in'}})
{
  my @line = split(/\r\n/, $i);
  foreach my $l (@line)
  {
    if($l) {
      if(!filter_header($l)) {
        print "  - '$l'\n";
      }
    } else {
      # we don't care about SDP
      last;
    }
  }
}
print "sip_out:\n";
foreach my $i (@{$inlog->{'sip_out'}})
{
  my @line = split(/\r\n/, $i);
  print "  - [\n";
  foreach my $l (@line)
  {
    if($l) {
      if(!filter_header($l)) {
        print "      '$l',\n";
      }
    } else {
      # we don't care about SDP
      last;
    }
  }
  print "    ]\n";
}
