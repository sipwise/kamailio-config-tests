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
use Getopt::Long;
use Cwd 'abs_path';
use Config::Tiny;
use Sipwise::API qw(all);
use YAML::XS qw(DumpFile LoadFile);
use File::Basename qw{ basename };

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
  return "Usage:\n$PROGRAM_NAME scenario.yml scenarios_ids.yml\n".
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

sub manage_soundfiles
{
  my ($data, $st) = @_;

  foreach my $sf (sort keys %{$data->{sounds}})
  {
    my $sf_data = $data->{sounds}->{$sf};
    my $filename = $sf_data->{filename};
    my $filepath = abs_path($filename);
    $sf_data->{set_id} = $data->{id};
    $sf_data->{handle} = $sf;
    $sf_data->{filename} = basename($filename, '.wav');
    if(-f $filepath) {
      $ids->{soundsets}->{$st}->{$sf}->{id} = $api->upload_soundfile($sf_data, $filepath);
      print "$filename at [$filepath] uploaded[$sf]\n";
    } else {
      die("$filename at [$filepath] not found");
    }
  }
  return;
}

sub do_create
{
  my $data = shift;
  foreach my $st (sort keys %{$data->{soundsets}})
  {
    my $st_data = {
      name => $st,
      reseller_id => $data->{soundsets}->{$st}->{reseller_id}
    };
    $data->{soundsets}->{$st}->{id} = $api->check_soundset_exists($st_data);
    if(defined $data->{soundsets}->{$st}->{id}) {
      print "soundset[$st] already there [$data->{soundsets}->{$st}->{id}]\n";
    } else {
      $data->{soundsets}->{$st}->{id} = $api->create_soundset($st_data);
      print "soundset [$st]: created [$data->{soundsets}->{$st}->{id}]\n";
      manage_soundfiles($data->{soundsets}->{$st}, $st);
    }
    $ids->{soundsets}->{$st}->{id} = $data->{soundsets}->{$st}->{id};
  }
  return;
}

sub do_delete
{
  my $data = shift;
  foreach my $st (sort keys %{$data->{soundsets}})
  {
    my $st_data = {
      name => $st,
      reseller_id => $data->{soundsets}->{$st}->{reseller_id}
    };
    $data->{soundsets}->{$st}->{id} = $api->check_soundset_exists($st_data);
    if(defined $data->{soundsets}->{$st}->{id}) {
      $api->delete_soundset($data->{soundsets}->{$st}->{id});
      print "delete soundset[$st] -> [$data->{soundsets}->{$st}->{id}]\n";
    }
  }
  return;
}

sub main {
    my $r = shift;

    if ($del) {
        return do_delete($r);
    } else {
        return do_create($r);
    }
}

if(! $del) {
  $ids_path = abs_path($ARGV[1]);
  $ids = LoadFile($ids_path);
}
main(LoadFile(abs_path($ARGV[0])), $ids);
if(! $del) {
  DumpFile($ids_path, $ids);
}
