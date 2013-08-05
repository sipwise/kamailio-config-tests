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

my $filename = abs_path($ARGV[0]);
my $r = YAML::LoadFile($filename);

if ($del)
{
    do_delete($r);
}
else
{
    do_create($r);
}

sub do_delete
{
    my ($data) = @_;
    for my $rule_set_name (keys $data)
    {
        my $rule_set;
        my $result = call_prov( $vprov, 'get_rewrite_rule_sets');
        foreach (@{$result})
        {
            $rule_set->{$_->{name}} = $_->{id};
        }
        if ($rule_set)
        {
            for my $rule_set_name (keys $rule_set)
            {
                call_prov($vprov, 'delete_rewrite_rule_set', {id => $rule_set->{$rule_set_name}});
            }
        }
    }
    exit;
}

sub do_create
{
    my ($data) = @_;
    for my $rule_set_name (keys $data)
    {
        my $param = { name => $rule_set_name };
        call_prov( $vprov, 'create_rewrite_rule_set',  $param );
    }
    my $rule_set;
    my $result = call_prov( $vprov, 'get_rewrite_rule_sets');
    foreach (@{$result})
    {
        $rule_set->{$_->{name}} = $_->{id};
    }
    # rules
    for my $rule_set_name (keys $data)
    {
        my $rs = $data->{$rule_set_name};
        foreach (@{$rs})
        {
            my $param = { set_id => $rule_set->{$rule_set_name}, data => $_ };
            call_prov($vprov, 'create_rewrite_rule', $param);
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
    return "Usage:\n$0 scenario.yml\n";
}
