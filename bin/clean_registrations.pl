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
use Capture::Tiny qw(capture);
use YAML::XS;
use List::MoreUtils qw(uniq);
use DBI qw(:sql_types);

my $CONSTANTS = YAML::XS::LoadFile('/etc/ngcp-config/constants.yml');

sub usage
{
  my $output = "usage: $PROGRAM_NAME [-h] scenario.yml\n";
  $output .= "Options:\n";
  $output .= "\t-h: this help\n";
  return $output
}

my $help = 0;
my $del = 0;
GetOptions ("h|help" => \$help)
  or die("Error in command line arguments\n".usage());

die(usage()) unless (!$help);
die("Wrong number of arguments\n".usage()) unless ($#ARGV == 0);

my $filename = abs_path($ARGV[0]);
my $cf = YAML::XS::LoadFile($filename);
my $MYSQL_CREDENTIALS = "/etc/mysql/sipwise_extra.cnf";

if (! -e ${MYSQL_CREDENTIALS}) {
  die("Error: missing DB credentials file '${MYSQL_CREDENTIALS}'.\n")
}

sub get_mysql_credentials {
  return $CONSTANTS->{credentials}->{mysql}->{system}->{u};
}

sub get_nodename {
    my @lines = capturex( [ 0 ], "/usr/sbin/ngcp-nodename");
    my $l = shift @lines;
    chomp $l;
    return $l;
}

sub connect_db {
    my ($dbhost, $dbport, $mysql_user, $mysql_pass) = @_;

    my $dsn = "DBI:mysql:database=mysql;host=$dbhost;port=$dbport";
    if ( $mysql_user eq get_mysql_credentials() ) {
        $dsn .= ";mysql_read_default_file=$MYSQL_CREDENTIALS";
    }

    my $dbh = DBI->connect($dsn, $mysql_user, $mysql_pass,
                            { PrintError => 1, mysql_auto_reconnect => 1 })
        or die "Can't connect to MySQL: ". $DBI::errstr;
    return $dbh;
}

sub run_cmd {
    my $cmd = shift;
    my $rc = 0;
    my ($out, $err) = capture {
        system($cmd);
        $rc = $CHILD_ERROR >> 8;
    };
    # error adjustments
    if ($err =~ 'Warning: Skipping the data of table mysql\.event') {
        $err = '';
    }
    if ($err =~ 'Warning: Permanently added') {
        $err = '';
    }

    return ($rc, $out, $err);
}

sub kamailio_ul_lookup
{
    my $subs = shift;
    my ($rc, $out, $err) = run_cmd("ngcp-kamcmd proxy ul.lookup location ${subs}");
    if ($err) {
        $err = join(", ", split(/\r*\n/, $err));
        die "Error looking up ${subs} from kamailio: $err (errno: $rc)";
    }
    print("location ${subs} from kamailio\n${out}\n");
}

sub clean_kamailio_ul
{
    my $subs = shift;
    my ($rc, undef, $err) = run_cmd("ngcp-kamcmd proxy ul.rm location ${subs}");
    if ($err) {
        $err = join(", ", split(/\r*\n/, $err));
        die "Error removing ${subs} from kamailio: $err (errno: $rc)";
    }
    print("clean location ${subs} from kamailio\n");
}

sub clean_kamailio
{
    my $data = shift;
    my @values = ();
    foreach (@{$data->{scenarios}})
    {
        push @values, $_->{username}."@".$_->{domain};
        foreach (@{$_->{responders}})
        {
            $_->{active} = "yes" unless defined($_->{active});
            if($_->{register} eq "yes" && $_->{active} eq "yes")
            {
                push @values, $_->{username}."@".$_->{domain};
            }
        }
    }
    foreach (uniq @values) {
        clean_kamailio_ul($_);
    }
    return;
}

sub usrloc_in_redis
{
    my ($rc, $out, $err) = run_cmd("ngcpcfg get kamailio.proxy.redis.usrloc");
    if ($err) {
        $err = join(", ", split(/\r*\n/, $err));
        print "Error getting kamailio.proxy.redis.usrloc config\n";
        return 0;
    }
    if($out =~ "yes") {
        return 1;
    }
    return 0;
}

sub clean_locations
{
    my $local_host = $CONSTANTS->{database}{local}{dbhost};
    my $local_port = $CONSTANTS->{database}{local}{dbport};
    my $local_user = get_mysql_credentials();
    my $local_pass = undef;
    my $local_dbh  = connect_db($local_host, $local_port, $local_user, $local_pass);

    my $sht = $local_dbh->prepare(<<SQL);
SELECT count(id) FROM kamailio.location
SQL
    $sht->execute() or die "Cannot get locations: $DBI::errstr";
    my ($num) = $sht->fetchrow_array;
    print("${num} in location\n");
    if($num gt 0) {
        print("Cleaning location table\n");
        my $aors = $local_dbh->selectall_arrayref(<<SQL);
SELECT concat(username, "@", domain) as user from kamailio.location
SQL
        die "Cannot get locations: $DBI::errstr" if $DBI::err;
        foreach (@{$aors}) {
            clean_kamailio_ul($_);
        }
        $local_dbh->do(<<SQL);
DELETE from kamailio.location
SQL
        die "Cannot delete locations: $DBI::errstr" if $DBI::err;
    }
}

clean_kamailio($cf);
if(usrloc_in_redis() eq 0) {
    clean_locations();
}
