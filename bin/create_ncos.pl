#!/usr/bin/perl
use strict;
use warnings;

use Getopt::Std;
use Cwd 'abs_path';
use YAML;
use Getopt::Long;
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
    my $result = call_prov( $bprov, 'get_ncos_levels');
    foreach (@{$result})
    {
        if (exists($data->{$_->{level}}))
        {
            call_prov($bprov, 'delete_ncos_level', { level => $_->{level}});
        }
    }
    exit;
}

sub do_create
{
    my ($data) = @_;
    for (keys $data)
    {
        my $ncos = $data->{$_};
        # level
        my $param = { level => $_, data => $ncos->{data} };
        call_prov( $bprov, 'create_ncos_level',  $param );
        # patterns
        $param = { level => $_, patterns => $ncos->{patterns}, purge_existing => 1};
        call_prov( $bprov, 'set_ncos_pattern_list', $param );
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
    return "Usage:\n$0 ncos.yml\n";
}
