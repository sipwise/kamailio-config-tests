#!/usr/bin/perl
#
# Copyright: 2013-2015 Sipwise Development Team <support@sipwise.com>
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
use List::MoreUtils qw{ none };
use Config::Tiny;
use JSON qw();
use LWP::UserAgent;
use URI;
use Data::Dumper;

my $config =  Config::Tiny->read('/etc/default/ngcp-api');
my $opts = {
    host => '127.0.0.1',
    port => 1443,
    auth_user => 'administrator',
    auth_pwd => 'administrator',
    verbose => 0,
    admin => 0
};

if ($config) {
    $opts->{host} = $config->{_}->{NGCP_API_IP};
    $opts->{port} = $config->{_}->{NGCP_API_PORT};
}

sub usage {
  return "Usage:\n$PROGRAM_NAME scenario.yml\n".
        "Options:\n".
        "  -d debug\n".
        "  -h this help\n";
}
my $help = 0;
GetOptions ("h|help" => \$help, "d|debug" => \$opts->{verbose})
  or die("Error in command line arguments\n".usage());

die(usage()) unless (!$help);
die("Wrong number of arguments\n".usage()) unless ($#ARGV == 0);

sub get_data {
  my $val = shift;
  my $data = {
    administrative => $val->{admin} || 0,
    domain_id => $val->{domain_id},
    customer_id => $val->{customer_id},
    username => $val->{username},
    password => $val->{password},
    primary_number => {
      cc => $val->{cc},
      ac => $val->{ac},
      sn => $val->{sn}
    },
  };
  my @aliases = ();
  foreach (@{$val->{alias_numbers}}) {
    my $alias = {
      cc => $_->{cc},
      ac => $_->{ac},
      sn => $_->{sn}
    };
    push(@aliases, $alias);
  }
  if(scalar(@aliases)>0) {
    $data->{alias_numbers} = \@aliases;
  }
  return $data;
}

sub do_request {
    my $ua = shift;
    my $url = shift;
    my $data = shift;

    my $req = HTTP::Request->new('POST', $url);
    $req->header('Content-Type' => 'application/json');
    $req->header('Prefer' => 'return=representation');
    $req->content(JSON::to_json($data));
    my $res = $ua->request($req);
    if(!$res->is_success) {
      print "$url\n";
      print Dumper $data;
    }
    return $res;
}

sub do_query {
    my $ua = shift;
    my $url = shift;
    my $data = shift;
    my $URL = URI->new($url);
    $URL->query_form($data);
    my $req = HTTP::Request->new('GET', $URL);

    my $res = $ua->request($req);
    if(!$res->is_success) {
      print "$url\n";
    }
    return $res;
}

sub get_id {
  my $baseurl = shift;
  my $location = shift;
  my $id;

  ($id) = ($location =~ m/\Q$baseurl\E(\d+)/);
  return $id;
}

sub get_content {
  my $res = shift;
  return JSON::from_json( $res->decoded_content );
}

sub create_ua {
  my $ua = LWP::UserAgent->new();

  # set to 0 if using a self-signed certificate
  $ua->ssl_opts(verify_hostname => 0);
  $ua->credentials($opts->{host}.':'.$opts->{port}, 'api_admin_http',
      $opts->{auth_user}, $opts->{auth_pwd});
  # debug!!
  if($opts->{verbose}) {
    $ua->show_progress(1);
    $ua->add_handler("request_send",  sub { shift->dump; return });
    $ua->add_handler("response_done", sub { shift->dump; return });
  }
  return $ua;
}

sub check_contact_exists {
  my $data = shift;
  my $type = shift;
  my $urlbase = 'https://'.$opts->{host}.':'.$opts->{port};
  my $urldata = "/api/${type}contacts/";
  my $ua = create_ua();

  my $res = do_query($ua, $urlbase.$urldata, $data);
  if($res->is_success) {
    my $collection = get_content($res);
    if ($collection->{total_count} == 1) {
      return $collection->{_embedded}->{"ngcp:${type}contacts"}->{id};
    }
  }
  return;
}

sub create_contact {
  my $data = shift;
  my $type = shift;
  my $urlbase = 'https://'.$opts->{host}.':'.$opts->{port};
  my $urldata = "/api/${type}contacts/";
  my $ua = create_ua();

  my $res = do_request($ua, $urlbase.$urldata, $data);
  if($res->is_success) {
    if($opts->{verbose}) {
      print $res->status_line . ' ' . $res->header('Location') . "\n";
    }
    return get_id($urldata, $res->header('Location'));
  } else {
    die $res->as_string;
  }
  return;
}

sub check_contract_exists {
  my $data = shift;
  my $urlbase = 'https://'.$opts->{host}.':'.$opts->{port};
  my $urldata = '/api/contracts/';
  my $ua = create_ua();

  my $res = do_query($ua, $urlbase.$urldata, $data);
  if($res->is_success) {
    my $collection = get_content($res);
    if ($collection->{total_count} == 1) {
      return $collection->{_embedded}->{'ngcp:contracts'}->{id};
    }
  }
  return;
}

sub create_contract {
  my $data = shift;
  my $urlbase = 'https://'.$opts->{host}.':'.$opts->{port};
  my $urldata = '/api/contracts/';
  my $ua = create_ua();

  my $res = do_request($ua, $urlbase.$urldata, $data);
  if($res->is_success) {
    if($opts->{verbose}) {
      print $res->status_line . ' ' . $res->header('Location') . "\n";
    }
    return get_id($urldata, $res->header('Location'));
  } else {
    die $res->as_string;
  }
  return;
}

sub check_reseller_exists {
  my $data = shift;
  my $urlbase = 'https://'.$opts->{host}.':'.$opts->{port};
  my $urldata = '/api/resellers/';
  my $ua = create_ua();

  my $res = do_query($ua, $urlbase.$urldata, $data);
  if($res->is_success) {
    my $collection = get_content($res);
    if ($collection->{total_count} == 1) {
      return $collection->{_embedded}->{'ngcp:resellers'}->{id};
    }
  }
  return;
}

sub create_reseller {
  my $data = shift;
  my $urlbase = 'https://'.$opts->{host}.':'.$opts->{port};
  my $urldata = '/api/resellers/';
  my $ua = create_ua();

  my $res = do_request($ua, $urlbase.$urldata, $data);
  if($res->is_success) {
    if($opts->{verbose}) {
      print $res->status_line . ' ' . $res->header('Location') . "\n";
    }
    return get_id($urldata, $res->header('Location'));
  } else {
    die $res->as_string;
  }
  return;
}

sub check_domain_exists {
  my $data = shift;
  my $type = shift;
  my $urlbase = 'https://'.$opts->{host}.':'.$opts->{port};
  my $urldata = "/api/domains/";
  my $ua = create_ua();

  my $res = do_query($ua, $urlbase.$urldata, $data);
  if($res->is_success) {
    my $collection = get_content($res);
    if ($collection->{total_count} == 1) {
      return $collection->{_embedded}->{"ngcp:domains"}->{id};
    }
  }
  return;
}

sub create_domain {
  my $data = shift;
  my $urlbase = 'https://'.$opts->{host}.':'.$opts->{port};
  my $urldata = '/api/domains/';
  my $ua = create_ua();

  my $res = do_request($ua, $urlbase.$urldata, $data);
  if($res->is_success) {
    if($opts->{verbose}) {
      print $res->status_line . ' ' . $res->header('Location') . "\n";
    }
    return get_id($urldata, $res->header('Location'));
  } else {
    die $res->as_string;
  }
  return;
}

sub check_customer_exists {
  my $data = shift;
  my $urlbase = 'https://'.$opts->{host}.':'.$opts->{port};
  my $urldata = '/api/customers/';
  my $ua = create_ua();

  my $res = do_query($ua, $urlbase.$urldata, $data);
  if($res->is_success) {
    my $collection = get_content($res);
    if ($collection->{total_count} == 1) {
      return $collection->{_embedded}->{'ngcp:customers'}->{id};
    }
  }
  return;
}

sub create_customer {
  my $data = shift;
  my $urlbase = 'https://'.$opts->{host}.':'.$opts->{port};
  my $urldata = '/api/customers/';
  my $ua = create_ua();

  my $res = do_request($ua, $urlbase.$urldata, $data);
  if($res->is_success) {
    if($opts->{verbose}) {
      print $res->status_line . ' ' . $res->header('Location') . "\n";
    }
    return get_id($urldata, $res->header('Location'));
  } else {
    die $res->as_string;
  }
  return;
}

sub create_subscriber {
  my $domain = shift;
  my $username = shift;
  my $data = shift;
  my $urlbase = 'https://'.$opts->{host}.':'.$opts->{port};
  my $urldata = '/api/subscribers/';
  my $real_data = get_data($data);

  my $ua = create_ua();
  my $res = do_request($ua, $urlbase.$urldata, $real_data);
  if($res->is_success) {
      if($opts->{verbose}) {
        print $res->status_line . ' ' . $res->header('Location') . "\n";
      }
      return get_id($urldata, $res->header('Location'));
  } else {
      print Dumper $data, $real_data;
      die $res->as_string;
  }
  return;
}

sub manage_contacts
{
  my $data = shift;
  my $type = shift;
  foreach my $contact (@{$data->{contacts}})
  {
    $data->{contact_id} = check_contact_exists($contact, $type);
    if(defined $data->{contact_id}) {
      print "contact_$type [$contact->{email}] already there [$data->{contact_id}]\n";
    } else {
      $data->{contact_id} = create_contact($contact, $type);
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
      $data->{contract_id} = check_contract_exists($contract);
      if(defined $data->{contract_id}) {
        print "contract: already there [$data->{contract_id}]\n";
      } else {
        $data->{contract_id} = create_contract($contract);
        print "contract : created [$data->{contract_id}]\n";
      }
    }
  }
  return;
}

sub manage_domains
{
  my $data = shift;
  foreach my $domain (keys %{$data->{domains}})
  {
    my $domain_data = $data->{domains}->{$domain};
    my $d_data = {
      'domain' => $domain
    };
    $domain_data->{domain_id} = check_domain_exists($d_data);
    if(defined $domain_data->{domain_id}) {
      print "domain [$domain] already there [$domain_data->{domain_id}]\n";
    } else {
      $d_data->{reseller_id} = $domain_data->{reseller_id};

      $domain_data->{domain_id} = create_domain($d_data);
      print "domain [$domain]: created [$domain_data->{domain_id}]\n";
    }
  }
}

sub manage_customers
{
  my $data = shift;
  foreach my $customer (keys %{$data->{customers}})
  {
    my $customer_data = $data->{customers}->{$customer};
    manage_contacts($customer_data, 'customer');
    $customer_data->{details}->{contact_id} = $customer_data->{contact_id};
    $customer_data->{customer_id} = check_customer_exists($customer_data->{details});
    if(defined $customer_data->{customer_id}) {
      print "customer [$customer] already there [$customer_data->{customer_id}]\n";
    } else {
      $customer_data->{customer_id} = create_customer($customer_data->{details});
      print "customer [$customer]: created [$customer_data->{customer_id}]\n";
    }
  }
}

sub main
{
    my $data = shift;
    manage_customers($data);
    manage_domains($data);

    foreach my $domain (keys %{$data->{subscribers}})
    {
      my $d_data = $data->{subscribers}->{$domain};
      foreach my $username (keys %{$d_data})
      {
        my $s = $d_data->{$username};
        $s->{username} = $username;
        $s->{domain_id} = $data->{domains}->{$domain}->{domain_id};
        $s->{customer_id} = $data->{customers}->{$s->{customer}}->{customer_id};
        create_subscriber($domain, $username, $s);
        print("$username\@$domain created\n");
      }
    }
    return;
}

my $cf = YAML::LoadFile($ARGV[0]);

main($cf);
