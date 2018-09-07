#!/usr/bin/env perl
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
use 5.014;
use strict;
use warnings;
use English;
use JSON;
use YAML::XS;
use File::Spec;
use Cwd 'abs_path';
use Data::Dumper;
use Tie::File;
use Getopt::Long;

my $filename = "/var/log/ngcp/kamailio-proxy.log";
my $output_dir = "log";

sub usage
{
  my $output = "usage: ulog_parser.pl [-h] [kamailio_log] [dest_dir]\n";
  $output .= "Options:\n";
  $output .= "\t-h: this help\n";
  $output .= "\tkamailio_log default:$filename\n";
  $output .= "\tdest_dir default:$output_dir\n";
  return $output
}

my $help = 0;
GetOptions ("h|help" => \$help)
  or die("Error in command line arguments\n".usage());

if($#ARGV>=2 || $help)
{
  die(usage())
}

my $path;
my $data = {
  msgid => '',
  callid => '',
  flow => [],
  sip_in => '',
  sip_out => [],
};

sub save_data
{
  if(!$data->{'msgid'})
  {
    print "data with no msgid\n";
    print Dumper $data;
    exit;
  }
  else
  {
    if (!$data->{'sip_out'}) { print "no sip_out\n"; }
    $path = File::Spec->catfile( $output_dir, (sprintf "%04i", $data->{'msgid'}).".yml");
    YAML::XS::DumpFile($path, $data);
    #print "$data->{'msgid'} saved\n";
    # This tries to fix problems with string values '-' being saved
    # without quotes.
    tie my @array, 'Tie::File', $path or die ('Can not open $path');
    for (@array)
    {
      s/(.*\$\w+\(\w+\):) -/$1 '-'/g
    }
    untie @array;
  }
  $data = {
    msgid => '',
    callid => '',
    flow => [],
    sip_in => '',
    sip_out => [],
  };
  return;
}

my $pid;
my $log;
my $line;
sub first_line
{
  $pid="unknown";
  my $pid_read;
  do
  {
    $line = <$log>;
    #print "read line\n";
    if(!$line) { $line = ''; return ($line ne '');}
    else
    {
      ($pid_read) = ($line =~ m/.+proxy\[(\d+)\]: DEBUG: <script>: start of route MAIN.*$/);
        if($pid_read) {
            $pid = $pid_read;
            #print "pid:".$pid."\n";
        }
        else {
          $pid_read = '';
          #print "what?".$line."\n";
        }
    }
  } while($pid_read ne $pid);
  return ($line ne '');
}

sub next_line
{
  my $pid_read;
  do
  {
    $line = <$log>;
    #print "read line\n";
    if(!$line) { $line = ''; return ($line ne '');}
    else
    {
      ($pid_read) = ($line =~ m/.+proxy\[(\d+)\]: DEBUG:.*$/);
        if($pid_read) {
          if(!$pid) {
            $pid = $pid_read;
            #print "pid:".$pid."\n";
          }
        }
        else {
          $pid_read = '';
          #print "what?".$line."\n";
        }
    }
  } while($pid_read ne $pid);
  return ($line ne '');
}

if (@ARGV == 2) {
  $filename = $ARGV[0]; $output_dir = $ARGV[1];
} elsif (@ARGV == 1) {
  $filename = $ARGV[0];
}
$filename = abs_path($filename);
$output_dir = abs_path($output_dir);
my $out;
open($log, '<', "$filename") or die "Couldn't open kamailio log, $ERRNO";

first_line();
do
{
  my ($mode, $route, $msgid, $msgid_t, $json, $msg, $pjson, $callid, $method);
  # Jun 25 14:52:16 spce proxy[11248]: DEBUG: debugger [debugger_api.c:427]: dbg_cfg_dump(): msg out:{
  if(($msg) = ($line =~ m/.+msg out:\{(.+)\}$/))
  {
    do
    {
      if(($callid) = ($msg =~ m/.+Call-ID: ([^#]+)#015#012.+$/si))
      {
        if($data->{'callid'} eq $callid)
        {
          $msg =~ s/#015#012/\n/g;
          push @{$data->{'sip_out'}}, $msg;
        }
        else
        {
          print "Not this Call-ID[$data->{'callid'}]:$callid\n$msg\n"
        }
      }
      else
      {
        print "No Call-ID\n";
      }
      next_line();
    }while(($msg) = ($line =~ m/.+msg out:\{(.+)\}$/));
    #print "msg_out\n";
  }

  if(($mode, $route, $msgid, $method) = ($line =~ m/.+DEBUG: <script>: (\w+) of route (\w+) - (\d+) (.*)$/))
  {
    if($route eq "MAIN")
    {
      #if ($mode eq "start") { print "$msgid start MAIN\n"; }
      if(($data->{'msgid'}) && ($data->{'msgid'} ne $msgid)) {
        #print "$msgid!=$data->{'msgid'} MAIN->save\n";
        save_data();
      }
      $data->{'msgid'} = $msgid;
    }
    my $prev_line = $line;
    next_line();
    if(!$line)
    {
      print $prev_line;
      close($log);
      die("Error parsing $filename. Malformed debug output\n");
    }
    else
    {
      if(($json) = ($line =~ m/.+dbg_dump_json\(\): (\{.*\})$/))
      {
        $pjson = from_json($json);
        push @{$data->{'flow'}}, { $mode."|".$route => $pjson };
        if ($route eq "MAIN" && $mode eq "start")
        {
          ($msg) = $method;
          if(($callid) = ($msg =~ m/.+Call-ID: ([^#]+)#015#012.+$/si)) { $data->{'callid'} = $callid; }
          $msg =~ s/#015#012/\n/g;
          if($mode eq "start") { $data->{'sip_in'} = $msg; }
        }
        #print $mode."|".$route."\n";
      }
    }
  }
} while(next_line());
if($data->{'msgid'} ne '') { save_data(); }
close($log);
#EOF
