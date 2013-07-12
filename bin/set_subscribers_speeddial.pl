#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use Getopt::Std;
use Sipwise::Provisioning::Voip;
use Cwd 'abs_path';
use YAML;
use DateTime;

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
    my $r = YAML::LoadFile($filename);

    my $now = DateTime->now();
    for my $key (keys $r)
    {
        my @fields = split /@/, $key;
        foreach (@{$r->{$key}})
        {
          my $param = { username => $fields[0], domain => $fields[1], data => $_ };
          call_prov( 'create_speed_dial_slot',  $param);
        }
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
            die "Voip\::$function failed: ". $@->faultstring;
        } else {
            die "Voip\::$function failed: $@";
        }
    }

    return $result;
}

sub usage {
    die "Usage:\n$0 reminder.yml\n";
}
