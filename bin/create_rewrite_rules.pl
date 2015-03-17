#!/usr/bin/perl
#
# Copyright: 2013 Sipwise Development Team <support@sipwise.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This package is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# On Debian systems, the complete text of the GNU General
# Public License version 3 can be found in "/usr/share/common-licenses/GPL-3".
#
use strict;
use warnings;

use English;
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

    if($EVAL_ERROR) {
        if(ref $EVAL_ERROR eq 'SOAP::Fault') {
            die "Voip\::$function failed: ". $EVAL_ERROR->faultstring;
        } else {
            die "Voip\::$function failed: $EVAL_ERROR";
        }
    }

    return $result;
}

sub usage {
    return "Usage:\n$PROGRAM_NAME scenario.yml\n";
}
