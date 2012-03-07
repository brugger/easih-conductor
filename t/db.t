#!/usr/bin/perl 
# 
# 
# 
# 
# Kim Brugger (07 Feb 2012), contact: kim.brugger@easih.ac.uk

use strict;
use warnings;
use Data::Dumper;

use Test::Simple tests => 19;

use lib '/home/kb468/easih-toolbox/modules/';
use lib '/home/kb468/projects/conductor/modules';


#use EASIH::Misc;
#my $rand_dbname = EASIH::Misc::random_string(20);
my $rand_dbname = "test";
print "Database name :: $rand_dbname\n";
use EASIH::DB;

my $dbhost = 'localhost';

# Create a random dbase that we can play with...
EASIH::DB::create_db($rand_dbname, $dbhost, "easih_admin", "easih");
my $dbi = EASIH::DB::connect($rand_dbname, $dbhost, "easih_admin", "easih");
if (-e "sql/db.sql") {
  EASIH::DB::sql_file($dbi, "sql/db.sql");
}
elsif (-e "../sql/db.sql") {
  EASIH::DB::sql_file($dbi, "../sql/db.sql");
}


ok( $dbi, 'Created and Connect to test database');

my $id1 = EASIH::DB::insert($dbi, "test", {string => "Entry 1"});
ok($id1 , 'Insert into table w/ primary key' );
my $id2 = EASIH::DB::insert($dbi, "test", {string => "Entry 2"});
$id2 = EASIH::DB::update($dbi, "test", {string => "Entry 2", id => $id2}, "id");
ok($id2 , 'Update record in table w/ primary key' );

my $id3 = EASIH::DB::insert($dbi, "test2", {string => "Entry 2", id=>10});
ok($id3 == -1 , 'Insert into table wo/ primary key' );
$id3 = EASIH::DB::update($dbi, "test2", {string => "Entry 2", id => $id3}, "id");
ok($id3 == -1 , 'Update record in table wo/ primary key' );

$id3 = EASIH::DB::insert($dbi, "test2", {strings => "Entry 2", ids=>10});
ok(! defined $id3, 'Insert into table w/ wrong column name' );
$id3 = EASIH::DB::update($dbi, "test2", {strings => "Entry 2", ids => $id3}, "id");
ok(! defined $id3, 'Update record in table w/ wrong column name' );

my $sth = EASIH::DB::prepare($dbi, "select * from test where id = ?");
ok($sth , 'Prepare a sql statement' );

my $array_ref = EASIH::DB::fetch_array($dbi, $sth, $id1);
ok(ref($array_ref) eq "ARRAY", 'ref fetch_array returns correct types' );

my @array = EASIH::DB::fetch_array($dbi, $sth, $id1);
ok(@array && $array[0], 'fetch_array returns correct types' );

my $hash_ref = EASIH::DB::fetch_hash($dbi, $sth, $id1);
ok(ref($hash_ref) eq "HASH" , 'ref fetch_hash returns correct types' );

my %hash = EASIH::DB::fetch_hash($dbi, $sth, $id1);
ok(%hash && $hash{id}, 'fetch_hash returns correct types' );

my $array_array_ref = EASIH::DB::fetch_array_array($dbi, $sth, $id1);
ok(ref($array_array_ref) eq "ARRAY" && ref($$array_array_ref[0]) eq "ARRAY" , 'ref fetch_array_array returns correct types' );

my @array_array = EASIH::DB::fetch_array_array($dbi, $sth, $id1);
ok(@array_array && ref($array_array[0]) eq "ARRAY" , 'ref fetch_array_array returns correct types' );

my $array_hash_ref = EASIH::DB::fetch_array_hash($dbi, $sth, $id1);
ok(ref($array_hash_ref) eq "ARRAY" && ref($$array_hash_ref[0]) eq "HASH" , 'ref fetch_array_hash returns correct types' );

my @array_hash = EASIH::DB::fetch_array_hash($dbi, $sth, $id1);
ok(@array_hash && ref($array_hash[0]) eq "HASH" , 'fetch_array_hash returns correct types' );

my $timestamp = EASIH::DB::highres_timestamp();
ok($timestamp , 'create a highres timestamp' );
$timestamp = 133113657706274;
my ($time, $micro) = EASIH::DB::split_highres_timestamp( $timestamp);
ok( $time == 1331136577.06274 && $micro == 6274,  'split highres timestamp into normal time and micro seconds');

$time = EASIH::DB::highres_timestamp2localtime( $timestamp);
ok( $time eq "07/03/2012 16:09:37.06274",  'split highres timestamp into localtime');


# Delete the tmp database now when we are done with it.
END {
  EASIH::DB::drop_db($rand_dbname, $dbhost, "easih_admin", "easih");
}
