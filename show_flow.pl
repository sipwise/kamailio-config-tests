#!/usr/bin/env perl
use 5.014;
use strict;
use warnings;
use YAML;
use Cwd 'abs_path';
use Data::Dumper;
use Getopt::Long;

my $yml = '';
GetOptions ("y|yml+" => \$yml)
  or die("Error in command line arguments\n");
                                      
if($#ARGV!=0)
{
  die "usage: show_flow.pl file.yml\n";
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
