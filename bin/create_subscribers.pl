#!/usr/bin/perl
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

