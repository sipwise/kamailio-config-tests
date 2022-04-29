#!/usr/bin/perl
#
# Copyright: 2013-2022 Sipwise Development Team <support@sipwise.com>
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
use English;
use File::Copy qw(cp move);
use File::Spec;
use Getopt::Long;
use strict;
use warnings;
use YAML::XS qw(LoadFile DumpFile);
use Hash::Merge qw(merge);

sub usage
{
  my $output = "usage: $PROGRAM_NAME [-hgct] kct_config.yml MODE\n";
  $output .= "Options:\n";
  $output .= "\t-h: this help\n";
  $output .= "\t-g: scenarios group\n";
  $output .= "\t-c: number of kamailio.proxy.children\n";
  $output .= "\t-t: enable cfgt\n";
  $output .= "\tkct_config.yml: config file for k-c-t environment\n";
  $output .= "\tMODE: on|off\tdefault: off\n";
  return $output
}

my $help = 0;
my $children = 0;
my $group;
my $cfgt = 0;

if (exists $ENV{'GROUP'})
{
  $group = $ENV{'GROUP'};
}
else
{
  $group = "scenarios";
}
GetOptions (
  "h|help" => \$help,
  "g|group=s" => \$group,
  "c|children=i" => \$children,
  "t" => \$cfgt,
) or die("Error in command line arguments\n".usage());

if($#ARGV>1 || $help)
{
  die("Wrong number of arguments\n".usage())
}

my $base_dir = '/usr/share/kamailio-config-tests';
my $file_yaml = '/etc/ngcp-config/config.yml';
my ($kct_conf_yaml, $action) = @ARGV;

$action = 'off' unless defined($action);

if (exists $ENV{'BASE_DIR'})
{
  $base_dir = $ENV{'BASE_DIR'};
}

sub change_config
{
  my $kct_conf = shift;
  my $yaml = LoadFile($file_yaml);
  my $es_test = $kct_conf->{kamailio}->{lb}->{extra_sockets}->{test};
  my $es_other = $kct_conf->{kamailio}->{lb}->{extra_sockets}->{other};

  if ($cfgt)
  {
    print "enable cfgt\n";
    $yaml->{kamailio}{lb}{cfgt} = 'yes';
    $yaml->{kamailio}{proxy}{cfgt} = 'yes';
    $yaml->{b2b}{cfgt} = 'yes';
  }
  $yaml->{kct} = { enable => 'yes' };
  $yaml->{kamailio}{lb}{dns}{use_dns_cache} = 'off';
  $yaml->{kamailio}{lb}{extra_sockets}->{test} = "$es_test->{transport}:$es_test->{ip}:$es_test->{port}";
  $yaml->{kamailio}{lb}{extra_sockets}->{other} = "$es_other->{transport}:$es_other->{ip}:$es_other->{port}";;
  $yaml->{kamailio}{proxy}{children} = $children if($children > 0);
  $yaml->{kamailio}{proxy}{permissions_reload_delta} = 0;
  $yaml->{b2b}{debug} = 'yes';
  $yaml->{witnessd}{gather}{sip_responsiveness} = 'no';
  $yaml->{security}->{ngcp_panel}->{scripts}->{restapi}->{sslverify} = 'no';
  $yaml->{mediator}{interval} = '1';      # Necessary to speedup the creation of the CDRs
  $yaml->{rtpproxy}{delete_delay} = '1';  # Necessary to speedup the deletetion of the used ports in rtpengine
  $yaml->{rtpproxy}{log_level} = '7';
  $yaml->{modules}[0]->{enable} = 'yes'; # dummy module should be the first one

  my $group_yml_file = $base_dir."/".$group."/config.yml";
  if ( -e  $group_yml_file )
  {
    print "load $group_yml_file config file\n";
    my $group_yml = LoadFile($group_yml_file);
    my $hm = Hash::Merge->new('RIGHT_PRECEDENT');
    my $config = $hm->merge( {}, $yaml);
    $yaml = $hm->merge( $config, $group_yml);
  } else {
    print "$group_yml_file not found\n";
  }
  DumpFile($file_yaml, $yaml);
}

if (lc($action) eq "off")
{
  move("${file_yaml}.orig", $file_yaml) or die "Can't restore the orig config ${file_yaml}";
}
else
{
  cp($file_yaml, "${file_yaml}.orig") or die "Copy $file_yaml failed: $ERRNO" unless(-e "${file_yaml}.orig");
  print "loading $kct_conf_yaml\n";
  my $kct_conf = LoadFile($kct_conf_yaml);
  change_config($kct_conf);
}

#EOF
