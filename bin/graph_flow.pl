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
use Cwd 'abs_path';
use Data::Dumper;
use Getopt::Long;
use English;

sub usage
{
  my $output = "usage: graph_flow.pl [-h] [-j] file_in file_out.png\n";
  $output .= "Options:\n";
  $output .= "\t-h: this help\n";
  $output .= "\t-j: file_in is json\n";
  return $output;
}

my $help = 0;
my $json_in = 0;
GetOptions ("h|help" => \$help, "j|json" => \$json_in)
  or die("Error in command line arguments\n".usage());

if($#ARGV!=1)
{
  die(usage());
}

eval
{
  require GraphViz;
  GraphViz->import();
  1;
} or die "You need package libgraphviz-perl to run this program\n";

my $g = GraphViz->new();
my $filename = abs_path($ARGV[0]);
my $outfilename = $ARGV[1];
my $inlog;
if($json_in) {
  use utf8;
  use JSON;
  my $json;
  {
    local $INPUT_RECORD_SEPARATOR = undef; #Enable 'slurp' mode
    open my $fh, "<", $filename;
    $json = <$fh>;
    close $fh;
  }
  $inlog = decode_json($json);
}
else {
  use YAML::XS;
  $inlog = YAML::XS::LoadFile($filename);
}
my @prevs = ();
my $name = '';
my $action = '';
my $prev;
my $cont = 1;
$g->add_node(name => 'END', shape =>'box');

foreach my $i (@{$inlog->{'flow'}})
{
  foreach my $key (keys %{$i})
  {
    #print "$key\n";
    if(($action, $name) = ($key =~ m/(start|exit|drop|return)\|(\w+)/))
    {
      if ($action eq "start")
      {
        $prev = $prevs[-1];

        if ($prev)
        {
          $g->add_node(name => $name);
          $g->add_edge( $prev => $name, label => $cont++);
        }
        else
        {
          $g->add_node(name => $name, shape=> 'diamond');
        }
        push(@prevs, $name);
      }
      else
      {
        pop(@prevs); # this is me.
        $prev = $prevs[-1];
        if ($action eq "return") { $g->add_edge($name => $prev, label => $cont++); }
        else { @prevs = ();  $g->add_edge($name => 'END', label => $cont++); }
      }
    }
  }
}
$g->as_png($outfilename);
#EOF
