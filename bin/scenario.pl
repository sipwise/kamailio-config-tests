#!/usr/bin/perl
#
# Copyright: 2013-2015 Sipwise Development Team <support@sipwise.com>
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
use YAML::XS;
use Text::CSV;
use Template;
use Data::Dumper;

sub usage
{
  my $output = "usage: scenario.pl [-h] scenario.yml\n";
  $output .= "Options:\n";
  $output .= "\t-h: this help\n";
  return $output
}

my $help = 0;
my $del = 0;
GetOptions ("h|help" => \$help)
  or die("Error in command line arguments\n".usage());

die(usage()) unless (!$help);
die("Wrong number of arguments\n".usage()) unless ($#ARGV == 0);

my $filename = abs_path($ARGV[0]);
our $base_check_dir = dirname($filename);
my $cf = YAML::XS::LoadFile($filename);

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
        if (defined($data_sub->{$domain}->{$data->{username}}))
        {
            my $username = $data->{username};
            my $subs = $data_sub->{$domain}->{$username};
            $data->{password} = $subs->{password};
            if(defined($data->{devid})) {
                $_->{auth_username} = $data->{devid};
                $_->{number} = $data->{devid};
                check_devid($subs, $data->{devid});
            } else {
                $data->{devid} = $data->{username};
                $data->{auth_username} = $data->{username};
                eval { $data->{number} = $subs->{cc}.$subs->{ac}.$subs->{sn}; } unless defined($presence);
            }
            $data->{'pbx_extension'} = $subs->{'pbx_extension'};
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

    foreach (@{$data->{scenarios}})
    {
        eval { get_subs_info($data->{subscribers}, $_); };
        $_->{password} = "" unless defined($_->{password});
        # by default proto is udp
        $_->{proto} = "udp" unless defined($_->{proto});
        $_->{password_wrong} = "no" unless defined($_->{password_wrong});
        if($_->{password_wrong} eq "yes")
        {
            $_->{password} = "wrongpass";
        }
        my $auth   = "[authentication username=$_->{auth_username} password=$_->{password}]";
        my $csv_data = [$_->{devid}, $auth, $_->{domain}, $test_uuid, $_->{'pbx_extension'}];
        $csv->{caller}->print($io_caller, $csv_data);
        $csv_data = ["sipp_scenario".sprintf("%02i", $id).".xml", $_->{proto}, $_->{ip}];
        $csv->{scenario}->print($io_scenario, $csv_data);
        foreach (@{$_->{responders}})
        {
            # by default foreign is no
            $_->{foreign} = "no" unless defined($_->{foreign});
            if(not defined($_->{peer_host}) and $_->{foreign} ne "yes")
            {
                get_subs_info($data->{subscribers}, $_);
            }
            $_->{password} = "" unless defined($_->{password});
            # by default responder is active
            $_->{active} = "yes" unless defined($_->{active});
            # by default peer_host is empty
            $_->{peer_host} = "" unless defined($_->{peer_host});
            # by default proto is udp
            $_->{proto} = "udp" unless defined($_->{proto});
            $auth   = "[authentication username=$_->{auth_username} password=$_->{password}]";
            $csv_data = [$_->{devid}, $_->{number}, $auth, $_->{domain}, $test_uuid, $_->{'pbx_extension'}];
            $csv->{callee}->print($io_callee, $csv_data);
            $csv_data = ["sipp_scenario_responder".sprintf("%02i", $res_id).".xml", $_->{proto}, $_->{ip}, $_->{peer_host}, $_->{foreign}, $_->{register}, $_->{username}."@".$_->{domain}];
            $csv->{scenario}->print($io_scenario, $csv_data);
            if($_->{register} eq "yes" && $_->{active} eq "yes")
            {
                generate_reg($res_id, $test_uuid, $_->{q});
            }
            if($_->{foreign} eq "yes")
            {
                generate_foreign_dom($_->{domain}, $_->{ip});
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
    foreach (@{$data->{presence}})
    {
        eval { get_subs_info($data->{subscribers}, $_); };
        $_->{password} = "" unless defined($_->{password});
        my $vars = { users => @{$_->{allow}} };
        my $fn = File::Spec->catfile($base_check_dir, "presence_".$_->{username}."_".$_->{domain}.".xml");
        $tt->process($template_presence, $vars, $fn) or die($tt->error(), "\n");
        undef $fn;
        my $digest = $_->{username}."@".$_->{domain}.":".$_->{password};
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

generate($cf);
generate_presence($cf);
