#!/usr/bin/perl
use strict;
use warnings;

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
            if ($_->{contact}->{company} eq $peer_name)
            {
                call_prov($bprov, 'delete_sip_peering_contract', { id => $_->{id}});
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

    if($@) {
        if(ref $@ eq 'SOAP::Fault') {
            die "Voip\::$function failed: ". $@->faultstring;
        } else {
            die "Voip\::$function failed: $@";
        }
    }

    return $result;
}

sub usage {
    return "Usage:\n$0 peer.yml\n";
}
