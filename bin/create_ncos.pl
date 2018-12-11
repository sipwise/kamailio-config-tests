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
use YAML::XS;
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
  return  "Usage:\n$PROGRAM_NAME ncos.yml\n".
          "Options:\n".
          "  -delete remove ncos\n".
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

sub manage_ncons
{
  my $data = shift;
  my $param = {
    level => $data->{level},
    reseller_id => $data->{reseller_id}
  };
  my $id = $api->check_ncoslevel_exists($param);
  if($id) {
    $data->{id} = $id;
    print "ncos [$data->{level}] already there [$id]\n";
  } else {
    $data->{id} = $api->create_ncoslevel($data);
    print "ncos [$data->{level}]: created [$data->{id}]\n";
  }
  return;
}

sub manage_ncons_patterns
{
  my $data = shift;
  my $ncos_id = shift;

  foreach my $pattern (@{$data}) {
    $pattern->{ncos_level_id} = $ncos_id;
    my $id = $api->check_ncospattern_exists($pattern);
    if($id) {
      print "ncos_pattern [$pattern->{description}] already there [$id]\n";
    } else {
      $pattern->{id} = $api->create_ncospattern($pattern);
      print "ncos_pattern [$pattern->{description}]: created [$pattern->{id}]\n";
    }
  }
  return;
}

sub do_delete
{
  my ($data) = @_;
  foreach (keys %{$data})
  {
    my $ncos = $data->{$_}->{data};
    my $param = {
      level => $_,
      reseller_id => $ncos->{reseller_id}
    };
    my $id = $api->check_ncoslevel_exists($param);
    if($id) {
      if($api->delete_ncoslevel($id)) {
        print "ncos: deleted [$param->{level}]\n";
      } else {
        die("Error: ncos: can't delete [$param->{level}]");
      }
    } else {
      print "ncos: already gone [$param->{level}]\n";
    }
  }
  exit;
}

sub do_create
{
  my ($data) = @_;
  foreach (keys %{$data})
  {
    my $ncos = $data->{$_}->{data};
    $ncos->{level} = $_;
    manage_ncons($ncos);
    manage_ncons_patterns($data->{$_}->{patterns}, $ncos->{id});
  }
  exit;
}

my $r = YAML::XS::LoadFile(abs_path($ARGV[0]));
if ($del) {
  do_delete($r);
}
else {
  do_create($r);
}
