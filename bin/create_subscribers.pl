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

use YAML;
use Getopt::Long;
use Sipwise::Provisioning::Billing;
use Sipwise::Provisioning::Config;

our %CONFIG = ( admin    => 'cmd' );

my $config = Sipwise::Provisioning::Config->new()->get_config();

unless ($CONFIG{password} = $config->{acl}->{$CONFIG{admin}}->{password}) {
  die "Error: No provisioning password found for user $CONFIG{admin}\n";
}

our %BILLING = (
#                product         => 'handle',
                billing_profile => 'default',
              );

sub usage {
    die "Usage:\n$0 scenario.yml\n".
        "Options:\n".
        "  -h this help\n";
}
my $help = 0;
my $debug = 0;
GetOptions ("h|help" => \$help, "d|debug" => \$debug)
  or die("Error in command line arguments\n".usage());

die(usage()) unless (!$help);
die("Wrong number of arguments\n".usage()) unless ($#ARGV == 0);

sub main
{
    my ($data, $bprov) = @_;
    my @subs;
    foreach my $domain (keys %{$data})
    {
        foreach my $username (keys %{$data->{$domain}})
        {
            my $s = $data->{$domain}->{$username};
            $s->{username} = $username;
            $s->{domain} = $domain;
            push(@subs, $s);
            if($debug) { print("$username@$domain read\n"); }
        }
    }
    if(@subs)
    {
        call_prov( $bprov, 'create_voip_account', { data => { %BILLING, subscribers => \@subs }});
        if($debug) { print("created ".($#subs+1)." subscribers"); }
    }
}

sub call_prov {
    #   scalar,    scalar,    hash-ref
    my ($bprov, $function, $parameter) = @_;
    my $result;

    eval {
        $result = $bprov->handle_request( $function,
                                          {
                                            authentication => {
                                                                type     => 'system',
                                                                username => $CONFIG{admin},
                                                                password => $CONFIG{password},
                                                              },
                                            parameters => $parameter,
                                        });
    };

    if($@) {
        if(ref $@ eq 'SOAP::Fault') {
            die "Billing\::$function failed: ". $@->faultstring;
        } else {
            die "Billing\::$function failed: $@";
        }
    }

    return $result;
}

my $cf = YAML::LoadFile($ARGV[0]);
my $bprov = Sipwise::Provisioning::Billing->new();

main($cf->{subscribers}, $bprov);

