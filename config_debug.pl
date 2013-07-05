#!/usr/bin/perl
use Tie::File;
use strict;
use warnings;
use YAML::Tiny;

my $yaml = YAML::Tiny->new;
my $file  = "/etc/ngcp-config/config.yml";
my @array;

$yaml = YAML::Tiny->read($file) or die "File $file could not be read";

my ($action, $domain) = @ARGV;

$action = 'off' unless defined($action);
$domain = 'spce.test' unless defined($domain);

if (lc($action) eq "off")
{
  $yaml->[0]->{kamailio}{lb}{debug} = 'no';
  $yaml->[0]->{kamailio}{proxy}{debug} = 'no';
  $yaml->[0]->{checktools}{sip_check_enable} = 1;

  tie @array, 'Tie::File', '/etc/hosts' or die ('Can set test domain on /etc/hosts');
  for (@array)
  {
    s/\Q$domain\E\ /spce. /;
  }
  untie @array;

}
else
{
  $yaml->[0]->{kamailio}{lb}{debug} = 'no';
  $yaml->[0]->{kamailio}{proxy}{debug} = 'yes';
  $yaml->[0]->{checktools}{sip_check_enable} = 0;

  tie @array, 'Tie::File', '/etc/hosts' or die ('Can set test domain on /etc/hosts');
  for (@array)
  {
    s/spce\.\s+/$domain /;
  }
  untie @array;
}
open(my $fh, '>', "$file") or die "Could not open $file for writing";
print $fh $yaml->write_string() or die "Could not write YAML to $file";

#EOF
