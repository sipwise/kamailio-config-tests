#!/usr/bin/perl
#
# Copyright: 2016 Sipwise Development Team <support@sipwise.com>
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

use English;
use YAML;
use Getopt::Long;
use Cwd 'abs_path';
use Config::Tiny;
use Sipwise::API qw(all);
use Data::Dumper;

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

sub usage {
  return  "Usage:\n$PROGRAM_NAME lnp.yml\n".
          "Options:\n".
          "  -delete remove lnp\n".
          "  -d debug\n".
          "  -h this help\n";
}
my $help = 0;
my $del;
GetOptions(
  "h|help" => \$help,
  "d|debug" => \$opts->{verbose},
  "delete" => \$del
) or die("Error in command line arguments\n".usage());

die(usage()) unless (!$help);
die("Error: wrong number of arguments\n".usage()) unless ($#ARGV == 0);

sub manage_lnp
{
  my $data = shift;
  my $param = {
    name => $data->{name}
  };
  my $id = $api->check_lnpcarrier_exists($param);
  if($id) {
    $data->{id} = $id;
    print "ncos [$data->{name}] already there [$id]\n";
  } else {
    $data->{id} = $api->create_lnpcarrier($data);
    print "ncos [$data->{name}]: created [$data->{id}]\n";
  }
  return;
}

sub manage_lnpnumbers
{
  my $data = shift;
  my $lnp_id = shift;

  foreach my $number (@{$data}) {
    $number->{carrier_id} = $lnp_id;
    my $id = $api->check_lnpnumber_exists($number);
    if($id) {
      print "lnnumber [$number->{number}] already there [$id]\n";
    } else {
      $number->{id} = $api->create_lnpnumber($number);
      print "lnpnumber [$number->{number}]: created [$number->{id}]\n";
    }
  }
  return;
}

sub manage_ncoslnpcarriers
{
  my ($data, $lnp_id) = @_;

  foreach my $ncos (@{$data}) {
    my $ncos_id = $api->check_ncoslevel_exists($ncos);
    if(!$ncos_id) {
      die("No ncoslevel[$ncos->{level}] found\n");
    }
    my $param = {
      ncos_level_id => $ncos_id,
      carrier_id => $lnp_id
    };
    my $id = $api->check_ncoslnpcarrier_exists($param);
    if($id) {
      print "ncoslnpcarriers [$ncos->{level}] for [$lnp_id] already there [$id]\n";
    } else {
      $ncos->{id} = $api->create_ncoslnpcarrier($param);
      print "ncoslnpcarriers [$ncos->{level}] for [$lnp_id]: created [$ncos->{id}]\n";
    }
  }
  return;
}


sub do_delete
{
  my ($data) = @_;
  foreach (keys %{$data})
  {
    my $lnp = $data->{$_}->{data};
    my $numbers = $data->{$_}->{numbers};
    my $param = {
      name => $lnp->{name}
    };
    my $id = $api->check_lnpcarrier_exists($param);
    if($id) {
      foreach my $number (@{$numbers}) {
        $number->{carrier_id} = $id;
        my $nid = $api->check_lnpnumber_exists($number);
        if($nid) {
          if($api->delete_lnpnumber($nid)) {
            print "lnpnumber [$number->{number}]: deleted [$nid]\n";
          } else {
            die("Error: can't delete lnpnumber [$number->{number}]");
          }
        } else {
          print "lnpnumber: already gone [$number->{number}]\n";
        }
      }
      if($api->delete_lnpcarrier($id)) {
        print "lnp: deleted [$lnp->{name}]\n";
      } else {
        die("Error: lnp: can't delete [$lnp->{name}]");
      }
    } else {
      print "lnp: already gone [$lnp->{name}]\n";
    }
  }
  exit;
}

sub do_create
{
  my ($data) = @_;
  foreach (keys %{$data})
  {
    my $lnp = $data->{$_}->{data};
    manage_lnp($lnp);
    manage_lnpnumbers($data->{$_}->{numbers}, $lnp->{id});
    manage_ncoslnpcarriers($data->{$_}->{ncos}, $lnp->{id});
  }
  exit;
}

my $r = YAML::LoadFile(abs_path($ARGV[0]));
if ($del) {
  do_delete($r);
}
else {
  do_create($r);
}
