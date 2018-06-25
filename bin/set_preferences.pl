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
use List::Util qw(none);
use Config::Tiny;
use Sipwise::API qw(all);
use Storable 'dclone';
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
die("Error: wrong number of arguments\n".usage()) unless ($#ARGV == 0);

sub resolve_ids {
	my $prefs = shift;
	return $prefs;
	my $key;
	if(defined $prefs->{sound_set}) {
		$key = $prefs->{sound_set};
		my $id = $api->check_soundset_exists({name => $key});
		if($id) {
			$prefs->{sound_set} = $id;
			print "soundset[$key] => $prefs->{sound_set}\n";
		} else {
			die("soundset[$key] not found\n");
		}
	}
	return $prefs;
}

sub merge
{
	my $a = shift;
	my $b = shift;
	my $result = dclone($a);

	for my $key (keys %{$b}) {
		$result->{$key} = $b->{$key} unless(exists $a->{$key});
	}
	return $result;
}

sub set_subscriber_preferences
{
	my $subscriber = shift;
	my $domain = shift;
	my $prefs = shift;
	my $subs_id = $api->check_subscriber_exists({
							domain => $domain,
							username => $subscriber});
	if($subs_id) {
		my $subs_prefs = $api->get_subscriber_preferences($subs_id);
		delete $subs_prefs->{_links};
		my $subs_prefs_id = $subs_prefs->{id};
		my $merged_prefs = merge($prefs, $subs_prefs);
		my $res = $api->set_subscriber_preferences($subs_prefs_id,
					$merged_prefs);
		if($opts->{verbose}) {
			print Dumper $prefs;
			print Dumper $subs_prefs;
			print Dumper $merged_prefs;
			print Dumper $res;
		}
		if($res) {
			print "prefs created for ${subscriber}\@${domain} [$subs_id]\n";
		} else {
			die("Error: pref failed for ${subscriber}\@${domain} [$subs_id]");
		}
	}
	else {
		die("Error: No subscriber ${subscriber}\@${domain} found");
	}
	return;
}

sub set_domain_preferences
{
	my $domain = shift;
	my $prefs = shift;
	my $domain_id = $api->check_domain_exists({ domain => $domain });

	if($domain_id) {
		my $dom_prefs = $api->get_domain_preferences($domain_id);
		delete $dom_prefs->{_links};
		my $dom_prefs_id = $dom_prefs->{id};
		my $merged_prefs = merge($prefs, $dom_prefs);
		my $res = $api->set_domain_preferences($dom_prefs_id,
					$merged_prefs);
		if($opts->{verbose}) {
			print Dumper $prefs;
			print Dumper $dom_prefs;
			print Dumper $merged_prefs;
			print Dumper $res;
		}
		if($res) {
			print "prefs created for ${domain} [$domain_id]\n";
		} else {
			die("Error: pref failed for ${domain}");
		}
	}
	else {
		die("Error: No domain ${domain} found");
	}
	return;
}

sub set_peer_preferences
{
	my $name = shift;
	my $prefs = shift;
	my $peer_id = $api->check_peeringserver_exists({ name => $name });

	if($peer_id) {
		my $peer_prefs = $api->get_peeringserver_preferences($peer_id);
		delete $peer_prefs->{_links};
		my $peer_prefs_id = $peer_prefs->{id};
		my $merged_prefs = merge($prefs, $peer_prefs);
		my $res = $api->set_peeringserver_preferences($peer_prefs_id,
					$merged_prefs);
		if($opts->{verbose}) {
			print Dumper($prefs);
			print Dumper($peer_prefs);
			print Dumper($merged_prefs);
			print Dumper($res);
		}
		if($res) {
			print "prefs created for ${name} [$peer_id]\n";
		} else {
			die("Error: pref failed for ${name}");
		}
	}
	else {
		die("Error: No peer ${name} found");
	}
	return;
}

sub main {
	my $prefs = shift;

	for my $key (keys %{$prefs})
	{
		my $prefs_id = resolve_ids($prefs->{$key});
		print "processing $key\n";
		if ( $key =~ /@/ ) {
			my @fields = split /@/, $key;
			if (!$fields[0]) {
				set_domain_preferences($fields[1], $prefs_id);
			} else {
				set_subscriber_preferences($fields[0], $fields[1], $prefs_id);
			}
		} else {
			set_peer_preferences($key, $prefs_id);
		}
	}
	exit;
}

sub get_json {
	my $filename = shift;
	my $json_text = do {
		open(my $json_fh, "<:encoding(UTF-8)", $filename)
			or die("Error: Can't open \$filename\": $ERRNO\n");
		undef $RS; # enable "slurp" mode
		<$json_fh>
	};

	my $json = JSON->new;
	return $json->decode($json_text);
}

my $cf = get_json($ARGV[0]);
main($cf);
