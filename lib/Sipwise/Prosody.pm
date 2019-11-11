#
# Copyright: 2019 Sipwise Development Team <support@sipwise.com>
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
package Sipwise::Prosody 0.001;
use strict;
use warnings;

use English;
use NGCP::Panel::Utils::Prosody;

use Net::Telnet;

my $hosts = [{ip => '127.0.0.1', port => 5582,}];

sub activate_domain {
    my ($domain) = @_;

    my $t = Net::Telnet->new(Timeout => 5);
    my $ok = 1;
    foreach my $host(@{ $hosts }) {
        $t->open(Host => $host->{ip}, Port => $host->{port});
        $t->waitfor('/http:\/\/prosody.im\/doc\/console/');
        $t->print("host:activate('$domain')");
        my ($res, $amatch)  = $t->waitfor(
            Match => '/(Result: \w+)|(Message: .+)/',
            Timeout => 20
        );
        if($amatch =~ /Result:\s*true/) {
            # fine
        } else {
            $ok = 0;
        }
        $t->print("host:activate('search.$domain', { component_module = 'sipwise_vjud' })");
        ($res, $amatch)  = $t->waitfor('/(Result: \w+)|(Message: .+)/');
        if($amatch =~ /Result:\s*true/) {
            # fine
        } else {
            $ok = 0;
        }
    }

    return $ok if($ok);
    return;
}

sub deactivate_domain {
    my ($domain) = @_;

    my $t = Net::Telnet->new(Timeout => 5);
    my $ok = 1;
    foreach my $host(@{ $hosts }) {
        $t->open(Host => $host->{ip}, Port => $host->{port});
        $t->waitfor('/http:\/\/prosody.im\/doc\/console/');
        $t->print("host:deactivate('$domain')");
        my ($res, $amatch)  = $t->waitfor(
            Match => '/(Result: \w+)|(Message: .+)/',
            Timeout => 20
        );
        if($amatch =~ /Result:\s*true/) {
            # fine
        } else {
            $ok = 0;
        }
        $t->print("host:deactivate('search.$domain')");
        ($res, $amatch)  = $t->waitfor('/(Result: \w+)|(Message: .+)/');
        if($amatch =~ /Result:\s*true/) {
            # fine
        } else {
            $ok = 0;
        }
    }

    return $ok if($ok);
    return;
}
