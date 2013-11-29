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

use Getopt::Std;
use Cwd 'abs_path';
use YAML;
use Sipwise::Provisioning::Voip;
use Sipwise::Provisioning::Config;
use Data::Dumper;

our %CONFIG = ( admin    => 'cmd' );

my $config = Sipwise::Provisioning::Config->new()->get_config();

unless ($CONFIG{password} = $config->{acl}->{$CONFIG{admin}}->{password}) {
  die "Error: No provisioning password found for user $CONFIG{admin}\n";
}

sub main;
sub usage;
sub call_prov;

die usage() unless ($#ARGV == 0);

our $vprov = Sipwise::Provisioning::Voip->new();

main();

sub get_peers
{
    my $peers;
    my $result = call_prov( $vprov, 'get_peer_groups');
    foreach (@{$result})
    {
        my $res = call_prov( $vprov, 'get_peer_group_details', {id=>$_->{id}});
        foreach (@{$res->{peers}})
        {
            $peers->{$_->{name}} = $_->{id};
        }
    }
    return $peers;
}

sub get_rewrites
{
    my $rule_set;
    my $result = call_prov( $vprov, 'get_rewrite_rule_sets');
    foreach (@{$result})
    {
        $rule_set->{$_->{name}} = $_->{id};
    }
    return $rule_set;
}

sub main {
    my $filename = abs_path($ARGV[0]);
    my $prefs = YAML::LoadFile($filename);
    my $peers;
    my $rule_set;

    for my $key (keys $prefs)
    {
        if (exists($prefs->{$key}->{rewrite_rule_set}))
        {
            if(!$rule_set) { $rule_set = get_rewrites($vprov); }
            if (exists($rule_set->{$prefs->{$key}->{rewrite_rule_set}}))
            {
                $prefs->{$key}->{rewrite_rule_set} = $rule_set->{$prefs->{$key}->{rewrite_rule_set}};
            }
            else
            {
                die("No rewrite_rule_set:$prefs->{$key}->{rewrite_rule_set} found");
            }
        }
        if ( $key =~ /@/ )
        {
            my @fields = split /@/, $key;
            if (!$fields[0])
            {
                my $pref = { domain => $fields[1], preferences => $prefs->{$key} };
                call_prov( $vprov, 'set_domain_preferences',  $pref);
            }
            else
            {
                my $pref = { username => $fields[0], domain => $fields[1], preferences => $prefs->{$key} };
                call_prov( $vprov, 'set_subscriber_preferences',  $pref);
            }
        }
        else
        {
            if (!$peers) { $peers = get_peers($vprov); }
            my $pref = { id => $peers->{$key}, preferences => $prefs->{$key} };
            call_prov( $vprov, 'set_peer_preferences',  $pref);
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

    if($@) {
        if(ref $@ eq 'SOAP::Fault') {
            die "Billing\::$function failed: ". $@->faultstring;
        } else {
            die "Billing\::$function failed: $@";
        }
    }

    return $result;
}

sub usage {
    die "Usage:\n$0 prefs.yml\n";
}
