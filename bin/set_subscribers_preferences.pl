#!/usr/bin/perl -w
use strict;

use Data::Dumper;
use Getopt::Std;
use Sipwise::Provisioning::Billing;
use Cwd 'abs_path';
use YAML;

my %CONFIG = (
               admin    => 'administrator',
               password => 'administrator',
             );

sub main;
sub usage;
sub call_prov;

die usage() unless ($#ARGV == 0);

my $bprov = Sipwise::Provisioning::Voip->new();

main;

sub main {
    my $filename = abs_path($ARGV[0]);
    my $prefs = YAML::LoadFile($filename);

    for my $key (keys $prefs)
    {
        my @fields = split /@/, $key;
        my $pref = { username => $fields[0], domain => $fields[1], preferences => $prefs->{$key} };
        print "Setting $key prefs\n";
        print Dumper $pref;
        call_prov( 'set_subscriber_preferences',  $pref);
    }

    exit;
}

sub call_prov {
    #   scalar,    scalar,    hash-ref
    my ($function, $parameter) = @_;
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
    die "Usage:\n$0 prefs.yml\n";
}
