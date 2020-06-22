#!/usr/bin/perl
#
# Copyright: 2020 Sipwise Development Team <support@sipwise.com>
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
use Getopt::Long;
use Cwd 'abs_path';
use Capture::Tiny qw(capture);
use File::Basename;
use IO::File;
use YAML::XS;
use Readonly;

sub usage
{
  my $output = "usage: $PROGRAM_NAME [-h] scenario.yml\n";
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
Readonly my $SIPWISE_EXTRA_CNF => "/etc/mysql/sipwise_extra.cnf";

if (! -e ${SIPWISE_EXTRA_CNF}) {
  die("Error: missing DB credentials file '${SIPWISE_EXTRA_CNF}'.\n")
}

sub run_cmd {
    my $cmd = shift;
    my $rc = 0;
    my ($out, $err) = capture {
        system($cmd);
        $rc = $CHILD_ERROR >> 8;
    };
    # error adjustments
    if ($err =~ 'Warning: Skipping the data of table mysql\.event') {
        $err = '';
    }
    if ($err =~ 'Warning: Permanently added') {
        $err = '';
    }

    return ($rc, $out, $err);
}

sub clean_kamailio
{
    my $data = shift;
    foreach (@{$data->{scenarios}})
    {
        my $subs = $_->{username}."@".$_->{domain};
        my ($rc, $out, $err) = run_cmd("ngcp-kamcmd proxy ul.rm location ${subs}");
        foreach (@{$_->{responders}})
        {
            $subs = $_->{username}."@".$_->{domain};
            if($_->{register} eq "yes" && $_->{active} eq "yes")
            {
                ($rc, $out, $err) = run_cmd("ngcp-kamcmd proxy ul.rm location ${subs}");
                print("${subs}\n");
            }
        }
    }
    return;
}

sub clean_locations
{
    my ($rc, $out, $err) = run_cmd("mysql --defaults-extra-file=${SIPWISE_EXTRA_CNF}
        kamailio -e 'select count(*) from location;' -s -r");
    print("${out} in location\n");
    if($out gt 0) {
        print("Cleaning location table\n");
        my ($rc, $out, $err) = run_cmd("mysql --defaults-extra-file=${SIPWISE_EXTRA_CNF}
            -e 'select concat(username, \"@\", domain) as user from kamailio.location;'
            -r -s | head| uniq|xargs");
        print("${out}\n");
        foreach (@{$out}) {
            qx/ngcp-kamctl proxy fifo ul.rm location ${_}/;
        }
        qx/mysql --defaults-extra-file="${SIPWISE_EXTRA_CNF}" \
            -e 'delete from kamailio.location;'/;
    }
}

clean_kamailio($cf);
clean_locations();
