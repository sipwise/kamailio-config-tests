#!/usr/bin/perl
#
# Copyright: 2023 Sipwise Development Team <support@sipwise.com>
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
use strict;
use warnings;

use Try::Tiny;
use English;
use Getopt::Long;
use Cwd 'abs_path';
use Config::Tiny;
use Sipwise::API qw(all);
use YAML::XS qw(DumpFile LoadFile);

my $config =  Config::Tiny->read('/etc/default/ngcp-api');
my $opts;
if ($config) {
    $opts = {};
    $opts->{host} = $config->{_}->{NGCP_API_IP};
    $opts->{port} = $config->{_}->{NGCP_API_PORT};
    $opts->{sslverify} = $config->{_}->{NGCP_API_SSLVERIFY};
}
my $api = Sipwise::API->new($opts);
$opts = $api->opts;
my $del = 0;
my $ids;
my $ids_path;

sub usage {
  return "Usage:\n$PROGRAM_NAME emergency.yml scenarios_ids.yml\n".
        "Options:\n".
        "  -delete\n".
        "  -d debug\n".
        "  -h this help\n";
}
my $help = 0;
GetOptions ("h|help" => \$help,
    "d|debug" => \$opts->{verbose},
    "delete" => \$del)
    or die("Error in command line arguments\n".usage());

die(usage()) unless (!$help);
if(!$del) {
  die("Error: wrong number of arguments\n".usage()) unless ($#ARGV == 1);
} else {
  die("Error: wrong number of arguments\n".usage()) unless ($#ARGV == 0);
}

sub manage_emc
{
  my $emc = shift;

  $emc->{id} = $api->check_emergencymappingcontainer_exists($emc);
  if(defined $emc->{id}) {
    print "emergencymappingcontainer: already there [$emc->{id}]\n";
  } else {
    $emc->{id} = $api->create_emergencymappingcontainer($emc);
    print "emergencymappingcontainer: created [$emc->{id}]\n";
  }
  return;
}

sub manage_mappings
{
  my $emc = shift;
  my $data = shift;

  foreach my $map (@{$data})
  {
    $map->{emergency_container_id} = $emc->{id};
    try {
      $map->{id} = $api->create_emergencymapping($map);
      print "emergencymapping: created [$map->{id}]\n";
    } catch {
      if($opts->{verbose}) {
        warn "emergencymapping: not able to create: $_";
      } else {
        warn "emergencymapping: not able to create";
      }
    };
  }
  return;
}

sub do_delete
{
  my $r = shift;

  foreach (keys %{$r})
  {
    my $emc = {
      "name" => $_,
      "reseller_id" => $r->{$_}->{reseller_id},
    };
    $emc->{id} = $api->check_emergencymappingcontainer_exists($emc);
    if(defined $emc->{id}) {
      if($api->delete_emergencymappingcontainer($emc->{id})) {
        print "deleted [$emc->{name}]\n";
      } else {
        die("Error: can't delete [$emc->{name}]");
      }
    } else {
      print "emergencymapping [$emc->{name}]\n";
    }
  }
  return;
}

sub do_create {
  my $r = shift;

  foreach (keys %{$r})
  {
    print "processing $_\n";
    my $emc = {
      "name" => $_,
      "reseller_id" => $r->{$_}->{reseller_id},
    };
    my $mappings = $r->{$_}->{mappings};
    manage_emc($emc);
    $ids->{emergencymapping}->{$emc->{name}}->{id} = $emc->{id};
    manage_mappings($emc, $mappings);
    $ids->{emergencymapping}->{$emc->{name}}->{mappings} = $mappings;
  }
  return;
}

sub main {
    my $r = shift;

    if ($del) {
        print "delete emergencymapping\n" unless $opts->{debug};
        return do_delete($r);
    } else {
        print "create emergencymapping\n" unless $opts->{debug};
        return do_create($r, $ids);
    }
}

if(! $del) {
  $ids_path = abs_path($ARGV[1]);
  print "load $ids_path\n";
  $ids = LoadFile($ids_path);
}
main(LoadFile(abs_path($ARGV[0])), $ids);
if(! $del) {
  print "save $ids_path\n";
  DumpFile($ids_path, $ids);
}
