#!/usr/bin/env perl
use 5.014;
use strict;
use warnings;
use JSON;
use YAML;
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
    YAML::DumpFile($path, $data);
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
}

given($#ARGV)
{
  when (1) { $filename = $ARGV[0]; $output_dir = $ARGV[1]; }
  when (0) { $filename = $ARGV[0]; }
}
$filename = abs_path($filename);
$output_dir = abs_path($output_dir);
my $log;
my $line;
my $out;
open($log, "<$filename") or die "Couldn't open kamailio log, $!";

while($line = <$log>)
{
  my ($mode, $route, $msgid, $msgid_t, $json, $msg, $pjson, $callid, $method);
  # Jun 25 14:52:16 spce proxy[11248]: DEBUG: debugger [debugger_api.c:427]: dbg_cfg_dump(): msg out:{
  if(($msg) = ($line =~ m/.+msg out:{(.+)}$/))
  {
    do
    {
      $msg =~ s/#015#012/\n/g;
      push($data->{'sip_out'}, $msg);
      $line = <$log>;
      #print substr($line, 34, 25)."\n";
      if(!$line) { $line = '' }
    }while(($msg) = ($line =~ m/.+msg out:{(.+)}$/));
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
    $line = <$log>;
    if(($json) = ($line =~ m/.+dbg_dump_json\(\): (\{.*\})$/))
    {
      $pjson = from_json($json);
      push($data->{'flow'}, { $mode."|".$route => $pjson });
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
} #while
if($data->{'msgid'} ne '') { save_data(); }
close($log);
#EOF
