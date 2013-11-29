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

use Getopt::Long;
use Cwd 'abs_path';
use File::Basename;
use File::Spec;
use IO::File;
use YAML;
use Text::CSV;
use Template;

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
my $cf = YAML::LoadFile($filename);

our $bin_dir = '/usr/share/kamailio-config-tests/bin';
our $template_dir = '/usr/share/kamailio-config-tests/scenarios/templates';
if (exists $ENV{'BASE_DIR'})
{
  $bin_dir = File::Spec->catfile(abs_path($ENV{'BASE_DIR'}), 'bin');
  $template_dir = File::Spec->catfile(abs_path($ENV{'BASE_DIR'}), 'scenarios', 'templates');
}
our $template_reg = 'sipp_scenario_responder_reg.xml.tt2';

our $tt = Template->new({
    INCLUDE_PATH => $template_dir,
    INTERPOLATE  => 1,
}) || die "$Template::ERROR\n";

sub new_csv
{
    return Text::CSV->new ( { quote_char => undef, sep_char => ';', eol => "\n" } )
                 or die "Cannot use CSV: ".Text::CSV->error_diag();
}

sub get_subs_info
{
    my ($data_sub, $data) = @_;
    if (defined($data_sub->{$data->{domain}}))
    {
        my $domain = $data->{domain};
        if (defined($data_sub->{$domain}->{$data->{username}}))
        {
            my $username = $data->{username};
            my $subs = $data_sub->{$domain}->{$username};
            $data->{password} = $subs->{password};
            eval { $data->{number} = $subs->{cc}.$subs->{ac}.$subs->{sn}; };
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

    $csv->{caller}->print($io_caller, $seq);
    $csv->{callee}->print($io_callee, $seq);

    foreach (@{$data->{scenarios}})
    {
        eval { get_subs_info($data->{subscribers}, $_); };
        $_->{password} = "" unless defined($_->{password});
        my $auth   = "[authentication username=$_->{username} password=$_->{password}]";
        my $csv_data = [$_->{username}, $auth, $_->{domain}];
        $csv->{caller}->print($io_caller, $csv_data);
        $csv_data = ["sipp_scenario".sprintf("%02i", $id).".xml", $_->{ip}];
        $csv->{scenario}->print($io_scenario, $csv_data);
        foreach (@{$_->{responders}})
        {
            get_subs_info($data->{subscribers}, $_) unless defined($_->{peer_host});
            $_->{password} = "" unless defined($_->{password});
            # by default responder is active
            $_->{active} = "yes" unless defined($_->{active});
            # by default peer_host is empty
            $_->{peer_host} = "" unless defined($_->{peer_host});
            $auth   = "[authentication username=$_->{username} password=$_->{password}]";
            $csv_data = [$_->{username}, $_->{number}, $auth, $_->{domain}];
            $csv->{callee}->print($io_callee, $csv_data);
            $csv_data = ["sipp_scenario_responder".sprintf("%02i", $res_id).".xml", $_->{ip}, $_->{peer_host}];
            $csv->{scenario}->print($io_scenario, $csv_data);
            if($_->{register} eq "yes" && $_->{active} eq "yes")
            {
                generate_reg($res_id)
            }
            $res_id++;
        }
        $id++;
    }
}

sub generate_reg
{
    my ($num) = @_;
    my $vars = { line => $num };
    my $fn = File::Spec->catfile($base_check_dir, "sipp_scenario_responder".(sprintf "%02i", $num)."_reg.xml");
    $tt->process($template_reg, $vars, $fn) or die($tt->error(), "\n");
}

generate($cf);
