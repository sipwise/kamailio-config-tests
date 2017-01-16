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
package Sipwise::API 0.001;

use strict;
use warnings;

use English;
use Hash::Merge qw( merge );
use JSON qw();
use LWP::UserAgent;
use IO::Socket::SSL;
use URI;
use Data::Dumper;
use File::Slurp;

my $opts_default = {
	host => '127.0.0.1',
	port => 1443,
	auth_user => 'administrator',
	auth_pwd => 'administrator',
	verbose => 0,
	sslverify => 'no',
	admin => 0
};

sub _get_id {
	my ($baseurl, $location) = @_;
	my $id;

	($id) = ($location =~ m/\Q$baseurl\E(\d+)/);
	return $id;
}

sub new {
	my ($class, $opts) = @_;
	my $self = {};

	$self->{opts} = merge($opts, $opts_default);
	bless $self, $class;

	return $self;
}

sub opts {
	my $self = shift;
	if (@_) {
		$self->{opts} = shift;
	}
	return $self->{opts};
}

sub do_request {
	my $self = shift;
	my $ua = shift;
	my $url = shift;
	my $data = shift;
	my $req_type = shift || 'POST';
	my $ct = 'application/json';

	if($req_type =~ 'PATCH') {
		$ct = 'application/json-patch+json';
	}

	my $req = HTTP::Request->new($req_type, $url);
	$req->header('Content-Type' => $ct);
	$req->header('Prefer' => 'return=representation');
	$req->content(JSON::to_json($data));
	my $res = $ua->request($req);
	if(!$res->is_success) {
		print "$url\n";
		print Dumper $data unless $self->{opts}->{verbose};
	}
	return $res;
}

sub do_query {
	my $self = shift;
	my $ua = shift;
	my $url = shift;
	my $data = shift;
	my $req_type = shift || 'GET';
	my $URL = URI->new($url);
	$URL->query_form($data);
	my $req = HTTP::Request->new($req_type, $URL);

	my $res = $ua->request($req);
	if(!$res->is_success) {
		print "$url\n";
		print Dumper $data unless $self->{opts}->{verbose};
	}
	return $res;
}

sub create_ua {
	my $self = shift;
	my $ua = LWP::UserAgent->new();

	if($self->{opts}->{sslverify} eq 'no') {
		$ua->ssl_opts(
			verify_hostname => 0,
			SSL_verify_mode => IO::Socket::SSL::SSL_VERIFY_NONE,
		);
	}
	$ua->credentials(
		$self->{opts}->{host}.':'.$self->{opts}->{port},
		'api_admin_http',
		$self->{opts}->{auth_user},
		$self->{opts}->{auth_pwd}
	);
	# debug!!
	if($self->{opts}->{verbose}) {
		$ua->show_progress(1);
		$ua->add_handler("request_send",  sub { shift->dump; return });
		$ua->add_handler("response_done", sub { shift->dump; return });
	}
	return $ua;
}

sub _create {
	my ($self, $data, $urldata) = @_;
	my $urlbase = 'https://'.$self->{opts}->{host}.':'.$self->{opts}->{port};

	my $ua = $self->create_ua();
	my $res = $self->do_request($ua, $urlbase.$urldata, $data);
	if($res->is_success) {
		if($self->{opts}->{verbose}) {
			print $res->status_line . ' ' . $res->header('Location') . "\n";
		}
		return _get_id($urldata, $res->header('Location'));
	} else {
		die $res->as_string;
	}
	return;
}

sub _delete {
	my ($self, $urldata) = @_;
	my $urlbase = 'https://'.$self->{opts}->{host}.':'.$self->{opts}->{port};

	my $ua = $self->create_ua();
	my $res = $self->do_query($ua, $urlbase.$urldata, undef, 'DELETE');
	return $res->is_success;
}

sub _get_content {
	my ($self, $data, $urldata) = @_;
	my $urlbase = 'https://'.$self->{opts}->{host}.':'.$self->{opts}->{port};
	my $ua = $self->create_ua();

	my $res = $self->do_query($ua, $urlbase.$urldata, $data);
	if($res->is_success) {
		return JSON::from_json( $res->decoded_content );
	}
	else {
		die $res->as_string;
	}
	return;
}

sub _set_content {
	my ($self, $data, $urldata) = @_;
	my $urlbase = 'https://'.$self->{opts}->{host}.':'.$self->{opts}->{port};
	my $ua = $self->create_ua();

	my $res = $self->do_request($ua, $urlbase.$urldata, $data, 'PUT');
	if($res->is_success) {
		return JSON::from_json( $res->decoded_content );
	}
	else {
		die $res->as_string;
	}
	return;
}

