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
	my $baseurl = shift;
	my $location = shift;
	my $id;

	($id) = ($location =~ m/\Q$baseurl\E(\d+)/);
	return $id;
}

sub new {
	my $class = shift;
	my $opts = shift;
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
	my $self = shift;
	my $data = shift;
	my $urldata = shift;
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
	my $self = shift;
	my $urldata = shift;
	my $urlbase = 'https://'.$self->{opts}->{host}.':'.$self->{opts}->{port};

	my $ua = $self->create_ua();
	my $res = $self->do_query($ua, $urlbase.$urldata, undef, 'DELETE');
	return $res->is_success;
}

sub _get_content {
	my $self = shift;
	my $data = shift;
	my $urldata = shift;
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
	my $self = shift;
	my $data = shift;
	my $urldata = shift;
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
	my $self = shift;
	my $data = shift;
	my $urldata = shift;
	my $collection_id = shift;
	my $collection = $self->_get_content($data, $urldata);

	if (defined $collection && $collection->{total_count} == 1) {
		my $links = $collection->{_embedded}->{$collection_id}->{_links};
		my $href = $links->{self}->{href};
		return _get_id($urldata, $href);
	}
	return;
}

sub check_contact_exists {
	my $self = shift;
	my $data = shift;
	my $type = shift;
	my $urldata = "/api/${type}contacts/";
	my $collection_id = "ngcp:${type}contacts";

	return $self->_exists($data, $urldata, $collection_id);
}

sub create_contact {
	my $self = shift;
	my $data = shift;
	my $type = shift;
	my $urldata = "/api/${type}contacts/";

	return $self->_create($data, $urldata);
}

sub check_contract_exists {
	my $self = shift;
	my $data = shift;
	my $urldata = '/api/contracts/';
	my $collection_id = 'ngcp:contracts';

	return $self->_exists($data, $urldata, $collection_id);
}

sub create_contract {
	my $self = shift;
	my $data = shift;
	my $urldata = '/api/contracts/';

	return $self->_create($data, $urldata);
}

sub check_reseller_exists {
	my $self = shift;
	my $data = shift;
	my $urldata = '/api/resellers/';
	my $collection_id = 'ngcp:resellers';

	return $self->_exists($data, $urldata, $collection_id);
}

sub create_reseller {
	my $self = shift;
	my $data = shift;
	my $urldata = '/api/resellers/';

	return $self->_create($data, $urldata);
}

sub check_domain_exists {
	my $self = shift;
	my $data = shift;
	my $urldata = "/api/domains/";
	my $collection_id = 'ngcp:domains';

	return $self->_exists($data, $urldata, $collection_id);
}

sub get_domain_preferences {
	my $self = shift;
	my $id = shift;
	my $urldata = "/api/domains/${id}";
	my $collection_id = 'ngcp:domainpreferences';

	return $self->_get_content(undef, $urldata);
}

sub set_domain_preferences {
	my $self = shift;
	my $id = shift;
	my $data = shift;
	my $urldata = "/api/domainpreferences/${id}";
	my $collection_id = 'ngcp:domainpreferences';

	return $self->_set_content($data, $urldata);
}

sub create_domain {
	my $self = shift;
	my $data = shift;
	my $urldata = '/api/domains/';

	return $self->_create($data, $urldata);
}

sub check_customer_exists {
	my $self = shift;
	my $data = shift;
	my $urldata = '/api/customers/';
	my $collection_id = 'ngcp:customers';

	return $self->_exists($data, $urldata, $collection_id);
}

sub create_customer {
	my $self = shift;
	my $data = shift;
	my $urldata = '/api/customers/';

	return $self->_create($data, $urldata);
}

sub check_subscriber_exists {
	my $self = shift;
	my $data = shift;
	my $urldata = '/api/subscribers/';
	my $collection_id = 'ngcp:subscribers';

	return $self->_exists($data, $urldata, $collection_id);
}

sub get_subscriber_preferences {
	my $self = shift;
	my $id = shift;
	my $urldata = "/api/subscribers/${id}";
	my $collection_id = 'ngcp:subscriberpreferences';

	return $self->_get_content(undef, $urldata);
}

sub set_subscriber_preferences {
	my $self = shift;
	my $id = shift;
	my $data = shift;
	my $urldata = "/api/subscriberpreferences/${id}";
	my $collection_id = 'ngcp:subscriberpreferences';

	return $self->_set_content($data, $urldata);
}

sub create_subscriber {
	my $self = shift;
	my $data = shift;
	my $urldata = '/api/subscribers/';

	return $self->_create($data, $urldata);
}

sub check_rewriterule_exists {
	my $self = shift;
	my $data = shift;
	my $urldata = '/api/rewriterules/';
	my $collection_id = 'ngcp:rewriterules';

	return $self->_exists($data, $urldata, $collection_id);
}

