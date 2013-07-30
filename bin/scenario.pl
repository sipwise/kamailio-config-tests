#!/usr/bin/perl
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

our $bin_dir = '/usr/local/src/kamailio-config-tests/bin';
our $template_dir = '/usr/local/src/kamailio-config-tests/scenarios/templates';
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

sub generate
{
    my $id = 0;
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

    foreach (@{$data})
    {
        my $res_id = 0;
        my $user   = $_->{user};
        my $domain = $_->{domain};
        my $auth   = "[authentication username=$_->{username} password=$_->{password}]";
        my $csv_data = [$user, $auth, $domain];
        $csv->{caller}->print($io_caller, $csv_data);
        $csv_data = ["sipp_scenario".sprintf("%02i", $id).".xml", $_->{ip}];
        $csv->{scenario}->print($io_scenario, $csv_data);
        foreach (@{$_->{responders}})
        {
            $user   = $_->{user};
            $domain = $_->{domain};
            my $number = $_->{number};
            $auth   = "[authentication username=$_->{username} password=$_->{password}]";
            $csv_data = [$user, $number, $auth, $domain];
            $csv->{callee}->print($io_callee, $csv_data);
            $csv_data = ["sipp_scenario_responder".sprintf("%02i", $res_id).".xml", $_->{ip}];
            $csv->{scenario}->print($io_scenario, $csv_data);
            if($_->{register} eq "yes")
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

generate($cf->{scenarios});
