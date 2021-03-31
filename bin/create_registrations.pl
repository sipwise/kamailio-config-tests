#!/usr/bin/perl
#
# Copyright: 2013-2021 Sipwise Development Team <support@sipwise.com>
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
my $ids = {};

sub usage {
  return "Usage:\n$PROGRAM_NAME registrations.yml\n".
        "Options:\n".
        "  -ids scenario_ids.yml file\n".
        "  -delete\n".
        "  -d debug\n".
        "  -h this help\n";
}
my $help = 0;
my $ids_path;
GetOptions ("h|help" => \$help,
    "ids=s" => \$ids_path,
    "d|debug" => \$opts->{verbose},
    "delete" => \$del)
    or die("Error in command line arguments\n".usage());

die(usage()) unless (!$help);
die("Error: wrong number of arguments\n".usage()) unless ($#ARGV == 0);

sub key_domain
{
    my $domain = shift;

    my $key_dom = $domain =~ tr/\./_/r;
    return $key_dom =~ tr/\-/_/r;
}

sub delete_regs
{
  my $subscriber = shift;
  my $domain = shift;
  my $subs_id = $api->check_subscriber_exists({
                          domain => $domain,
                          username => $subscriber});
  if($subs_id) {
    my $count = $api->delete_subscriber_registration($subs_id);
    print "${subscriber}[${subs_id}] deleted ${count} regs\n";
  }

  return;
}

sub contact
{
  my $subscriber = shift;
  my $domain = shift;
  my $key_dom = key_domain($domain);

  foreach my $scen (@{$ids->{scenarios}})
  {
    foreach my $resp (@{$scen->{responders}})
    {
      if( $resp->{username} eq $subscriber && $resp->{domain} eq $domain)
      {
        return "sip:$resp->{ip}:$resp->{port}";
      }
    }
  }
  die("can't find ${subscriber}\@${domain} on scenarios\n");
}

sub create_regs
{
  my $subscriber = shift;
  my $domain = shift;
  my $subs_id = $api->check_subscriber_exists({
                          domain => $domain,
                          username => $subscriber});
  my $data = shift;
  if($subs_id) {
    foreach my $r (@{$data})
    {
      $r->{subscriber_id} = $subs_id;
      $r->{contact} = contact($subscriber, $domain);
      my $id = $api->create_subscriber_registration($r);
      print "registration: ${subscriber}[${subs_id}] created as $r->{contact} [${id}]\n";
    }
  }
  else {
    die("Error: No subscriber ${subscriber}\@${domain} found");
  }

  return;
}

sub do_delete
{
  my $r = shift;

  foreach my $key (keys %{$r})
  {
    my @fields = split /@/, $key;
    delete_regs($fields[0], $fields[1]);
  }
  return;
}

sub do_create {
  my $r = shift;

  foreach my $key (keys %{$r})
  {
    print "processing ${key}\n";
    my @fields = split /@/, $key;
    my $reg = $r->{$key};
    create_regs($fields[0], $fields[1], $reg);
  }
  return;
}

sub main {
    my $r = shift;

    if ($del) {
        print "delete registrations\n" unless $opts->{debug};
        return do_delete($r);
    } else {
        die("scenario_ids.yml needed, use -ids option\n") unless defined($ids_path);
        print "load ${ids_path}\n" unless $opts->{debug};
        $ids = LoadFile($ids_path);
        print "create registrations\n" unless $opts->{debug};
        return do_create($r);
    }
}
my $path = abs_path($ARGV[0]);
print "loading ${path}\n";
main(LoadFile($path));
