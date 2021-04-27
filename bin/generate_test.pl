#!/usr/bin/perl
#
# Copyright: 2016-2021 Sipwise Development Team <support@sipwise.com>
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
use Template;
use YAML::XS qw(LoadFile);

sub usage
{
  my $output = "usage: generate_test.pl [-h] test.tt2 scenario_ids.yml\n";
  $output .= "Options:\n";
  $output .= "\t-h: this help\n";
  $output .= "\t-p: PRO scenario\n";
  $output .= "\t-c: k-c-t config.yml\n";
  return $output
}

my $base_dir = '/usr/share/kamailio-config-tests';
my $help = 0;
my $PRO = 0;
my $kct_conf_yaml = undef;

GetOptions (
  "h|help" => \$help,
  "p|pro" =>\$PRO,
  "c|config=s" =>\$kct_conf_yaml,
) or die("Error in command line arguments\n".usage());

if (exists $ENV{'BASE_DIR'})
{
  $base_dir = $ENV{'BASE_DIR'};
}
$kct_conf_yaml = "${base_dir}/config.yml" unless(defined($kct_conf_yaml));

die(usage()) unless (!$help);
die("Wrong number of arguments\n".usage()) unless ($#ARGV == 1);

my $ids = LoadFile($ARGV[1]);
if($PRO) {
  $ids->{PRO} = 1;
} else {
  $ids->{CE} = 1;
}
${ids}->{config} = LoadFile($kct_conf_yaml);

my $template = Template->new({ABSOLUTE => 1});
$template->process(abs_path($ARGV[0]), $ids)
  or die $template->error();
