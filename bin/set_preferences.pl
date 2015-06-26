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
use JSON qw();
use Getopt::Long;
use List::MoreUtils qw{ none };
use Config::Tiny;
use Sipwise::API qw(all);
use Hash::Merge qw( merge );
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
  return "Usage:\n$PROGRAM_NAME prefs.json\n".
		"Options:\n".
		"  -d debug\n".
		"  -h this help\n";
}
my $help = 0;
GetOptions ("h|help" => \$help, "d|debug" => \$opts->{verbose})
	or die("Error in command line arguments\n".usage());

die(usage()) unless (!$help);
die("Wrong number of arguments\n".usage()) unless ($#ARGV == 0);

sub set_subscriber_preferences
{
	my $subscriber = shift;
	my $domain = shift;
	my $prefs = shift;
	my $subs_id = $api->check_subscriber_exists({
							'domain'=>$domain,
							'username'=>$subscriber});
	if(defined $subs_id) {
		my $subs_prefs = $api->get_subscriber_preferences($subs_id);
		delete $subs_prefs->{_links};
		my $subs_prefs_id = $subs_prefs->{id};
		my $res = $api->set_subscriber_preferences($subs_prefs_id,
					merge($prefs, $subs_prefs));
		if($opts->{verbose}) {
			print Dumper $res;
		}
		if(defined $res) {
			print "prefs created for ${subscriber}\@${domain}\n";
		}
	}
	else {
		die("No subscriber ${subscriber}\@${domain} found");
	}
	return;
}

sub set_domain_preferences
{
	my $domain = shift;
	my $prefs = shift;
	my $domain_id = $api->check_domain_exists({'domain' => $domain});

	if(defined $domain_id) {
		my $dom_prefs = $api->get_domain_preferences($domain_id);
		my $links = delete $dom_prefs->{_links};
		my $dom_prefs_id = $dom_prefs->{id};
		my $res = $api->set_domain_preferences($dom_prefs_id,
					merge($prefs, $dom_prefs));
		if($opts->{verbose}) {
			print Dumper $res;
		}
		if(defined $res) {
			print "prefs created for ${domain}\n";
		}
	}
	else {
		die("No domain ${domain} found");
	}
	return;
}

sub set_peer_preferences
{
	my $id = shift;
	my $prefs = shift;
	my $peer_id = $api->check_peer_exists($id);

	if(defined $peer_id) {
		my $peer_prefs = $api->get_peer_preferences($peer_id);
		delete $peer_prefs->{_links};
		my $peer_prefs_id = $peer_prefs->{id};
		return $api->set_peer_preferences($peer_prefs_id,
					merge($prefs, $peer_prefs));
	}
	else {
		die("No peer ${id} found");
	}
	return;
}

sub main {
	my $prefs = shift;
	my $peers;
	my $rule_set;

	for my $key (keys %{$prefs})
	{
		if (exists($prefs->{$key}->{rewrite_rule_set}))
		{
			my $rule_set_id = $api->check_rewriterule_exists(
								$prefs->{$key}->{rewrite_rule_set});
			if (defined $rule_set_id)
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
			#set_peer_preferences($key, $prefs->{$key});
			die "API peer preferences *Not* implemented";
		}
	}

	exit;
}

sub get_json {
	my $filename = shift;
	my $json_text = do {
		open(my $json_fh, "<:encoding(UTF-8)", $filename)
			or die("Can't open \$filename\": $ERRNO\n");
		undef $RS; # enable "slurp" mode
		<$json_fh>
	};

	my $json = JSON->new;
	return $json->decode($json_text);
}

my $cf = get_json($ARGV[0]);

main($cf);
