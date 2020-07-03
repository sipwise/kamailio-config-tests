#!/usr/bin/perl
#
# Copyright: 2016-2020 Sipwise Development Team <support@sipwise.com>
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
  $output .= "\t-c: ngcp config yml file\n";
  $output .= "\t-p: PRO scenario\n";
  return $output
}

my $help = 0;
my $PRO = 0;
my $ngcp_cfg;
GetOptions (
	"h|help" => \$help,
	"p|pro" =>\$PRO,
	"c|config=s" =>\$ngcp_cfg,
) or die("Error in command line arguments\n".usage());

die(usage()) unless (!$help);
die("Wrong number of arguments\n".usage()) unless ($#ARGV == 1);

my $ids = LoadFile($ARGV[1]);
if($PRO) {
  $ids->{PRO} = 1;
} else {
  $ids->{CE} = 1;
}
my $config = undef;
if ($ngcp_cfg) {
	$ids->{cfg} = LoadFile($ngcp_cfg);
}

my $template = Template->new({ABSOLUTE => 1});
$template->process(abs_path($ARGV[0]), $ids)
  or die $template->error();
