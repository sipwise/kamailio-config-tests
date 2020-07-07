#!/usr/bin/env perl
#
# Copyright: 2020 Sipwise Development Team <support@sipwise.com>
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
use 5.014;
use strict;
use warnings;
use Cwd 'abs_path';
use Data::Dumper;
use YAML::XS qw(LoadFile);
use Getopt::Long;
use English;
use utf8;
use JSON;
use Scalar::Util qw(reftype);
use List::MoreUtils qw(uniq);

my @common_hdrs = qw(Via Route Call-ID Expires Max-Forwards);
sub usage
{
  my $output = "usage: generate_test_tt2.pl [-h] [-f Header] file\n";
  $output .= "Options:\n";
  $output .= "\t-h --help: this help\n";
  $output .= "\t-f --filter: remove this header ( can be used multiple times )\n";
  $output .= "\t-F --filter-common: filter common headers:\n";
  $output .= "\t\t@common_hdrs\n";
  $output .= "\t-i --ids: subst ids present in scenarios_ids.yml file\n";
  $output .= "\t-n --network: subst sipp ports using networks defined at scenarios.yml file\n";
  return $output
}

sub load_ids
{
  my $yml = LoadFile($_[0]);
  my $res = {};
  get_id($yml, "", $res, 'id');
  return $res;
}

sub load_uuids
{
  my $yml = LoadFile($_[0]);
  my $res = {};
  get_id($yml, "", $res, 'uuid');
  return $res;
}

sub load_network
{
  my $yml = LoadFile($_[0]);
  my @res = ();
  foreach (@{$yml->{scenarios}}) {
    push @res, $_->{ip};
    foreach (@{$_->{responders}}) {
      push @res, $_->{ip};
    }
  }
  @res = uniq(@res);
  return \@res;
}

sub get_id
{
  my $data = shift;
  my $str_key = shift;
  my $res = shift;
  my $id = shift;
  foreach my $key (sort keys %{$data}) {
    my $new_key = ${str_key} ? "${str_key}.${key}" : "${key}";
    if($key eq $id) {
      $res->{$data->{$key}} = $new_key;
    } else {
      my $_type = defined(reftype($data->{$key})) ? reftype($data->{$key}) : "";
      if( $_type eq 'HASH') {
        get_id($data->{$key}, $new_key, $res, $id);
      }
    }
  }
  return $res;
}

my $uuids;
my $ids;
sub subst_uuids
{
  my $line = shift;

  foreach my $uuid (sort keys %{$uuids}) {
    if($line =~ s/\Q${uuid}\E/[% $uuids->{$uuid} %]/g) {
      return $line;
    }
  }
  return $line;
}

sub subst_ids
{
  my $line = shift;
  foreach my $id (sort keys %{$ids}) {
    if($line =~ s/(=|: )\Q${id}\E([^\d]?)/${1}[% $ids->{$id} %]${2}/g) {
      return $line;
    }
  }
  return $line;
}

sub subst_common
{
  my $line = shift;
  if(($line =~ /^From: /i) || ($line =~ /^To: /i)) {
    $line =~ s/;tag=(.+)/;tag=[\\w-]+/;
  } elsif($line =~ /^CSeq: /i) {
    $line =~ s/:[ ]+\d+[ ]+/: \\d+ /;
  } elsif($line =~ /^(WWW|Proxy)-Authenticate: /i) {
    $line =~ s/nonce="[^"]+"/nonce=".+"/;
  } elsif($line =~ /^(WWW|Proxy)-Authorization: /i) {
    $line =~ s/response="[^"]+"/response=".+"/;
    $line =~ s/nonce="[^"]+"/nonce=".+"/;
  } elsif($line =~ /^(Server|User-Agent): Sipwise/i) {
    $line =~ s/: Sipwise NGCP (Proxy|Application|PBX).+/: Sipwise NGCP ${1}/;
  } elsif($line =~ /^Content-Length:[ ]+[1-9]/i) {
    $line =~ s/:[ ]+\d+/:\\s+\\d+/;
  } elsif($line =~ /^P-LB-Uptime: /i) {
    $line =~ s/: \d+/: \\d+/;
  } elsif($line =~ /^P-NGCP-Src-Port: /i) {
    $line =~ s/: \d+/: \\d+/;
  } elsif($line =~ /^P-NGCP-Acc-(Src|Dst)-Leg: /i) {
    $line =~ s/: .+/: .+/;
  } elsif($line =~ /^SIP-If-Match: /i) {
    $line =~ s/: .+/: .+/;
  } elsif($line =~ /127\.0\.0\.1(:|;port=)508[58]/) {
     $line =~ s/127\.0\.0\.1(:|;port=)\d+/127.0.0.1${1}508[58]/g;
  } elsif($line =~ /^Content-Type: application\/dialog\-info\+xml/i) {
    $line =~ s/: application\/dialog\-info\+xml/: application\/dialog\\-info\\+xml/;
  }
  return $line;
}

