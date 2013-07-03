#!/usr/bin/perl -wCSD

use strict;
use warnings;
use YAML::Tiny;

my $yaml = YAML::Tiny->new;
my $file  = "/etc/ngcp-config/config.yml";

$yaml = YAML::Tiny->read($file) or die "File $file could not be read";


if ($#ARGV eq 0 && lc($ARGV[0]) eq "off")
{
  $yaml->[0]->{kamailio}{lb}{debug} = 'no';
  $yaml->[0]->{kamailio}{proxy}{debug} = 'no';
  $yaml->[0]->{checktools}{sip_check_enable} = 1;
}
else
{
  $yaml->[0]->{kamailio}{lb}{debug} = 'no';
  $yaml->[0]->{kamailio}{proxy}{debug} = 'yes';
  $yaml->[0]->{checktools}{sip_check_enable} = 0;
}
open(my $fh, '>', "$file") or die "Could not open $file for writing";
print $fh $yaml->write_string() or die "Could not write YAML to $file";