sub create_rewriterule {
	my $self = shift;
	my $data = shift;
	my $urldata = '/api/rewriterules/';

	return $self->_create($data, $urldata);
}

sub check_rewriteruleset_exists {
	my $self = shift;
	my $data = shift;
	my $urldata = '/api/rewriterulesets/';
	my $collection_id = 'ngcp:rewriterulesets';

	return $self->_exists($data, $urldata, $collection_id);
}

sub create_rewriteruleset {
	my $self = shift;
	my $data = shift;
	my $urldata = '/api/rewriterulesets/';

	return $self->_create($data, $urldata);
}

sub delete_rewriteruleset {
	my $self = shift;
	my $id = shift;
	my $urldata = "/api/rewriterulesets/${id}";

	return $self->_delete($urldata);
}

sub check_peeringgroup_exists {
	my $self = shift;
	my $data = shift;
	my $urldata = '/api/peeringgroups/';
	my $collection_id = 'ngcp:peeringgroups';

	return $self->_exists($data, $urldata, $collection_id);
}

sub create_peeringgroup {
	my $self = shift;
	my $data = shift;
	my $urldata = '/api/peeringgroups/';

	return $self->_create($data, $urldata);
}

sub delete_peeringgroup {
	my $self = shift;
	my $id = shift;
	my $urldata = "/api/peeringgroups/${id}";

	return $self->_delete($urldata);
}

sub check_peeringserver_exists {
	my $self = shift;
	my $data = shift;
	my $urldata = '/api/peeringservers/';
	my $collection_id = 'ngcp:peeringservers';

	return $self->_exists($data, $urldata, $collection_id);
}

sub get_peeringserver_preferences {
	my $self = shift;
	my $id = shift;
	my $urldata = "/api/peeringservers/${id}";
	my $collection_id = 'ngcp:peeringserverpreferences';

	return $self->_get_content(undef, $urldata);
}

sub set_peeringserver_preferences {
	my $self = shift;
	my $id = shift;
	my $data = shift;
	my $urldata = "/api/peeringserverpreferences/${id}";
	my $collection_id = 'ngcp:peeringserverpreferences';

	return $self->_set_content($data, $urldata);
}

sub create_peeringserver {
	my $self = shift;
	my $data = shift;
	my $urldata = '/api/peeringservers/';

	return $self->_create($data, $urldata);
}

sub set_peeringserver {
	my $self = shift;
	my $id = shift;
	my $data = shift;
	my $urldata = "/api/peeringservers/${id}";
	my $collection_id = 'ngcp:peeringservers';

	return $self->_set_content($data, $urldata);
}

sub get_peeringserver {
	my $self = shift;
	my $id = shift;
	my $urldata = "/api/peeringservers/${id}";
	my $collection_id = 'ngcp:peeringservers';

	return $self->_get_content(undef, $urldata);
}

sub delete_peeringserver {
	my $self = shift;
	my $id = shift;
	my $urldata = "/api/peeringservers/${id}";

	return $self->_delete($urldata);
}

sub check_peeringrule_exists {
	my $self = shift;
	my $data = shift;
	my $urldata = '/api/peeringrules/';
	my $collection_id = 'ngcp:peeringrules';

	return $self->_exists($data, $urldata, $collection_id);
}

sub create_peeringrule {
	my $self = shift;
	my $data = shift;
	my $urldata = '/api/peeringrules/';

	return $self->_create($data, $urldata);
}

sub delete_peeringrule {
	my $self = shift;
	my $id = shift;
	my $urldata = "/api/peeringrules/${id}";

	return $self->_delete($urldata);
}

sub check_ncoslevel_exists {
	my $self = shift;
	my $data = shift;
	my $urldata = "/api/ncoslevels/";
	my $collection_id = 'ngcp:ncoslevels';

	return $self->_exists($data, $urldata, $collection_id);
}

sub create_ncoslevel {
	my $self = shift;
	my $data = shift;
	my $urldata = '/api/ncoslevels/';

	return $self->_create($data, $urldata);
}

sub delete_ncoslevel {
	my $self = shift;
	my $id = shift;
	my $urldata = "/api/ncoslevels/${id}";

	return $self->_delete($urldata);
}

sub check_ncospattern_exists {
	my $self = shift;
	my $data = shift;
	my $urldata = "/api/ncospatterns/";
	my $collection_id = 'ngcp:ncospatterns';

	return $self->_exists($data, $urldata, $collection_id);
}

sub create_ncospattern {
	my $self = shift;
	my $data = shift;
	my $urldata = '/api/ncospatterns/';

	return $self->_create($data, $urldata);
}

sub delete_ncospattern {
	my $self = shift;
	my $id = shift;
	my $urldata = "/api/ncospatterns/${id}";

	return $self->_delete($urldata);
}
