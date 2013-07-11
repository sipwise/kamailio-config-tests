#!/usr/bin/perl
use strict;
use warnings;

use Data::Dumper;
use Getopt::Std;
use Sipwise::Provisioning::Billing;

our %CONFIG = (
               admin    => 'administrator',
               password => 'administrator',
             );

die usage() unless ($#ARGV == 0);

sub main {
    my ($bprov) = @_;

    call_prov_exists( $bprov, 'get_domain',
               {
                    domain => $ARGV[0]
               }
             );
    call_prov( $bprov, 'delete_domain',
               {
                    domain => $ARGV[0]
               }
             );
    exit;
}

sub call_prov_exists {
    #   scalar,    scalar,    hash-ref
    my ($bprov, $function, $parameter) = @_;
    my $result;

    eval {
        $result = $bprov->handle_request( $function,
                                          {
                                            authentication => {
                                                                type     => 'admin',
                                                                username => $CONFIG{admin},
                                                                password => $CONFIG{password},
                                                              },
                                            parameters => $parameter,
                                        });
    };

    if($@) {
        if(ref $@ eq 'SOAP::Fault') {
            exit 0 if($@->faultstring =~ 'unknown domain');
            die "Billing\::$function failed: ". $@->faultstring;
        } else {
            die "Billing\::$function failed: $@";
        }
    }

    return $result;
}

sub call_prov {
    #   scalar,    scalar,    hash-ref
    my ($bprov, $function, $parameter) = @_;
    my $result;

    eval {
        $result = $bprov->handle_request( $function,
                                          {
                                            authentication => {
                                                                type     => 'admin',
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
    die "Usage:\n$0 <domain>\n".
        "\ne.g.: $0 sip.sipwise.com\n";
}

my $bprov = Sipwise::Provisioning::Billing->new();

main($bprov);

