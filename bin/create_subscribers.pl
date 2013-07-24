#!/usr/bin/perl
use strict;
use warnings;

use Getopt::Std;
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
    die "Usage:\n$0 -v <#accounts> -s <#subscribers> -d <domain> -u <userbase> -c <cc> -a <ac> -n <startnumber> [-p <password>]\n".
        "\ne.g.: $0 -v 200 -s 5 -d sip.sipwise.com -u test -a 720 -n 555000\n\n".
        "Options:\n".
        "  -v <#accounts>    how many voip accounts to create\n".
        "  -s <#subscribers> number of subscribers per voip account\n".
        "  -d <domain>       existing domain for subscribers\n".
        "  -u <userbase>     prefix number with this string for SIP usernames\n".
        "  -c <cc>           country code for subscriber numbers\n".
        "  -a <ac>           area code for subscriber numbers\n".
        "  -n <startnumber>  lowest number in available numberblock\n".
        "  -p <password>     static password for all users\n";
}

my %opts;
getopts('v:s:d:u:c:a:n:p:', \%opts);

die usage() unless defined $opts{v} and defined $opts{s} and defined $opts{d}
               and defined $opts{u} and defined $opts{a} and defined $opts{n}
	       and defined $opts{c};

sub main {
    my ($bprov) = @_;
    print "\nCreating $opts{v} accounts with $opts{s} subscribers each.\n";
    print "Numbers go from +$opts{c}-$opts{a}-$opts{n} to +$opts{c}-$opts{a}-".($opts{n} + ($opts{v} * $opts{s} - 1))."\n";

    my $foo = $opts{n};
    my $i = 0;
    my $mod = $opts{s};
    $mod *= int(100/$mod) if $mod < 100;
    for(1 .. $opts{v}) {
        my @subscribers;
        for(1 .. $opts{s}) {
            push @subscribers, { username => $opts{u} . $foo,
                                 domain   => $opts{d},
                                 password => defined $opts{p} ? $opts{p} : $opts{u} . $foo,
                                 cc       => $opts{c},
                                 ac       => $opts{a},
                                 sn       => $foo,
                                 admin    => $_ == 1 ? 1 : 0,
                               };

            $foo++;
            $i++;
        }

        call_prov( $bprov, 'create_voip_account',
                   {
                     data => {
                               %BILLING,
                               subscribers => \@subscribers,
                             }
                   }
                 );
        print "Created $i subscribers.\n" unless $i % $mod;
    }

    print "Created $i subscribers.\n" if $i % 100;
    exit;
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

my $bprov = Sipwise::Provisioning::Billing->new();

main($bprov);