sub _exists {
	my ($self, $data, $urldata, $collection_id) = @_;
	my $collection = $self->_get_content($data, $urldata);

	if (defined $collection && $collection->{total_count} == 1) {
		my $links = $collection->{_embedded}->{$collection_id}->{_links};
		my $href = $links->{self}->{href};
		return _get_id($urldata, $href);
	}
	return;
}

sub check_contact_exists {
	my ($self, $data, $type) = @_;
	my $urldata = "/api/${type}contacts/";
	my $collection_id = "ngcp:${type}contacts";

	return $self->_exists($data, $urldata, $collection_id);
}

sub create_contact {
	my ($self, $data, $type) = @_;
	my $urldata = "/api/${type}contacts/";

	return $self->_create($data, $urldata);
}

sub check_contract_exists {
	my ($self, $data) = @_;
	my $urldata = '/api/contracts/';
	my $collection_id = 'ngcp:contracts';

	return $self->_exists($data, $urldata, $collection_id);
}

sub create_contract {
	my ($self, $data) = @_;
	my $urldata = '/api/contracts/';

	return $self->_create($data, $urldata);
}

sub check_reseller_exists {
	my ($self, $data) = @_;
	my $urldata = '/api/resellers/';
	my $collection_id = 'ngcp:resellers';

	return $self->_exists($data, $urldata, $collection_id);
}

sub create_reseller {
	my ($self, $data) = @_;
	my $urldata = '/api/resellers/';

	return $self->_create($data, $urldata);
}

sub check_domain_exists {
	my ($self, $data) = @_;
	my $urldata = "/api/domains/";
	my $collection_id = 'ngcp:domains';

	return $self->_exists($data, $urldata, $collection_id);
}

sub get_domain_preferences {
	my ($self, $id) = @_;
	my $urldata = "/api/domainpreferences/${id}";
	my $collection_id = 'ngcp:domainpreferences';

	return $self->_get_content(undef, $urldata);
}

sub set_domain_preferences {
	my ($self, $id, $data) = @_;
	my $urldata = "/api/domainpreferences/${id}";
	my $collection_id = 'ngcp:domainpreferences';

	return $self->_set_content($data, $urldata);
}

sub create_domain {
	my ($self, $data) = @_;
	my $urldata = '/api/domains/';

	return $self->_create($data, $urldata);
}

sub check_customer_exists {
	my ($self, $data) = @_;
	my $urldata = '/api/customers/';
	my $collection_id = 'ngcp:customers';

	return $self->_exists($data, $urldata, $collection_id);
}

sub create_customer {
	my ($self, $data) = @_;
	my $urldata = '/api/customers/';

	return $self->_create($data, $urldata);
}

sub check_subscriber_exists {
	my ($self, $data) = @_;
	my $urldata = '/api/subscribers/';
	my $collection_id = 'ngcp:subscribers';

	return $self->_exists($data, $urldata, $collection_id);
}

sub get_subscriber {
	my ($self, $id) = @_;
	my $urldata = "/api/subscribers/${id}";

	return $self->_get_content(undef, $urldata);
}

sub get_subscriber_preferences {
	my ($self, $id) = @_;
	my $urldata = "/api/subscriberpreferences/${id}";
	my $collection_id = 'ngcp:subscriberpreferences';

	return $self->_get_content(undef, $urldata);
}

sub set_subscriber_preferences {
	my ($self, $id, $data) = @_;
	my $urldata = "/api/subscriberpreferences/${id}";
	my $collection_id = 'ngcp:subscriberpreferences';

	return $self->_set_content($data, $urldata);
}

sub set_subscriber_speeddial {
	my ($self, $id, $data) = @_;
	my $urldata = "/api/speeddials/${id}";
	my $collection_id = 'ngcp:speeddials';

	return $self->_set_content($data, $urldata);
}

sub get_subscriber_speeddial {
	my ($self, $id) = @_;
	my $urldata = "/api/speeddials/${id}";
	my $collection_id = 'ngcp:speeddials';

	return $self->_get_content(undef, $urldata);
}

sub set_subscriber_callforward {
	my ($self, $id, $data) = @_;
	my $urldata = "/api/callforwards/${id}";
	my $collection_id = 'ngcp:callforwards';

	return $self->_set_content($data, $urldata);
}

sub get_subscriber_callforward {
	my ($self, $id) = @_;
	my $urldata = "/api/callforwards/${id}";
	my $collection_id = 'ngcp:callforwards';

	return $self->_get_content(undef, $urldata);
}

