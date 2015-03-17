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
use Cwd 'abs_path';
use YAML;
use Getopt::Long;
use Sipwise::Provisioning::Voip;
use Sipwise::Provisioning::Billing;
use Sipwise::Provisioning::Config;
use Data::Dumper;

our %CONFIG = ( admin    => 'cmd' );

my $config = Sipwise::Provisioning::Config->new()->get_config();

unless ($CONFIG{password} = $config->{acl}->{$CONFIG{admin}}->{password}) {
  die "Error: No provisioning password found for user $CONFIG{admin}\n";
}

sub usage;
sub call_prov;

my $help = 0;
my $ip;
my $port;
GetOptions ("h|help" => \$help,
            "i|ip=s" => \$ip,
            "p|port=i" => \$port)
  or die("Error in command line arguments\n".usage());

die(usage()) unless (!$help);
die("Wrong number of arguments\n".usage()) unless ($#ARGV == 1);

our $bprov = Sipwise::Provisioning::Billing->new();
our $vprov = Sipwise::Provisioning::Voip->new();
my $data;
$data->{ip} = $ip unless !defined($ip);
$data->{port} = $port unless !defined($port);
die("ip or port option has to be set\n".usage()) unless defined($data);

print Dumper($data), "\n";

do_update($data);

sub do_update {
    my ($data) = @_;
    my $filename = abs_path($ARGV[1]);
    my $r = YAML::LoadFile($filename);

    for (keys $r)
    {
        my $peer = $r->{$_};
        # groups
        my $group = {}; # name = id
        my $result = call_prov( $vprov, 'get_peer_groups');
        foreach (@{$result})
        {
            $group->{$_->{name}} = $_->{id};
        }
        for (keys $group)
        {
            $result = call_prov( $vprov, 'get_peer_group_details', { id => $group->{$_} });
            foreach (@{$result->{peers}})
            {
                if ($_->{name} eq $ARGV[0])
                {
                    my $param = {
                        id => $_->{id},
                        data => $data
                    };
                    call_prov( $vprov, 'update_peer_host', $param);
                }
            }
        }
    }
    exit;
}

sub call_prov {
    #   scalar,    scalar,    hash-ref
    my ($prov, $function, $parameter) = @_;
    my $result;

    eval {
        $result = $prov->handle_request( $function,
                                          {
                                            authentication => {
                                                                type     => 'system',
                                                                username => $CONFIG{admin},
                                                                password => $CONFIG{password},
                                                              },
                                            parameters => $parameter,
                                        });
    };

    if($EVAL_ERROR) {
        if(ref $EVAL_ERROR eq 'SOAP::Fault') {
            die "Voip\::$function failed: ". $EVAL_ERROR->faultstring;
        } else {
            die "Voip\::$function failed: $EVAL_ERROR";
        }
    }

    return $result;
}

sub usage {
    return "Usage:\n$PROGRAM_NAME [-h] [-i IP] [-p PORT]" .
        " peer_host_name peer.yml\n";
}
