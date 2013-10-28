#!/usr/bin/env perl
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