sub set_subscriber_voicemailsettings {
	my ($self, $id, $data) = @_;
	my $urldata = "/api/voicemailsettings/${id}";
	my $collection_id = 'ngcp:voicemailsettings';

	return $self->_set_content($data, $urldata);
}

sub get_subscriber_voicemailsettings {
	my ($self, $id) = @_;
	my $urldata = "/api/voicemailsettings/${id}";
	my $collection_id = 'ngcp:voicemailsettings';

	return $self->_get_content(undef, $urldata);
}

sub create_subscriber {
	my ($self, $data) = @_;
	my $urldata = '/api/subscribers/';

	return $self->_create($data, $urldata);
}

sub check_rewriterule_exists {
	my ($self, $data) = @_;
	my $urldata = '/api/rewriterules/';
	my $collection_id = 'ngcp:rewriterules';

	return $self->_exists($data, $urldata, $collection_id);
}

sub create_rewriterule {
	my ($self, $data) = @_;
	my $urldata = '/api/rewriterules/';

	return $self->_create($data, $urldata);
}

sub check_rewriteruleset_exists {
	my ($self, $data) = @_;
	my $urldata = '/api/rewriterulesets/';
	my $collection_id = 'ngcp:rewriterulesets';

	return $self->_exists($data, $urldata, $collection_id);
}

sub create_rewriteruleset {
	my ($self, $data) = @_;
	my $urldata = '/api/rewriterulesets/';

	return $self->_create($data, $urldata);
}

sub delete_rewriteruleset {
	my ($self, $id) = @_;
	my $urldata = "/api/rewriterulesets/${id}";

	return $self->_delete($urldata);
}

sub check_peeringgroup_exists {
	my ($self, $data) = @_;
	my $urldata = '/api/peeringgroups/';
	my $collection_id = 'ngcp:peeringgroups';

	return $self->_exists($data, $urldata, $collection_id);
}

sub create_peeringgroup {
	my ($self, $data) = @_;
	my $urldata = '/api/peeringgroups/';

	return $self->_create($data, $urldata);
}

sub delete_peeringgroup {
	my ($self, $id) = @_;
	my $urldata = "/api/peeringgroups/${id}";

	return $self->_delete($urldata);
}

sub check_peeringserver_exists {
	my ($self, $data) = @_;
	my $urldata = '/api/peeringservers/';
	my $collection_id = 'ngcp:peeringservers';

	return $self->_exists($data, $urldata, $collection_id);
}

sub get_peeringserver_preferences {
	my ($self, $id) = @_;
	my $urldata = "/api/peeringserverpreferences/${id}";
	my $collection_id = 'ngcp:peeringserverpreferences';

	return $self->_get_content(undef, $urldata);
}

sub set_peeringserver_preferences {
	my ($self, $id, $data) = @_;
	my $urldata = "/api/peeringserverpreferences/${id}";
	my $collection_id = 'ngcp:peeringserverpreferences';

	return $self->_set_content($data, $urldata);
}

sub create_peeringserver {
	my ($self, $data) = @_;
	my $urldata = '/api/peeringservers/';

	return $self->_create($data, $urldata);
}

sub set_peeringserver {
	my ($self, $id, $data) = @_;
	my $urldata = "/api/peeringservers/${id}";
	my $collection_id = 'ngcp:peeringservers';

	return $self->_set_content($data, $urldata);
}

sub get_peeringserver {
	my ($self, $id) = @_;
	my $urldata = "/api/peeringservers/${id}";
	my $collection_id = 'ngcp:peeringservers';

	return $self->_get_content(undef, $urldata);
}

sub delete_peeringserver {
	my ($self, $id) = @_;
	my $urldata = "/api/peeringservers/${id}";

	return $self->_delete($urldata);
}

sub check_peeringrule_exists {
	my ($self, $data) = @_;
	my $urldata = '/api/peeringrules/';
	my $collection_id = 'ngcp:peeringrules';

	return $self->_exists($data, $urldata, $collection_id);
}

sub create_peeringrule {
	my ($self, $data) = @_;
	my $urldata = '/api/peeringrules/';

	return $self->_create($data, $urldata);
}

sub delete_peeringrule {
	my ($self, $id) = @_;
	my $urldata = "/api/peeringrules/${id}";

	return $self->_delete($urldata);
}

sub check_peeringinboundrule_exists {
	my ($self, $data) = @_;
	my $urldata = '/api/peeringinboundrules/';
	my $collection_id = 'ngcp:peeringinboundrules';

	return $self->_exists($data, $urldata, $collection_id);
}

sub create_peeringinboundrule {
	my ($self, $data) = @_;
	my $urldata = '/api/peeringinboundrules/';

	return $self->_create($data, $urldata);
}

