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
  my $output = "usage: config_debug.pl [-hgc] MODE DOMAIN\n";
  $output .= "Options:\n";
  $output .= "\t-h: this help\n";
  $output .= "\t-g: scenarios group\n";
  $output .= "\t-c: number of kamailio.proxy.children\n";
  $output .= "\tMODE: on|off\tdefault: off\n";
  $output .= "\tDOMAIN: default: spce.test\n";
  return $output
}

my $help = 0;
my $children = 0;
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
GetOptions (
  "h|help" => \$help,
  "g|group=s" => \$group,
  "c|children=i" => \$children)
  or die("Error in command line arguments\n".usage());

if($#ARGV>1 || $help)
{
  die("Wrong number of arguments\n".usage())
}

my $base_dir;
my $yaml;
my $net_yaml;
my $file_yaml = '/etc/ngcp-config/config.yml';
my $file_net_yaml = '/etc/ngcp-config/network.yml';
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
  for my $file ($file_yaml, $file_net_yaml) {
    move("$file.orig", $file) or die "Can't restore the orig config $file";
  }
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
  for my $file ($file_yaml, $file_net_yaml) {
    cp($file, $file.".orig") or die "Copy $file failed: $ERRNO" unless(-e $file.".orig");
  }
  $yaml = LoadFile($file_yaml);
  $yaml->{kamailio}{lb}{cfgt} = 'yes';
  $yaml->{kamailio}{lb}{dns}{use_dns_cache} = 'off';
  $yaml->{kamailio}{lb}{extra_sockets}->{test} = "udp:127.2.0.1:5064";
  $yaml->{kamailio}{lb}{extra_sockets}->{other} = "tcp:127.3.0.1:5074";
  $yaml->{kamailio}{proxy}{children} = $children if($children > 0);
  $yaml->{kamailio}{proxy}{permissions_reload_delta} = 0;
  $yaml->{kamailio}{proxy}{cfgt} = 'yes';
  $yaml->{sems}{cfgt} = 'yes';
  $yaml->{sems}{debug} = 'yes';
  $yaml->{witnessd}{gather}{sip_responsiveness} = 'no';
  $yaml->{security}->{ngcp_panel}->{scripts}->{restapi}->{sslverify} = 'no';
  $yaml->{mediator}{interval} = '1';      # Necessary to speedup the creation of the CDRs
  $yaml->{rtpproxy}{delete_delay} = '5';  # Necessary to speedup the deletetion of the used ports in rtpengine
  $yaml->{rtpproxy}{log_level} = '7';

  $net_yaml = LoadFile($file_net_yaml);
  $net_yaml->{hosts_common}->{etc_hosts_global_extra_entries} //= ();
  my $entries = $net_yaml->{hosts_common}->{etc_hosts_global_extra_entries};
  push @{$entries}, "127.0.0.1 $domain";
  $net_yaml->{hosts_common}->{etc_hosts_global_extra_entries} = $entries;
  DumpFile($file_net_yaml, $net_yaml);

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
  DumpFile($file_yaml, $yaml);
}

#EOF
