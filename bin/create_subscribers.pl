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

use English;
use Cwd 'abs_path';
use YAML::XS qw(DumpFile LoadFile);
use Getopt::Long;
use List::Util qw(none);
use Config::Tiny;
use Sipwise::API qw(all);

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
my $ids = {};

sub usage {
  return "Usage:\n$PROGRAM_NAME scenario.yml scenario_ids.yml\n".
        "Options:\n".
        "  -d debug\n".
        "  -h this help\n";
}
my $help = 0;
GetOptions ("h|help" => \$help, "d|debug" => \$opts->{verbose})
  or die("Error in command line arguments\n".usage());

die(usage()) unless (!$help);
die("Wrong number of arguments\n".usage()) unless ($#ARGV == 1);

sub get_data {
  my $val = shift;
  my $data = {
    administrative => $val->{admin} || 0,
    domain_id => $val->{domain_id},
    customer_id => $val->{customer_id},
    username => $val->{username},
    password => $val->{password},
    is_pbx_group => $val->{is_pbx_group},
    pbx_hunt_policy => $val->{pbx_hunt_policy},
    pbx_hunt_timeout => $val->{pbx_hunt_timeout},
    is_pbx_pilot => $val->{is_pbx_pilot},
    pbx_extension => $val->{pbx_extension},
    pbx_group_ids => $val->{pbx_group_ids},
    primary_number => {
      cc => $val->{cc},
      ac => $val->{ac},
      sn => $val->{sn}
    }
  };
  my @aliases = ();
  foreach (@{$val->{alias_numbers}}) {
    my $alias = {
      cc => $_->{cc},
      ac => $_->{ac},
      sn => $_->{sn},
      is_devid => $_->{is_devid},
      devid_alias => $_->{devid_alias}
    };
    push(@aliases, $alias);
  }
  if(scalar(@aliases)>0) {
    $data->{alias_numbers} = \@aliases;
  }
  return $data;
}

sub manage_contacts
{
  my $data = shift;
  my $type = shift;
  foreach my $contact (@{$data->{contacts}})
  {
    $data->{contact_id} = $api->check_contact_exists($contact, $type);
    if(defined $data->{contact_id}) {
      print "contact_$type [$contact->{email}] already there [$data->{contact_id}]\n";
    } else {
      $data->{contact_id} = $api->create_contact($contact, $type);
      print "contact_$type [$contact->{email}]: created [$data->{contact_id}]\n";
    }
  }
  return;
}

sub manage_contracts
{
  my $data = shift;
  foreach my $contract (@{$data->{contracts}})
  {
    if(defined $data->{contact_id})
    {
      $contract->{contact_id} = $data->{contact_id};
      $data->{contract_id} = $api->check_contract_exists($contract);
      if(defined $data->{contract_id}) {
        print "contract: already there [$data->{contract_id}]\n";
      } else {
        $data->{contract_id} = $api->create_contract($contract);
        print "contract : created [$data->{contract_id}]\n";
      }
    }
  }
  return;
}

sub manage_domains
{
  my $data = shift;
  foreach my $domain (sort keys %{$data->{domains}})
  {
    my $domain_data = $data->{domains}->{$domain};
    my $d_data = {
      'domain' => $domain
    };
    $domain_data->{domain_id} = $api->check_domain_exists($d_data);
    if(defined $domain_data->{domain_id}) {
      print "domain [$domain] already there [$domain_data->{domain_id}]\n";
    } else {
      $d_data->{reseller_id} = $domain_data->{reseller_id};

      $domain_data->{domain_id} = $api->create_domain($d_data);
      print "domain [$domain]: created [$domain_data->{domain_id}]\n";
    }
  }
  return;
}

sub manage_customers
{
  my $data = shift;
  foreach my $customer (sort keys %{$data->{customers}})
  {
    my $customer_data = $data->{customers}->{$customer};
    manage_contacts($customer_data, 'customer');
    $customer_data->{details}->{contact_id} = $customer_data->{contact_id};
    $customer_data->{customer_id} = $api->check_customer_exists($customer_data->{details});
    if(defined $customer_data->{customer_id}) {
      print "customer [$customer] already there [$customer_data->{customer_id}]\n";
    } else {
      $customer_data->{customer_id} = $api->create_customer($customer_data->{details});
      print "customer [$customer]: created [$customer_data->{customer_id}]\n";
    }
    my $key = $customer =~ tr/\./_/r;
    $ids->{$key}->{id} = $customer_data->{customer_id};
  }
  return;
}

sub create_subscriber
{
  my ($username, $domain , $data , $s) = @_;
  my $pbx_groups = $data->{pbx_groups};

  $s->{pbx_group_ids} = [];
  $s->{username} = $username;
  $s->{domain_id} = $data->{domains}->{$domain}->{domain_id};
  $s->{customer_id} = $data->{customers}->{$s->{customer}}->{customer_id};
  foreach my $group (@{$s->{pbx_groups}}) {
    if (defined $pbx_groups->{$group}) {
      push @{$s->{pbx_group_ids}}, $pbx_groups->{$group};
    }
    else {
      print "pbx_group[$group] not defined!\n";
    }
  }
  delete $s->{pbx_groups};
  $s->{id} = $api->create_subscriber(get_data($s));
  my $tmp = $api->get_subscriber($s->{id});
  my $key = $username =~ tr/\./_/r;
  my $key_dom = $domain =~ tr/\./_/r;
  $key_dom = $key_dom =~ tr/\-/_/r;
  $ids->{$key_dom}->{$key}->{uuid} = $tmp->{uuid};
  return;
}

sub manage_pbx_pilot
{
  my $data = shift;
  foreach my $domain (sort keys %{$data->{subscribers}})
  {
    my $d_data = $data->{subscribers}->{$domain};
    foreach my $username (sort keys %{$d_data})
    {
      my $s = $d_data->{$username};
      next unless $s->{is_pbx_pilot};
      # TODO: support pbx_groups for pbx_pilot
      if (exists $s->{pbx_groups}) {
        print("WARN: pbx_groups not supported for pbx_pilot. Skipped\n");
        delete $s->{pbx_groups};
      }
      create_subscriber($username, $domain, $data, $s);
      print("$username\@$domain is a pbx_pilot[$s->{id}]\n");
    }
  }
  return;
}

sub manage_pbx_groups
{
  my $data = shift;
  $data->{pbx_groups} = {};
  foreach my $domain (sort keys %{$data->{subscribers}})
  {
    my $d_data = $data->{subscribers}->{$domain};
    foreach my $username (sort keys %{$d_data})
    {
      my $s = $d_data->{$username};
      next unless $s->{is_pbx_group};
      create_subscriber($username, $domain, $data, $s);
      $data->{pbx_groups}->{$username} = $s->{id};
      print("$username\@$domain is a pbx_group[$s->{id}]\n");
    }
  }
  return;
}

sub main
{
    my $data = shift;
    manage_customers($data);
    manage_domains($data);
    manage_pbx_pilot($data);
    manage_pbx_groups($data);

    foreach my $domain (sort keys %{$data->{subscribers}})
    {
      my $d_data = $data->{subscribers}->{$domain};
      foreach my $username (sort keys %{$d_data})
      {
        my $s = $d_data->{$username};
        next if ($s->{is_pbx_group} || $s->{is_pbx_pilot});
        create_subscriber($username, $domain, $data, $s);
        print("$username\@$domain created [$s->{id}]\n");
      }
    }
    return;
}

main(LoadFile(abs_path($ARGV[0])));
DumpFile(abs_path($ARGV[1]), $ids);
