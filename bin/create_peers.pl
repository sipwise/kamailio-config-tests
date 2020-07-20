#!/usr/bin/perl
#
# Copyright: 2013-2016 Sipwise Development Team <support@sipwise.com>
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
  return "Usage:\n$PROGRAM_NAME peer.yml scenarios_ids.yml\n".
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

sub manage_contact
{
  my $contact = shift;
  my $type = shift;

  $contact->{id} = $api->check_contact_exists($contact, $type);
  if(defined $contact->{id}) {
    print "contact_$type [$contact->{email}] already there [$contact->{id}]\n";
  } else {
    $contact->{id} = $api->create_contact($contact, $type);
    print "contact_$type [$contact->{email}]: created [$contact->{id}]\n";
  }
  return;
}

sub manage_contract
{
  my $contract = shift;

  if(defined $contract->{contact_id})
  {
    $contract->{id} = $api->check_contract_exists($contract);
    if(defined $contract->{id}) {
      print "contract: already there [$contract->{id}]\n";
    } else {
      $contract->{id} = $api->create_contract($contract);
      print "contract : created [$contract->{id}]\n";
    }
  }
  else {
    die("Error: contract: No contact_id");
  }
  return;
}

sub manage_groups
{
  my $data = shift;

  foreach my $group (@{$data})
  {
    $group->{id} = $api->check_peeringgroup_exists($group);
    if(defined $group->{id}) {
      print "peer_group: already there [$group->{id}]\n";
    } else {
      $group->{id} = $api->create_peeringgroup($group);
      print "peer_group: created [$group->{id}]\n";
    }
  }
  return;
}

sub manage_rules
{
  my $data = shift;

  foreach my $rule (@{$data})
  {
    try {
      $rule->{id} = $api->create_peeringrule($rule);
      print "rule: created [$rule->{id}]\n";
    } catch {
      if($opts->{verbose}) {
        warn "rule: not able to create: $_";
      } else {
        warn "rule: not able to create";
      }
    };
  }
  return;
}

sub manage_inbound_rules
{
  my $data = shift;

  foreach my $rule (@{$data})
  {
    try {
      $rule->{id} = $api->create_peeringinboundrule($rule);
      print "inboundrule: created [$rule->{id}]\n";
    } catch {
      if($opts->{verbose}) {
        warn "rule: not able to create: $_";
      } else {
        warn "rule: not able to create";
      }
    };
  }
  return;
}

sub manage_hosts
{
  my $data = shift;

  foreach my $host (@{$data})
  {
    my $param = {name => $host->{name}, contract_id => $host->{contract_id}};
    $host->{id} = $api->check_peeringserver_exists($param);
    if(defined $host->{id}) {
      print "peer: $host->{name} already there [$host->{id}]\n";
    } else {
      $host->{id} = $api->create_peeringserver($host);
      print "peer: $host->{name} created [$host->{id}]\n";
    }
    my $key = $host->{name} =~ tr/\./_/r;
    $ids->{$key}->{id} = $host->{id};
  }
  return;
}

sub do_delete
{
  my $r = shift;

  foreach (keys %{$r})
  {
    my $peer = $r->{$_};
    $peer->{contact}->{id} = $api->check_contact_exists($peer->{contact},'system');
    my $contract_id = $api->check_contract_exists($peer->{contract});
    foreach my $group (@{$peer->{groups}}) {
      $group->{contract_id} = $contract_id;
      $group->{id} = $api->check_peeringgroup_exists($group);
      if(defined $group->{id}) {
        if($api->delete_peeringgroup($group->{id})) {
          print "peer_group: deleted [$group->{name}]\n";
        } else {
          die("Error: peer_group: can't delete [$group->{name}]");
        }
      } else {
        print "peer_group: already gone [$group->{name}]\n";
      }
    }
  }
  return;
}

sub do_create {
  my $r = shift;

  foreach (keys %{$r})
  {
    print "processing $_\n";
    my $peer = $r->{$_};
    manage_contact($peer->{contact}, 'system');
    $peer->{contract}->{contact_id} = $peer->{contact}->{id};
    manage_contract($peer->{contract});
    my $group = {};
    foreach (@{$peer->{groups}}) {
      $_->{contract_id} = $peer->{contract}->{id};
      $group->{$_->{name}} = $_;
    }
    manage_groups($peer->{groups});
    foreach (@{$peer->{rules}}) {
      $_->{group_id} = $group->{$_->{group_id}}->{id};
    }
    manage_rules($peer->{rules});
    foreach (@{$peer->{inboundrules}}) {
      $_->{group_id} = $group->{$_->{group_id}}->{id};
    }
    manage_inbound_rules($peer->{inboundrules});
    foreach (@{$peer->{hosts}}) {
      $_->{group_id} = $group->{$_->{group_id}}->{id};
    }
    manage_hosts($peer->{hosts});
  }
  return;
}

sub main {
    my $r = shift;

    if ($del) {
        print "delete peers\n" unless $opts->{debug};
        return do_delete($r);
    } else {
        print "create peers\n" unless $opts->{debug};
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
