#!/usr/bin/perl
use File::Spec;
use Tie::File;
use strict;
use warnings;
use YAML::Tiny;
use Getopt::Long;

sub usage
{
  my $output = "usage: config_debug.pl [-h] MODE DOMAIN\n";
  $output .= "Options:\n";
  $output .= "\t-h: this help\n";
  $output .= "\tMODE: on|off\tdefault: off\n";
  $output .= "\tDOMAIN: default: spce.test\n";
  return $output
}

my $help = 0;
my $profile = "CE";
GetOptions ("h|help" => \$help)
  or die("Error in command line arguments\n".usage());

if($#ARGV>1 || $help)
{
  die("Wrong number of arguments\n".usage())
}

my $base_dir;
my $yaml = YAML::Tiny->new;
my $file  = "/etc/ngcp-config/config.yml";
my @array;
my $path;
if (exists $ENV{'BASE_DIR'})
{
  $base_dir = $ENV{'BASE_DIR'};
}
else
{
  $base_dir = '/usr/share/kamailio-config-tests';
}

$yaml = YAML::Tiny->read($file) or die "File $file could not be read";

my ($action, $domain) = @ARGV;

$action = 'off' unless defined($action);
$domain = 'spce.test' unless defined($domain);

if (lc($action) eq "off")
{
  $yaml->[0]->{kamailio}{lb}{debug} = 'no';
  $yaml->[0]->{kamailio}{proxy}{debug} = 'no';
  $yaml->[0]->{sems}{debug} = 'no';
  $yaml->[0]->{checktools}{sip_check_enable} = 1;

  tie @array, 'Tie::File', '/etc/hosts' or die ('Can set test domain on /etc/hosts');
  for (@array)
  {
    s/\Q$domain\E//;
  }
  untie @array;
  for my $i ('caller.csv', 'callee.csv')
  {
    $path = File::Spec->catfile( $base_dir, 'scenarios', $i);
    tie @array, 'Tie::File', $path or die ("Can set test domain on $path");
    for (@array)
    {
      s/\Q$domain\E/DOMAIN/;
    }
    untie @array;
  }
}
else
{
  $yaml->[0]->{kamailio}{lb}{debug} = 'yes';
  $yaml->[0]->{kamailio}{proxy}{debug} = 'yes';
  $yaml->[0]->{sems}{debug} = 'yes';
  $yaml->[0]->{checktools}{sip_check_enable} = 0;

  tie @array, 'Tie::File', '/etc/hosts' or die ('Can set test domain on /etc/hosts');
  for (@array)
  {
    s/127.0.0.1 localhost/127.0.0.1 localhost $domain/;
  }
  untie @array;
  for my $i ('caller.csv', 'callee.csv')
  {
    $path = File::Spec->catfile( $base_dir, 'scenarios', $i);
    tie @array, 'Tie::File', $path or die ("Can set test domain on $path");
    for (@array)
    {
      s/DOMAIN/$domain/;
    }
    untie @array;
  }
}
open(my $fh, '>', "$file") or die "Could not open $file for writing";
print $fh $yaml->write_string() or die "Could not write YAML to $file";

#EOF
