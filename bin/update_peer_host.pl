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
    return "Usage:\n$PROGRAM_NAME [-h] [-i IP] [-p PORT]" .
        " peer_host_name\n";
}

my $help = 0;
my $ip;
my $port;
GetOptions ("h|help" => \$help,
            "i|ip=s" => \$ip,
            "p|port=i" => \$port)
  or die("Error in command line arguments\n".usage());

die(usage()) unless (!$help);
die("Wrong number of arguments\n".usage()) unless ($#ARGV == 0);

my $data = {};
$data->{ip} = $ip unless !defined($ip);
$data->{port} = $port unless !defined($port);
die("ip or port option has to be set\n".usage()) unless defined($data);

sub do_update {
    my $host_id = $api->check_peeringserver_exists({ name => $ARGV[0] });
    if($host_id) {
        my $peer_data = $api->get_peeringserver($host_id);
        if($peer_data) {
            $peer_data->{ip} = $data->{ip};
            $peer_data->{port} = $data->{port};
            $api->set_peeringserver($host_id, $peer_data) or
                die("Can't update peer $_->{name}");
            print "peer $ARGV[0] updated [$host_id]\n";
        } else {
            die("Can't get peer data");
        }
    } else {
        die("peer $_->{name} not found");
    }
    return;
}

do_update();