my $network;
sub subst_network
{
  my $line = shift;
  if ($line =~ /(?:[0-9]{1,3}\.){3}[0-9]{1,3}/) {
    foreach my $ip (@{$network}) {
      if($line =~ s/\Q${ip}\E:\d+/${ip}:\\d+/g) {
        return $line;
      } elsif($line =~ s/ip=\Q${ip}\E;port=\d+/ip=${ip};port=\\d+/g) {
        return $line;
      }
    }
  }
  return $line;
}

sub print_header
{
  my $_type = shift;
  my $_l = shift;
  my $line = $_l;

  if($uuids) {
    $line = subst_uuids($_l);
  }
  if($ids) {
    $line = subst_ids($line);
  }
  $line = subst_common($line);
  if($network) {
    $line = subst_network($line);
  }
  if($_type eq 'sip_in') {
    print "  - '$line'\n";
  } else {
    print "      '$line',\n";
  }
}

my @headers;
sub filter_header
{
  my $line = shift;
  foreach my $header (@headers) {
    if ($line =~ /${header}:/i) {
      return 1;
    }
  }
  return 0;
}

my $help = 0;
my $f_common = 0;
my $f_ids;
my $f_net;
GetOptions (
  "h|help" => \$help,
  "f|filter=s" => \@headers,
  "F|filter-common" => \$f_common,
  "i|ids=s" => \$f_ids,
  "n|network=s" => \$f_net,
) or die("Error in command line arguments\n".usage());

if($#ARGV!=0 || $help)
{
  die(usage())
}

if($f_common) {
  @headers =  uniq(@headers, @common_hdrs);
}

my $filename = abs_path($ARGV[0]);
my $json;
{
  local $INPUT_RECORD_SEPARATOR = undef; #Enable 'slurp' mode
  open my $fh, "<", $filename;
  $json = <$fh>;
  close $fh;
}
my $inlog = decode_json($json);

if($f_ids) {
  $uuids = load_uuids(abs_path($f_ids));
  $ids = load_ids(abs_path($f_ids));
}

if($f_net) {
  $network = load_network(abs_path($f_net));
}

print "flow:\n";
foreach my $i (@{$inlog->{'flow'}})
{
  foreach my $key (keys %{$i})
  {
    print "  - ".$key.":\n";
  }
}
print "sip_in:\n";
foreach my $i (@{$inlog->{'sip_in'}})
{
  my @line = split(/\r\n/, $i);
  foreach my $l (@line)
  {
    if($l) {
      if(!filter_header($l)) {
        print_header('sip_in', $l);
      }
    } else {
      # we don't care about SDP
      last;
    }
  }
}
if(@{$inlog->{'sip_out'}}) {
  print "sip_out:\n";
  foreach my $i (@{$inlog->{'sip_out'}})
  {
    my @line = split(/\r\n/, $i);
    print "  - [\n";
    foreach my $l (@line)
    {
      if($l) {
        if(!filter_header($l)) {
          print_header('sip_out', $l);
        }
      } else {
        # we don't care about SDP
        last;
      }
    }
    print "    ]\n";
  }
} else {
  print "sip_out: []\n";
}