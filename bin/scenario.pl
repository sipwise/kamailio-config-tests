#!/usr/bin/perl
#
# Copyright: 2013-2021 Sipwise Development Team <support@sipwise.com>
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

use Getopt::Long;
use Cwd 'abs_path';
use File::Basename;
use File::Spec;
use IO::File;
use YAML::XS qw(DumpFile LoadFile);
use Hash::Merge qw(merge);
use Storable 'dclone';
use Text::CSV;
use Template;
use Try::Tiny;
use Data::Dumper;

sub usage
{
  my $output = "usage: scenario.pl [options] scenario.yml scenario_ids.yml\n";
  $output .= "Options:\n";
  $output .= "\t-h: this help\n";
  $output .= "\t--ip: IP\n";
  $output .= "\t--port: base sipp port\n";
  $output .= "\t--mport: base sipp media port\n";
  $output .= "\t--phone: base phone number\n";
  $output .= "\t--peer-ip: peer IP\n";
  $output .= "\t--peer-port: peer base sipp port\n";
  $output .= "\t--peer-mport: peer base sipp media port\n";
  return $output
}

my $ids = {};
my $help = 0;
my $net_data = {
    scen => {
        ip => "127.126.0.1",
        port => 51602,
        mport => 45003,
    },
    peer => {
        ip => "127.0.2.1",
        port => 51602,
        mport => 45003,
    },
};
my $phone = "43:1:1000";
GetOptions (
    "h|help" => \$help,
    "ip=s" => \$net_data->{scen}->{ip},
    "port=i" => \$net_data->{scen}->{port},
    "mport=i" => \$net_data->{scen}->{mport},
    "phone=s" => \$phone,
    "peer-ip=s" => \$net_data->{peer}->{ip},
    "peer-port=i" => \$net_data->{peer}->{port},
    "peer-mport=i" => \$net_data->{peer}->{mport},
) or die("Error in command line arguments\n".usage());

