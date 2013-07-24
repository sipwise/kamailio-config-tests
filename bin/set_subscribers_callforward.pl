#!/usr/bin/perl
use strict;
use warnings;

use Getopt::Std;
use Cwd 'abs_path';
use YAML;
use Sipwise::Provisioning::Voip;
use Sipwise::Provisioning::Config;

our %CONFIG = ( admin    => 'cmd' );

my $config = Sipwise::Provisioning::Config->new()->get_config();

unless ($CONFIG{password} = $config->{acl}->{$CONFIG{admin}}->{password}) {
  die "Error: No provisioning password found for user $CONFIG{admin}\n";
}

sub main;
sub usage;
sub call_prov;

die usage() unless ($#ARGV == 0);

my $bprov = Sipwise::Provisioning::Voip->new();

main;

sub main {
    my $filename = abs_path($ARGV[0]);
    my $cf = YAML::LoadFile($filename);

    for my $key (keys $cf)
    {
        my @fields = split /@/, $key;
        my $param;
        # cf_set
        my $set = {}; # name -> set_id
        my $time = {}; # name -> time_id 
        foreach my $s (@{$cf->{$key}->{'destination_set'}})
        {
          $param = { username => $fields[0], domain => $fields[1], data => $s };
          call_prov( 'create_subscriber_cf_destination_set',  $param);
        }
        $param = { username => $fields[0], domain => $fields[1] };
        my $result = call_prov('get_subscriber_cf_destination_sets', $param);
        # name -> set_id
        foreach my $r (@{$result})
        {
          $set->{$r->{'name'}} = $r->{'id'};
        }
        # time_set
        foreach my $t (@{$cf->{$key}->{'time_set'}})
        {
          $param = { username => $fields[0], domain => $fields[1], data => $t };
          call_prov( 'create_subscriber_cf_time_set',  $param);
        }
        $param = { username => $fields[0], domain => $fields[1] };
        $result = call_prov('get_subscriber_cf_time_sets', $param);
        # name -> time_id
        foreach my $r (@{$result})
        {
          $time->{$r->{'name'}} = $r->{'id'};
        }
        # cf_map
        foreach my $m (@{$cf->{$key}->{'map'}})
        {
          $m->{'destination_set_id'} = $set->{$m->{'destination_set_id'}};
          if(exists($m->{'time_set_id'}))
          {
            $m->{'time_set_id'} = $time->{$m->{'time_set_id'}};
          }
          $param = { username => $fields[0], domain => $fields[1], data => $m };
          call_prov( 'create_subscriber_cf_map',  $param);
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
    die "Usage:\n$0 callforward.yml\n";
}
