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

use English;
use YAML;
use Getopt::Long;
use List::MoreUtils qw{ none };
use Config::Tiny;
use Sipwise::API qw(all);
use Data::Dumper;

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

sub usage {
  return "Usage:\n$PROGRAM_NAME prefs.yml\n".
		"Options:\n".
		"  -d debug\n".
		"  -h this help\n";
}
my $help = 0;
GetOptions ("h|help" => \$help, "d|debug" => \$opts->{verbose})
	or die("Error in command line arguments\n".usage());

die(usage()) unless (!$help);
die("Wrong number of arguments\n".usage()) unless ($#ARGV == 0);

sub get_peers
{
	my $peers;
	my $result = call_prov( $vprov, 'get_peer_groups');
	foreach (@{$result})
	{
		my $res = call_prov( $vprov, 'get_peer_group_details', {id=>$_->{id}});
		foreach (@{$res->{peers}})
		{
			$peers->{$_->{name}} = $_->{id};
		}
	}
	return $peers;
}

sub get_rewrites
{
	my $rule_set;
	my $result = call_prov( $vprov, 'get_rewrite_rule_sets');
	foreach (@{$result})
	{
		$rule_set->{$_->{name}} = $_->{id};
	}
	return $rule_set;
}

sub set_subscriber_preferences
{
	my $subscriber = shift;
	my $domain = shift;
	my prefs = shift;
	print Dumper $prefs;
	return;
}

sub set_domain_preferences
{
	my $domain = shift;
	my $prefs = shift;
	print Dumper $prefs;
	return;
}

sub main {
	my $prefs = shift;
	my $peers;
	my $rule_set;

	for my $key (keys $prefs)
	{
		if (exists($prefs->{$key}->{rewrite_rule_set}))
		{
			if(!$rule_set) { $rule_set = get_rewrites($vprov); }
			if (exists($rule_set->{$prefs->{$key}->{rewrite_rule_set}}))
			{
				$prefs->{$key}->{rewrite_rule_set} = $rule_set->{$prefs->{$key}->{rewrite_rule_set}};
			}
			else
			{
				die("No rewrite_rule_set:$prefs->{$key}->{rewrite_rule_set} found");
			}
		}
		if ( $key =~ /@/ )
		{
			my @fields = split /@/, $key;
			if (!$fields[0])
			{
				set_domain_preferences($fields[1], $prefs->{$key});
			}
			else
			{
				set_subscriber_preferences($fields[0], $fields[1], $prefs->{$key});
			}
		}
		else
		{
			if (!$peers) { $peers = get_peers($vprov); }
			my $pref = { id => $peers->{$key}, preferences => $prefs->{$key} };
			call_prov( $vprov, 'set_peer_preferences',  $pref);
		}
	}

	exit;
}

my $cf = YAML::LoadFile($ARGV[0]);

main($cf);
