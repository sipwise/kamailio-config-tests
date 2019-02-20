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

sub usage {
  return "Usage:\n$PROGRAM_NAME header.yml\n".
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
die("Error: Wrong number of arguments\n".usage()) unless ($#ARGV == 0);

sub manage_headers_rule
{
  my $data = shift;

  my $id = $api->check_headerrule_exists($data);
  if($id) {
    $data->{id} = $id;
    print "headerrule [$data->{name}] already there [$id]\n";
  } else {
    my $hr_id = $api->create_headerrule($data);
    if(defined $hr_id) {
      $data->{id} = $hr_id;
      print "headerrule [$data->{name}] created [$hr_id]\n";
    }
    else {
      die "Error: Can't create headerrule";
    }
  }
  return;
}

sub manage_headers_conditions
{
  my $data = shift;
  my $header_id = shift;

  foreach my $condition (@{$data}) {
    $condition->{rule_id} = $header_id;
    my $con_id = $api->create_headerrulecondition($condition);
    if(defined $con_id) {
      $condition->{id} = $con_id;
      print "header_condition [$condition->{match_type}/$condition->{match_part}/$condition->{match_name}]: created [$con_id]\n";
    }
    else {
      die "Error: Can't create headerrulecondition";
    }
  }
  return;
}

sub manage_headers_actions
{
  my $data = shift;
  my $header_id = shift;

  foreach my $action (@{$data}) {
    $action->{rule_id} = $header_id;
    my $act_id = $api->create_headerruleaction($action);
    if(defined $act_id) {
      $action->{id} = $act_id;
      print "header_action [$action->{action_type}/$action->{header}/$action->{value}]: created [$act_id]\n";
    }
    else {
      die "Error: Can't create headerruleaction";
    }
  }
  return;
}

sub do_delete
{
  my ($data) = @_;
  for my $header_set_name (keys %{$data}) {
    my $param = { reseller_id => 1, name => $header_set_name };
    my $hrs_id = $api->check_headerruleset_exists($param);
    if(defined $hrs_id) {
      if($api->delete_headerruleset($hrs_id)) {
        print "headerruleset [$header_set_name] deleted [$hrs_id]\n";
      }
      else {
        die "Error: headerruleset [$header_set_name] can't be removed [$hrs_id]\n";
      }
    } else {
      print "headerruleset [$header_set_name] not there\n";
    }
  }
  exit;
}

sub do_create
{
  my ($data) = @_;

  for my $header_set_name (keys %{$data}) {
    my $param = { reseller_id => 1, name => $header_set_name };
    my $hrs_id = $api->check_headerruleset_exists($param);
    if(defined $hrs_id) {
      print "headerruleset [$header_set_name] already there [$hrs_id]\n";
    } else {
      $hrs_id = $api->create_headerruleset($param);
      print "headerruleset [$header_set_name] created [$hrs_id]\n";
    }

    foreach my $header_rule (@{$data->{$header_set_name}->{header_rules}}) {
      $header_rule->{data}->{set_id} = $hrs_id;
      manage_headers_rule($header_rule->{data});
      manage_headers_conditions($header_rule->{conditions}, $header_rule->{data}->{id});
      manage_headers_actions($header_rule->{actions}, $header_rule->{data}->{id});
    }
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