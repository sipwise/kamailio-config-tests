#!/usr/bin/perl
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
    return "Usage:\n$PROGRAM_NAME [-h]" .
        " subscriber IP PORT\n";
}

my $help = 0;
GetOptions ("h|help" => \$help,
            "d|debug" => \$opts->{verbose})
  or die("Error in command line arguments\n".usage());

die(usage()) unless (!$help);
die("Wrong number of arguments\n".usage()) unless ($#ARGV == 2);

my $data = {ip=> $ARGV[1], port=>$ARGV[2]};
my ($subscriber, $domain) = split /@/, $ARGV[0];

sub do_update {
    my $subs_id = $api->check_subscriber_exists({
                          domain => $domain,
                          username => $subscriber});
    if(!$subs_id) {
        die("Error: No subscriber ${subscriber}\@${domain} found");
    }
    my $regs = $api->get_subscriber_registrations($subs_id);
    foreach my $r (@{$regs}) {
        print "registration[$r->{id}]: $r->{contact}\n";
        if($r->{contact} =~ m/sip:$data->{ip}:/) {
            $r->{contact} = "sip:". $data->{ip}. ":" . $data->{port};
            $api->set_subscriber_registration($r->{id}, $r) or
                die("Can't update permanent registration $r->{id}");
            print "registration for ${ARGV[0]}[$r->{id}] updated to $r->{contact}\n";
        }
    }
    return;
}

do_update();
