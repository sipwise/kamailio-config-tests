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

sub usage
{
  my $output = "usage: generate_test_tt2.pl [-h] [-f Header] file\n";
  $output .= "\tOptions:\n";
  $output .= "-h --help: this help\n";
  $output .= "-f --filter: remove this header ( can be used multiple times )\n";
  $output .= "-i --ids: subst ids present in scenarios_ids.yml file\n";
  return $output
}

sub load_ids
{
  my $yml = LoadFile($_[0]);
  my $res = {};
  get_uuid($yml, "", $res);
  return $res;
}

sub get_uuid
{
  my $data = shift;
  my $str_key = shift;
  my $res = shift;
  foreach my $key (sort keys %{$data}) {
    my $new_key = ${str_key} ? "${str_key}.${key}" : "${key}";
    if($key eq 'uuid') {
      $res->{$data->{$key}} = $new_key;
    } else {
      my $_type = defined(reftype($data->{$key})) ? reftype($data->{$key}) : "";
      if( $_type eq 'HASH') {
        get_uuid($data->{$key}, $new_key, $res);
      }
    }
  }
  return $res;
}

my $uuids;
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

sub subst_common
{
  my $line = shift;
  if(($line =~ /^From: /i) || ($line =~ /^To: /i)) {
    $line =~ s/;tag=(.+)/;tag=[\\w-]+/;
  } elsif($line =~ /^CSeq: /i) {
    $line =~ s/:[ ]+\d+[ ]+/: \\d+ /;
  } elsif($line =~ /^WWW-Authenticate: /i) {
    $line =~ s/nonce=".+"/nonce=".+"/;
  } elsif($line =~ /^Server: Sipwise/i) {
    $line =~ s/^: Sipwise .+/: Sipwise NGCP Proxy/;
  } elsif($line =~ /^Content-Length: [1-9]/i) {
    $line =~ s/: \d+/: \\d+/;
  } elsif($line =~ /^P-LB-Uptime: /i) {
    $line =~ s/: \d+/: \\d+/;
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
  $line = subst_common($line);
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
my $f_ids;
GetOptions ("h|help" => \$help, "f|filter=s" => \@headers, "i|ids=s" => \$f_ids)
  or die("Error in command line arguments\n".usage());

if($#ARGV!=0 || $help)
{
  die(usage())
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
  $uuids = load_ids(abs_path($f_ids));
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
