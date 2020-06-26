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
use IO::File;
use YAML::XS;
use Capture::Tiny qw(capture);

sub usage
{
  my $output = "usage: $PROGRAM_NAME [-h] [--clean] scenario.yml\n";
  $output .= "Options:\n";
  $output .= "\t-h: this help\n";
  $output .= "\t-c|--clean: reset to level 1 defined modules\n";
  return $output
}

my $help = 0;
my $clean = undef;
GetOptions ("h|help" => \$help,
    "c|clean" => \$clean
) or die("Error in command line arguments\n".usage());

die(usage()) unless (!$help);
die("Wrong number of arguments\n".usage()) unless ($#ARGV == 0);

my $filename = abs_path($ARGV[0]);
my $cf = YAML::XS::LoadFile($filename);

sub run_cmd {
    my $cmd = shift;
    my $rc = 0;
    my ($out, $err) = capture {
        system($cmd);
        $rc = $CHILD_ERROR >> 8;
    };
    return ($rc, $out, $err);
}

sub kam_set_mod_level {
    my ($kam, $module, $lvl) = @_;
    my $cmd = "ngcp-kamcmd ${kam} dbg.set_mod_level ${module} ${lvl}";
    my ($rc, undef, $err) = run_cmd($cmd);
    if ($err) {
        $err = join(", ", split(/\r*\n/, $err));
        die "Error setting debugger level on kamailio: $err (errno: $rc)";
    }
    print("")
}

sub kamailio_debugger {
    my $data = shift;
    if(! defined($data->{kamailio})) {
        return;
    }
    foreach (keys %{$data->{kamailio}}) {
        if(defined($data->{kamailio}->{$_}->{debugger})) {
            foreach my $module (@{$data->{kamailio}->{$_}->{debugger}}) {
                my $lvl = 1;
                $lvl = $module->{level} unless($clean);
                kam_set_mod_level($_, $module->{name}, $lvl);
            }
        }
    }
}

kamailio_debugger($cf);
