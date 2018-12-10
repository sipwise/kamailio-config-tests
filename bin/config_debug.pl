#!/usr/bin/perl
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
use English;
use File::Copy qw(cp move);
use File::Spec;
use Getopt::Long;
use strict;
use Tie::File;
use warnings;
use YAML::XS qw(LoadFile DumpFile);
use Hash::Merge qw(merge);

sub usage
{
  my $output = "usage: config_debug.pl [-h] MODE DOMAIN\n";
  $output .= "Options:\n";
  $output .= "\t-h: this help\n";
  $output .= "\t-g: scenarios group\n";
  $output .= "\tMODE: on|off\tdefault: off\n";
  $output .= "\tDOMAIN: default: spce.test\n";
  return $output
}

my $help = 0;
my $profile = "CE";
my $group;
if (exists $ENV{'GROUP'})
{
  $group = $ENV{'GROUP'};
}
else
{
  $group = "scenarios";
}
GetOptions ("h|help" => \$help, "g|group=s" => \$group)
  or die("Error in command line arguments\n".usage());

if($#ARGV>1 || $help)
{
  die("Wrong number of arguments\n".usage())
}

my $base_dir;
my $yaml;
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

my ($action, $domain) = @ARGV;

$action = 'off' unless defined($action);
$domain = 'spce.test' unless defined($domain);

if (lc($action) eq "off")
{
  move("$file.orig", $file) or die "Can't restore the orig config";
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
  cp($file, $file.".orig") or die "Copy failed: $ERRNO" unless(-e $file.".orig");
  $yaml = LoadFile($file);
  $yaml->{kamailio}{lb}{cfgt} = 'yes';
  $yaml->{kamailio}{lb}{use_dns_cache} = 'off';
  $yaml->{kamailio}{proxy}{children} = 1;
  $yaml->{kamailio}{proxy}{cfgt} = 'yes';
  $yaml->{sems}{debug} = 'yes';
  $yaml->{checktools}{sip_check_enable} = 0;
  $yaml->{security}->{ngcp_panel}->{scripts}->{restapi}->{sslverify} = 'no';
  $yaml->{mediator}{interval} = '1';

  my $group_yml_file = $base_dir."/".$group."/config.yml";
  if ( -e  $group_yml_file )
  {
    print "load $group_yml_file config file\n";
    my $group_yml = LoadFile($group_yml_file);
    my $hm = Hash::Merge->new('RIGHT_PRECEDENT');
    my $config = {};
    $config = $hm->merge( $config, $yaml);
    $yaml = $hm->merge( $config, $group_yml);
  } else {
    print "$group_yml_file not found\n";
  }

  tie @array, 'Tie::File', '/etc/hosts' or die ('Can set test domain on /etc/hosts');
  for (@array)
  {
    s/127.0.0.1[ \t]+localhost/127.0.0.1 localhost $domain/ unless($_ =~ /$domain/);
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
  DumpFile($file, $yaml);
}

#EOF