die(usage()) unless (!$help);
die("Wrong number of arguments[$#ARGV]\n".usage()) unless ($#ARGV == 1);

my $filename = abs_path($ARGV[0]);
our $base_check_dir = dirname($filename);
my $cf = LoadFile($filename);

our $bin_dir = '/usr/share/kamailio-config-tests/bin';
our $template_dir = '/usr/share/kamailio-config-tests/scenarios/templates';
if (exists $ENV{'BASE_DIR'})
{
  $bin_dir = File::Spec->catfile(abs_path($ENV{'BASE_DIR'}), 'bin');
  $template_dir = File::Spec->catfile(abs_path($ENV{'BASE_DIR'}), 'scenarios', 'templates');
}
our $template_reg = 'sipp_scenario_responder_reg.xml.tt2';
our $template_presence = 'pres-rules.xml.tt2';

our $tt = Template->new({
    INCLUDE_PATH => $template_dir,
    INTERPOLATE  => 1,
}) || die "$Template::ERROR\n";
our ($phone_cc, $phone_ac, $phone_sn) = split(/:/, $phone);
$phone_sn = int($phone_sn);

sub extra_info
{
    my $data = shift;
    if(defined($data->{extra_info})) {
        $ids->{extra_info} = dclone($data->{extra_info});
    } else {
        $ids->{extra_info} = {};
    }
}

sub key_domain
{
    my $domain = shift;

    my $key_dom = $domain =~ tr/\./_/r;
    return $key_dom =~ tr/\-/_/r;
}

sub replace_devid
{
    my ($data, $old_alias, $alias) = @_;

    foreach my $scen (@{$data->{scenarios}})
    {
        if(defined($scen->{devid})) {
            if($scen->{devid} eq $old_alias) {
                $scen->{devid} = $alias;
            }
        }
        foreach my $resp (@{$scen->{responders}})
        {
            if(defined($resp->{devid})) {
                if($resp->{devid} eq $old_alias) {
                    $resp->{devid} = $alias;
                }
            }
        }
    }
}

sub manage_phones
{
    my ($data) = @_;

    foreach my $domain (sort keys %{$data->{subscribers}}) {
        my $key_dom = key_domain($domain);
        my $pbx_pilot_number = undef;

        push(@{$ids->{domains}}, $key_dom);
        foreach my $subs (sort keys %{$data->{subscribers}->{$domain}}) {
            my $subs_data = $data->{subscribers}->{$domain}->{$subs};
            $ids->{$key_dom}->{$subs}->{cc} = $subs_data->{cc} = $phone_cc;
            $ids->{$key_dom}->{$subs}->{ac} = $subs_data->{ac} = $phone_ac;
            $ids->{$key_dom}->{$subs}->{sn} = $subs_data->{sn} = $phone_sn++;
            $ids->{$key_dom}->{$subs}->{phone_number} = $subs_data->{cc} . $subs_data->{ac} . $subs_data->{sn};
            $subs_data->{phone_number} = $ids->{$key_dom}->{$subs}->{phone_number};
            if(defined($subs_data->{is_pbx_pilot}) && $subs_data->{is_pbx_pilot} == 1) {
                $pbx_pilot_number = $subs_data->{phone_number};
            }
        }
        foreach my $subs (sort keys %{$data->{subscribers}->{$domain}}) {
            my $subs_data = $data->{subscribers}->{$domain}->{$subs};
            foreach (@{$subs_data->{alias_numbers}}) {
                my $old_alias = $_->{cc} . $_->{ac} . $_->{sn};
                my $alias_data = {
                    cc => $phone_cc,
                    ac => $phone_ac,
                    sn => $phone_sn++,
                };
                if(defined($_->{is_devid})) { $alias_data->{is_devid} = $_->{is_devid}; }
                $alias_data->{phone_number} = $alias_data->{cc} . $alias_data->{ac} . $alias_data->{sn};
                replace_devid($data, $old_alias, $alias_data->{phone_number});
                push(@{$ids->{$key_dom}->{$subs}->{alias_numbers}}, $alias_data);
            }
            if(defined($ids->{$key_dom}->{$subs}->{alias_numbers})) {
                $subs_data->{alias_numbers} = $ids->{$key_dom}->{$subs}->{alias_numbers};
            }
            if(defined($subs_data->{pbx_extension})) {
                $ids->{$key_dom}->{$subs}->{pbx_extension} = $subs_data->{pbx_extension};
                $ids->{$key_dom}->{$subs}->{pbx_phone_number} = $pbx_pilot_number.$subs_data->{pbx_extension};
            }
        }
    }
}

sub new_csv
{
    my $r = Text::CSV->new({quote_char => undef, sep_char => ';', eol => "\n"})
        or die("Cannot use CSV: ".Text::CSV->error_diag());
    return $r;
}

sub check_devid
{
    my ($data_sub, $devid) = @_;
    foreach (@{$data_sub->{alias_numbers}}) {
        if ($devid eq $_->{cc}.$_->{ac}.$_->{sn}) {
            die("devid:$devid not defined as is_devid") unless $_->{is_devid};
            return 1;
        }
    }
    die("devid:$devid is not an alias_number");
}

sub get_subs_info
{
    my ($data_sub, $data, $presence) = @_;
    if (defined($data_sub->{$data->{domain}}))
    {
        my $domain = $data->{domain};
        my $key_dom = key_domain($domain);
        if (defined($data_sub->{$domain}->{$data->{username}}))
        {
            my $username = $data->{username};
            my $subs = $data_sub->{$domain}->{$username};
            $data->{password} = $subs->{password};
            if(defined($data->{devid})) {
                $data->{auth_username} = $data->{devid};
                $data->{number} = $data->{devid};
                check_devid($subs, $data->{devid});
            } else {
                $data->{devid} = $username;
                $data->{auth_username} = $username;
                eval { $data->{number} = $subs->{phone_number}; } unless defined($data->{number});
            }
            $data->{'pbx_extension'} = $subs->{'pbx_extension'};
            $data->{alias} = [];
            foreach (@{$subs->{alias_numbers}}) {
                push(@{$data->{alias}}, $_->{phone_number});
            }
        }
        else
        {
            die("username:".$data->{username}."@".$domain." not defined in subscribers");
        }
    }
    else
    {
        die("domain:".$data->{domain}." not defined in subscribers");
    }
    return;
}

sub generate_net_values
{
    my $net = shift;
    my $res = {
        ip => $net->{ip},
        port => $net->{port},
        mport => $net->{mport},
    };
    $net->{port} += 1;
    $net->{mport} += 3;
    return $res;
}

sub peer_data
{
    my $peer_host = shift;
    if(not defined($ids->{$peer_host})) {
        $ids->{$peer_host} = generate_net_values($net_data->{peer});
    }
    return $ids->{$peer_host};
}

sub network_data
{
    my $scen = shift;
    my $hm = Hash::Merge->new('RIGHT_PRECEDENT');
    my $data = {};

    if(defined($scen->{peer_host})) {
        $data->{peer} = $scen->{peer_host};
        $data = $hm->merge($data, peer_data($scen->{peer_host}));
    } else {
        $data = generate_net_values($net_data->{scen});
    }
    if(defined($scen->{devid})) { $data->{devid} = $scen->{devid}; }
    $data->{username} = $scen->{username};
    $scen->{ip} = $data->{ip};
    $scen->{port} = $data->{port};
    $scen->{mport} = $data->{mport};
    if(defined($scen->{domain})) { $data->{domain} = $scen->{domain}; }
    foreach my $resp (@{$scen->{responders}})
    {
        my $rdata = {};
        if(defined($resp->{register}) && $resp->{register} eq "permanent") {
            $rdata->{ip} = $resp->{ip};
            $rdata->{port} = $resp->{port};
            $rdata->{mport} = $resp->{mport};
        } elsif(defined($resp->{peer_host})) {
            $rdata->{peer} = $resp->{peer_host};
            $rdata = $hm->merge($rdata, peer_data($resp->{peer_host}));
        } else {
            $rdata = generate_net_values($net_data->{scen});
        }
        if(defined($resp->{devid})) { $data->{devid} = $resp->{devid}; }
        $rdata->{username} = $resp->{username};
        if (defined($resp->{foreign}) && $resp->{foreign} eq "yes") {
            $rdata->{port} = 5060;
        }
        $resp->{ip} = $rdata->{ip};
        $resp->{port} = $rdata->{port};
        $resp->{mport} = $rdata->{mport};
        if(defined($resp->{domain})) { $rdata->{domain} = $resp->{domain}; }
        if(defined($resp->{register})) {
            $rdata->{register} = $resp->{register};
            $resp->{proto} = 'udp' unless(defined($resp->{proto}));
            $rdata->{proto} = $resp->{proto};
        }
        push @{$data->{responders}}, $rdata;
    }
    push @{$ids->{scenarios}}, $data;
}

sub generate
{
    my $id = 0;
    my $res_id = 0;
    my ($data) = @_;
    my $csv = { callee => new_csv(), caller => new_csv(), scenario => new_csv() };
    my $io_caller = new IO::File(File::Spec->catfile($base_check_dir, "caller.csv"), "w")
        or die("Cannot create file caller.csv");
    my $io_callee = new IO::File(File::Spec->catfile($base_check_dir, "callee.csv"), "w")
        or die("Cannot create file callee.csv");
    my $io_scenario = new IO::File(File::Spec->catfile($base_check_dir, "scenario.csv"), "w")
        or die("Cannot create file scenario.csv");
    my $seq = ["SEQUENTIAL"];
    my $test_uuid = $data->{test_uuid};

    $csv->{caller}->print($io_caller, $seq);
    $csv->{callee}->print($io_callee, $seq);

    foreach my $scen (@{$data->{scenarios}})
    {
        try
        {
            get_subs_info($data->{subscribers}, $scen);
        } catch {
            $scen->{devid} = $scen->{username};
            $scen->{auth_username} = $scen->{username};
            $scen->{alias} = [];
        };
        $scen->{password} = "" unless defined($scen->{password});
        # by default proto is udp
        $scen->{proto} = "udp" unless defined($scen->{proto});
        $scen->{password_wrong} = "no" unless defined($scen->{password_wrong});
        if($scen->{password_wrong} eq "yes")
        {
            $scen->{password} = "wrongpass";
        }
        my $auth   = "[authentication username=$scen->{auth_username} password=$scen->{password}]";
        my $csv_data = [
            $scen->{devid},
            $auth,
            $scen->{domain},
            $test_uuid,
            $scen->{'pbx_extension'},
            @{$scen->{alias}}, # must be the last one!!
        ];
        $csv->{caller}->print($io_caller, $csv_data);
        network_data($scen);
        $csv_data = [
            "sipp_scenario".sprintf("%02i", $id).".xml",
            $scen->{proto},
            $scen->{ip},
            $scen->{port},
            $scen->{mport},
        ];
        $csv->{scenario}->print($io_scenario, $csv_data);
        foreach my $resp (@{$scen->{responders}})
        {
            # by default foreign is no
            $resp->{foreign} = "no" unless defined($resp->{foreign});
            try
            {
                get_subs_info($data->{subscribers}, $resp);
            } catch {
                $resp->{devid} = $resp->{username};
                $resp->{auth_username} = $resp->{username};
                $resp->{alias} = [];
            };
            $resp->{password} = "" unless defined($resp->{password});
            # by default responder is active
            $resp->{active} = "yes" unless defined($resp->{active});
            # by default peer_host is empty
            $resp->{peer_host} = "" unless defined($resp->{peer_host});
            # by default proto is udp
            $resp->{proto} = "udp" unless defined($resp->{proto});
            $auth   = "[authentication username=$resp->{auth_username} password=$resp->{password}]";
            $csv_data = [
                $resp->{devid},
                $resp->{number},
                $auth,
                $resp->{domain},
                $test_uuid,
                $resp->{'pbx_extension'},
                @{$resp->{alias}}, # must be the last one!!
            ];
            $csv->{callee}->print($io_callee, $csv_data);
            $csv_data = [
                "sipp_scenario_responder".sprintf("%02i", $res_id).".xml",
                $resp->{proto},
                $resp->{ip},
                $resp->{port},
                $resp->{mport},
                $resp->{peer_host},
                $resp->{foreign},
                $resp->{register},
                $resp->{username}."@".$resp->{domain}
            ];
            $csv->{scenario}->print($io_scenario, $csv_data);
            if($resp->{register} eq "yes" && $resp->{active} eq "yes")
            {
                generate_reg($res_id, $test_uuid, $resp->{q});
            }
            if($resp->{foreign} eq "yes")
            {
                generate_foreign_dom($resp->{domain}, $resp->{ip});
            }
            $res_id++;
        }
        $id++;
    }
    return;
}

sub generate_reg
{
    my ($num, $test_uuid, $q) = @_;
    my $vars = { line => $num, test_uuid => $test_uuid, q => $q };
    my $fn = File::Spec->catfile($base_check_dir, "sipp_scenario_responder".(sprintf "%02i", $num)."_reg.xml");
    $tt->process($template_reg, $vars, $fn) or die($tt->error(), "\n");
    return;
}

sub generate_presence
{
    my @rules;
    my ($data) = @_;
    foreach my $pres (@{$data->{presence}})
    {
        try {
            get_subs_info($data->{subscribers}, $pres);
        } catch {
            $pres->{auth_username} = $pres->{username};
        };
        $pres->{password} = "" unless defined($pres->{password});
        my $vars = { users => @{$pres->{allow}} };
        my $fn = File::Spec->catfile($base_check_dir, "presence_".$pres->{auth_username}."_".$pres->{domain}.".xml");
        $tt->process($template_presence, $vars, $fn) or die($tt->error(), "\n");
        undef $fn;
        my $digest = $pres->{auth_username}."@".$pres->{domain}.":".$pres->{password};
        push @rules, "$bin_dir/presence.sh $digest $template_dir/$template_presence"
    }
    if(scalar(@rules)>0)
    {
        my $file = "$base_check_dir/presence.sh";
        my $fn = IO::File->new($file, "w") or die("can't create $file");
        print {$fn} "#!/bin/bash\n";
        foreach(@rules)
        {
            print {$fn} "$_\n";
        }
        chmod(0755, $fn);
        undef $fn;
    }
    return;
}

sub generate_foreign_dom
{
    my ($domain, $ip) = @_;
    my $file = "$base_check_dir/hosts";
    my $fn = IO::File->new($file, "w") or die("can't create $file");
    print {$fn} "$ip $domain\n";
    undef $fn;
    return;
}

extra_info($cf);
manage_phones($cf);
generate($cf);
generate_presence($cf);
DumpFile(abs_path($ARGV[1]), $ids);