sub delete_peeringinboundrule {
	my ($self, $id) = @_;
	my $urldata = "/api/peeringinboundrules/${id}";

	return $self->_delete($urldata);
}

sub check_ncoslevel_exists {
	my ($self, $data) = @_;
	my $urldata = "/api/ncoslevels/";
	my $collection_id = 'ngcp:ncoslevels';

	return $self->_exists($data, $urldata, $collection_id);
}

sub create_ncoslevel {
	my ($self, $data) = @_;
	my $urldata = '/api/ncoslevels/';

	return $self->_create($data, $urldata);
}

sub delete_ncoslevel {
	my ($self, $id) = @_;
	my $urldata = "/api/ncoslevels/${id}";

	return $self->_delete($urldata);
}

sub check_ncospattern_exists {
	my ($self, $data) = @_;
	my $urldata = "/api/ncospatterns/";
	my $collection_id = 'ngcp:ncospatterns';

	return $self->_exists($data, $urldata, $collection_id);
}

sub create_ncospattern {
	my ($self, $data) = @_;
	my $urldata = '/api/ncospatterns/';

	return $self->_create($data, $urldata);
}

sub delete_ncospattern {
	my ($self, $id) = @_;
	my $urldata = "/api/ncospatterns/${id}";

	return $self->_delete($urldata);
}

sub check_lnpcarrier_exists {
	my ($self, $data) = @_;
	my $urldata = "/api/lnpcarriers/";
	my $collection_id = 'ngcp:lnpcarriers';

	return $self->_exists($data, $urldata, $collection_id);
}

sub create_lnpcarrier {
	my ($self, $data) = @_;
	my $urldata = '/api/lnpcarriers/';

	return $self->_create($data, $urldata);
}

sub delete_lnpcarrier {
	my ($self, $id) = @_;
	my $urldata = "/api/lnpcarriers/${id}";

	return $self->_delete($urldata);
}

sub check_lnpnumber_exists {
	my ($self, $data) = @_;
	my $urldata = "/api/lnpnumbers/";
	my $collection_id = 'ngcp:lnpnumbers';

	return $self->_exists($data, $urldata, $collection_id);
}

sub create_lnpnumber {
	my ($self, $data) = @_;
	my $urldata = '/api/lnpnumbers/';

	return $self->_create($data, $urldata);
}

sub delete_lnpnumber {
	my ($self, $id) = @_;
	my $urldata = "/api/lnpnumbers/${id}";

	return $self->_delete($urldata);
}

sub check_ncoslnpcarrier_exists {
	my ($self, $data) = @_;
	my $urldata = "/api/ncoslnpcarriers/";
	my $collection_id = 'ngcp:ncoslnpcarriers';

	return $self->_exists($data, $urldata, $collection_id);
}

sub create_ncoslnpcarrier {
	my ($self, $data) = @_;
	my $urldata = '/api/ncoslnpcarriers/';

	return $self->_create($data, $urldata);
}

sub delete_ncoslnpcarrier {
	my ($self, $id) = @_;
	my $urldata = "/api/ncoslnpcarriers/${id}";

	return $self->_delete($urldata);
}

sub check_soundset_exists {
	my ($self, $data) = @_;
	my $urldata = "/api/soundsets/";
	my $collection_id = 'ngcp:soundsets';

	return $self->_exists($data, $urldata, $collection_id);
}

sub create_soundset {
	my ($self, $data) = @_;
	my $urldata = '/api/soundsets/';

	return $self->_create($data, $urldata);
}

sub delete_soundset {
	my ($self, $id) = @_;
	my $urldata = "/api/soundsets/${id}";

	return $self->_delete($urldata);
}

sub _do_binary_request {
	my $self = shift;
	my $ua = shift;
	my $url = shift;
	my $filename = shift;
	my $content;

	my $req = HTTP::Request->new('POST', $url);
	$req->header('Content-Type' => 'audio/x-wav');
	$req->header('Prefer' => 'return=representation');
	$req->content(read_file($filename));
	my $res = $ua->request($req);
	if(!$res->is_success) {
		print "$url\n";
	}
	return $res;
}

sub upload_soundfile {
	my ($self, $data, $filepath) = @_;
	my $urldata = "/api/soundfiles/?".
		"filename=$data->{filename}&handle=$data->{handle}".
		"&set_id=$data->{set_id}&loopplay=$data->{loopplay}";
	my $urlbase = 'https://'.$self->{opts}->{host}.':'.$self->{opts}->{port};

	my $ua = $self->create_ua();
	my $res = $self->_do_binary_request($ua, $urlbase.$urldata, $filepath);
	if(! $res->is_success) {
		die $res->as_string;
	}
	return;
}

1;
