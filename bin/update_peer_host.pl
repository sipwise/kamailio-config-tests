#!/usr/bin/perl
use strict;
use warnings;

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
    return "Usage:\n$0 [-h] [-i IP] [-p PORT] peer_host_name peer.yml\n";
}
