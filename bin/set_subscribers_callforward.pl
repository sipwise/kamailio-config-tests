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
  return  "Usage:\n$PROGRAM_NAME callforward.yml\n".
          "Options:\n".
          "  -d debug\n".
          "  -h this help\n";
}
my $help = 0;
GetOptions(
  "h|help" => \$help,
  "d|debug" => \$opts->{verbose}
) or die("Error in command line arguments\n".usage());

die(usage()) unless (!$help);
die("Wrong number of arguments\n".usage()) unless ($#ARGV == 0);

sub set_subscriber_callforward
{
  my $subscriber = shift;
  my $domain = shift;
  my $prefs = shift;
  my $subs_id = $api->check_subscriber_exists({
                          domain => $domain,
                          username => $subscriber});
  if($subs_id) {
    my $res = $api->set_subscriber_callforward($subs_id, $prefs);
    if($opts->{verbose}) {
      print Dumper $res;
    }
    if($res) {
      print "callforward created for ${subscriber}\@${domain} [$subs_id]\n";
    } else {
      die("Error: callforward failed for ${subscriber}\@${domain} [$subs_id]");
    }
  }
  else {
    die("Error: No subscriber ${subscriber}\@${domain} found");
  }
  return;
}

sub set_subscriber_voicemailsettings
{
  my $subscriber = shift;
  my $domain = shift;
  my $prefs = shift;
  my $subs_id = $api->check_subscriber_exists({
                          domain => $domain,
                          username => $subscriber});
  if($subs_id) {
    my $res = $api->set_subscriber_voicemailsettings($subs_id, $prefs);
    if($opts->{verbose}) {
      print Dumper $res;
    }
    if($res) {
      print "voicemailsetting created for ${subscriber}\@${domain} [$subs_id]\n";
    } else {
      die("Error: voicemailsetting failed for ${subscriber}\@${domain} [$subs_id]");
    }
  }
  else {
    die("Error: No subscriber ${subscriber}\@${domain} found");
  }
  return;
}

sub main {
    my $r = YAML::XS::LoadFile(abs_path($ARGV[0]));

    for my $key (keys %{$r})
    {
        my @fields = split /@/, $key;
        my $voicemail = delete $r->{$key}->{voicebox};
        set_subscriber_callforward($fields[0], $fields[1], $r->{$key});
        if ($voicemail) {
          set_subscriber_voicemailsettings($fields[0], $fields[1], $voicemail);
        }
    }
    return;
}

main();
