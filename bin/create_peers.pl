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
use Getopt::Std;
use Cwd 'abs_path';
use YAML;
use Getopt::Long;
use Sipwise::Provisioning::Voip;
use Sipwise::Provisioning::Billing;
use Sipwise::Provisioning::Config;

our %CONFIG = ( admin    => 'cmd' );

my $config = Sipwise::Provisioning::Config->new()->get_config();

unless ($CONFIG{password} = $config->{acl}->{$CONFIG{admin}}->{password}) {
  die "Error: No provisioning password found for user $CONFIG{admin}\n";
}

sub usage;
sub call_prov;

my $help = 0;
my $del = 0;
GetOptions ("h|help" => \$help,
            "d|delete" => \$del)
  or die("Error in command line arguments\n".usage());

die(usage()) unless (!$help);
die("Wrong number of arguments\n".usage()) unless ($#ARGV == 0);

our $bprov = Sipwise::Provisioning::Billing->new();
our $vprov = Sipwise::Provisioning::Voip->new();

if ($del)
{
    do_delete();
}
else
{
    do_create();
}

sub do_delete
{
    my $filename = abs_path($ARGV[0]);
    my $r = YAML::LoadFile($filename);

    for (keys $r)
    {
        my $peer_name = $_;
        my $peer = $r->{$peer_name};
        # groups
        my $group = {};
        my $result = call_prov( $vprov, 'get_peer_groups');
        foreach (@{$result})
        {
            $group->{$_->{name}} = $_->{id};
        }
        foreach (@{$peer->{groups}})
        {
            if (exists($group->{$_->{name}}))
            {
              call_prov($vprov, 'delete_peer_group', {id => $group->{$_->{name}}});
            }
        }
        # contracts
        $result = call_prov( $bprov, 'get_sip_peering_contracts');
        foreach (@{$result})
        {
            my $contact = $_->{contact};
            if(defined($contact->{company}))
            {
                if ($contact->{company} eq $peer_name)
                {
                    call_prov($bprov, 'delete_sip_peering_contract', { id => $_->{id}});
                }
            }
        }
    }
    exit;
}

sub do_create {
    my $filename = abs_path($ARGV[0]);
    my $r = YAML::LoadFile($filename);

    for (keys $r)
    {
        my $peer = $r->{$_};
        # contract
        my $param = { data => $peer->{contract} };
        my $contract_id = call_prov( $bprov, 'create_sip_peering_contract',  $param );
        # groups
        my $group = {}; # name = id
        foreach (@{$peer->{groups}})
        {
            $_->{peering_contract_id} = $contract_id;
            call_prov( $vprov, 'create_peer_group', $_ );
        }
        my $result = call_prov( $vprov, 'get_peer_groups');
        foreach (@{$result})
        {
            $group->{$_->{name}}->{id} = $_->{id};
        }
        # rules
        foreach (@{$peer->{rules}})
        {
            $_->{group_id} = $group->{$_->{group_id}}->{id};
            call_prov($vprov, 'create_peer_rule', $_);
        }
        # hosts
        my $host = {};
        foreach (@{$peer->{hosts}})
        {
            $host->{$_->{data}->{name}} = { preferences => delete $_->{preferences}};
            $_->{group_id} = $group->{$_->{group_id}}->{id};
            call_prov($vprov, 'create_peer_host', $_);
        }
        foreach (keys $group)
        {
            my $result = call_prov( $vprov, 'get_peer_group_details', {id=>$group->{$_}->{id}});
            foreach (@{$result->{peers}})
            {
                if(exists($host->{$_->{name}}))
                {
                    $param = { id => $_->{id}, preferences => $host->{$_->{name}}->{preferences}};
                    call_prov($vprov, 'set_peer_preferences', $param);
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
    return "Usage:\n$PROGRAM_NAME peer.yml\n";
}
