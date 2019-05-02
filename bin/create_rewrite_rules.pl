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
use Getopt::Long;
use Cwd 'abs_path';
use Config::Tiny;
use Sipwise::API qw(all);
use YAML::XS;

my $config =  Config::Tiny->read('/etc/default/ngcp-api');
my $opts;
if ($config) {
    $opts = {};
    $opts->{host} = $config->{_}->{NGCP_API_IP};
    $opts->{port} = $config->{_}->{NGCP_API_PORT};
    $opts->{sslverify} = $config->{_}->{NGCP_API_SSLVERIFY};
}
my $api = Sipwise::API->new($opts);
$opts = $api->opts;
my $del;

sub usage {
  return "Usage:\n$PROGRAM_NAME rewrite.yml\n".
        "Options:\n".
        "  -delete\n".
        "  -d debug\n".
        "  -h this help\n";
}
my $help = 0;
GetOptions ("h|help" => \$help,
    "d|debug" => \$opts->{verbose},
    "delete" => \$del)
    or die("Error in command line arguments\n".usage());

die(usage()) unless (!$help);
die("Error: Wrong number of arguments\n".usage()) unless ($#ARGV == 0);

sub do_delete
{
    my ($data) = @_;
    for my $rule_set_name (keys %{$data})
    {
        my $param = { reseller_id => 1, name => $rule_set_name };
        my $rws_id = $api->check_rewriteruleset_exists($param);
        if(defined $rws_id) {
            sleep(5);
            if($api->delete_rewriteruleset($rws_id)) {
                print "rewriteruleset [$rule_set_name] deleted [$rws_id]\n";
            }
            else {
                die "Error: rewriteruleset [$rule_set_name] can't be removed [$rws_id]\n";
            }
        } else {
            print "rewriteruleset [$rule_set_name] not there\n";
        }
    }
    exit;
}

sub do_create
{
    my ($data) = @_;
    for my $rule_set_name (keys %{$data})
    {
        my $param = { reseller_id => 1, name => $rule_set_name };
        my $rws_id = $api->check_rewriteruleset_exists($param);
        if(defined $rws_id) {
          print "rewriteruleset [$rule_set_name] already there [$rws_id]\n";
        } else {
          $rws_id = $api->create_rewriteruleset($param);
          print "rewriteruleset [$rule_set_name] created [$rws_id]\n";
        }
        foreach my $param (@{$data->{$rule_set_name}}) {
            $param->{set_id} = $rws_id;
            sleep(5);
            my $rw_id = $api->create_rewriterule($param);
            if(defined $rw_id) {
                print "rewriterule [".
                    $param->{field}."/".$param->{direction}.
                    "] created [$rw_id]\n";
            }
            else {
                die "Error: Can't create rewriterule"
            }
        }
    }
    exit;
}

sub main {
    my $r = shift;

    if ($del)
    {
        print "delete rewriterules\n" unless $opts->{debug};
        return do_delete($r);
    }
    else
    {
        print "create rewriterules\n" unless $opts->{debug};
        return do_create($r);
    }
}

main(YAML::XS::LoadFile(abs_path($ARGV[0])));
