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
use YAML::XS;
use utf8;
use JSON;
use Text::Diff;

sub usage
{
  my $output = "usage: show_flow_diff.pl [-h] test_yml log_json\n";
  $output .= "\tOptions:\n";
  $output .= "-h --help: this help\n";
  return $output
}

my $help = 0;
GetOptions ("h|help" => \$help)
  or die("Error in command line arguments\n".usage());

if($#ARGV!=1 || $help)
{
  die(usage())
}
my $file_yml = abs_path($ARGV[0]);
my $test = YAML::XS::LoadFile($file_yml);

my $file_json = abs_path($ARGV[1]);
my $log;
{
  local $INPUT_RECORD_SEPARATOR = undef; #Enable 'slurp' mode
  open my $fh, "<", $file_json;
  my $json = <$fh>;
  close $fh;
  $log = decode_json($json);
}

my $text_yml = "";
foreach my $i (@{$test->{'flow'}})
{
  foreach my $key (keys %{$i})
  {
    $text_yml .= "  - ".$key.":\n";
  }
}

my $text_json = "";
foreach my $i (@{$log->{'flow'}})
{
  foreach my $key (keys %{$i})
  {
    $text_json .= "  - ".$key.":\n";
  }
}

my $diff = diff(\$text_yml, \$text_json, { STYLE => "Unified" });
print $diff;
#EOF
