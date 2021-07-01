#!/usr/bin/perl
#
# Copyright: 2021 Sipwise Development Team <support@sipwise.com>
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
use warnings;
use List::MoreUtils qw(uniq);
use YAML::XS qw(LoadFile DumpFile);
use Hash::Merge qw(merge);

sub usage
{
  my $output = "usage: $PROGRAM_NAME [-hg] kct_config.yml MODE\n";
  $output .= "Options:\n";
  $output .= "\t-h: this help\n";
  $output .= "\t-g: scenarios group\n";
  $output .= "\tkct_config.yml: config file for k-c-t environment\n";
  $output .= "\tMODE: on|off\tdefault: off\n";
  return $output
}

my $help = 0;
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
  "g|group=s" => \$group)
  or die("Error in command line arguments\n".usage());

if($#ARGV>1 || $help)
{
  die("Wrong number of arguments\n".usage())
}

my $base_dir = '/usr/share/kamailio-config-tests';
my $file_net_yaml = '/etc/ngcp-config/network.yml';
my ($kct_conf_yaml, $action) = @ARGV;

$action = 'off' unless defined($action);

if (exists $ENV{'BASE_DIR'})
{
  $base_dir = $ENV{'BASE_DIR'};
}

sub get_domains
{
  my $ip = shift;
  my $entries = shift;
  my @scenarios = qx{${base_dir}/bin/get_scenarios.sh -x ${group}};
  my @domains = ();
  for my $scenario (@scenarios) {
    chomp $scenario;
    my $scen_file = "${base_dir}/${group}/${scenario}/scenario.yml";
    print "loading ${scen_file}\n";
    my $info = LoadFile($scen_file);
    foreach (keys %{$info->{domains}}) {
      push @domains, $_;
    }
  }
  foreach (uniq(@domains)) {
    print "define $_ as $ip\n";
    push @{$entries}, "$ip $_";
  }
  return $entries;
}

sub change_network
{
  my $kct_conf = shift;
  my $net_yaml = LoadFile($file_net_yaml);

  for my $host (keys %{$net_yaml->{hosts}}) {
    $net_yaml->{hosts}->{$host}->{dummy0} = {
      ip => $kct_conf->{rtpengine}->{rtp_flag}[0]->{ip},
      netmask => $kct_conf->{rtpengine}->{rtp_flag}[0]->{netmask},
      type => ['rtp_tag']
    };
    push @{$net_yaml->{hosts}->{$host}->{interfaces}}, 'dummy0';
    $net_yaml->{hosts}->{$host}->{dummy1} = {
      ip => $kct_conf->{rtpengine}->{rtp_flag}[1]->{ip},
      netmask => $kct_conf->{rtpengine}->{rtp_flag}[1]->{netmask},
      type => ['rtp_tag']
    };
    push @{$net_yaml->{hosts}->{$host}->{interfaces}}, 'dummy1';
  }

  $net_yaml->{hosts_common}->{etc_hosts_global_extra_entries} //= ();
  my $entries = $net_yaml->{hosts_common}->{etc_hosts_global_extra_entries};
  $entries = get_domains($kct_conf->{kamailio}->{lb}->{ip}, $entries);
  $net_yaml->{hosts_common}->{etc_hosts_global_extra_entries} = $entries;
  DumpFile($file_net_yaml, $net_yaml);
}

if (lc($action) eq "off")
{
  for my $file ($file_net_yaml) {
    move("$file.orig", $file) or die "Can't restore the orig config $file";
  }
}
else
{
  for my $file ($file_net_yaml) {
    cp($file, $file.".orig") or die "Copy $file failed: $ERRNO" unless(-e $file.".orig");
  }
  print "loading $kct_conf_yaml\n";
  my $kct_conf = LoadFile($kct_conf_yaml);
  change_network($kct_conf);
}

#EOF
