#!/usr/bin/perl 
# 
# 
# 
# 
# Kim Brugger (07 Feb 2012), contact: kim.brugger@easih.ac.uk

use strict;
use warnings;
use Data::Dumper;

# Sets up dynamic paths for EASIH modules...
# Makes it possible to work with multiple checkouts without setting 
# perllib/perl5lib in the enviroment.
BEGIN {
  my $DYNAMIC_LIB_PATHS = 1;
  if ( $DYNAMIC_LIB_PATHS ) {
    my $path = $0;
    
    if ($path =~ /.*\//) {
      $path =~ s/(.*)\/.*/$1/;
      push @INC, "$path/modules" if ( -e "$path/modules");
      $path =~ s/(.*)\/.*/$1/;
      push @INC, "$path/modules" if ( -e "$path/modules" && ! grep /^$path\/modules/, @INC);
    }
    else {
      push @INC, "../modules" if ( -e "../modules");
      push @INC, "./modules" if ( -e "./modules");
    }
  }
  else {
    push @INC, '/home/kb468/easih-toolbox/modules/';
  }

}

use lib '/home/kb468/easih-toolbox/modules/';
use lib '/home/kb468/projects/conductor/modules';
use lib '/home/kb468/projects/easih-conductor/modules';


#use EASIH::Misc;
#my $rand_dbname = EASIH::Misc::random_string(20);
my $rand_dbname = "test";
print "Database name :: $rand_dbname\n";
use EASIH::DB;
use EASIH::DB::EASIH_user;

use Test::More tests => 14;

my $dbhost = 'localhost';

# Create a random dbase that we can play with...
EASIH::DB::create_db($rand_dbname, $dbhost, "easih_admin", "easih");
my $dbi_DB = EASIH::DB::connect($rand_dbname, $dbhost, "easih_admin", "easih");
if (-e "sql/conductor.sql") {
  EASIH::DB::sql_file($dbi_DB, "sql/EASIH_user.sql");
}
elsif (-e "../sql/conductor.sql") {
  EASIH::DB::sql_file($dbi_DB, "../sql/EASIH_user.sql");
}

my $dbi = EASIH::DB::EASIH_user::connect($rand_dbname, $dbhost, "easih_admin", "easih");

ok( $dbi, 'Created and Connect to test database');

##           USER               ##
my $uid = EASIH::DB::EASIH_user::insert_user("kb468", "password1");
ok($uid, 'Inserted kb468 as a user');

$uid = EASIH::DB::EASIH_user::update_user($uid, "kb468", "password2");
ok($uid, 'Updated the password for user kb468');

my $fetched_uid = EASIH::DB::EASIH_user::fetch_user_id("kb468");
ok($fetched_uid == $uid, 'Fetched uid for user kb468');

my $fetched_name = EASIH::DB::EASIH_user::fetch_user_name( $uid );
ok($fetched_name eq "kb468", 'Fetched user name by uid');



##           USER               ##
my $gid = EASIH::DB::EASIH_user::insert_group("admin");
ok($gid, 'Inserted admin group ');

$gid = EASIH::DB::EASIH_user::insert_group("info");
ok($gid, 'Inserted info group ');


my $fetched_gid = EASIH::DB::EASIH_user::fetch_group_id("info");
ok($fetched_gid == $gid, 'Fetched gid for group info');

$fetched_name = EASIH::DB::EASIH_user::fetch_group_name( $gid );
ok($fetched_name eq "info", 'Fetched group name by gid');

my $ugid = EASIH::DB::EASIH_user::insert_user_group_ids( $uid, $gid );
ok($ugid == -1 , 'Linked user to the infor group');

my @groups = EASIH::DB::EASIH_user::fetch_user_group_ids($uid);
ok($groups[0] == $gid , 'fetched what group ids a user is linked to');

my $ugid = EASIH::DB::EASIH_user::insert_user_group_ids( $uid, 1 );
ok($ugid == -1 , 'Linked user to the admin group');

 @groups = EASIH::DB::EASIH_user::fetch_user_group_ids($uid);
ok($groups[0] == 1 && $groups[1] == 2 , 'fetched what group ids a user is linked to');

@groups = EASIH::DB::EASIH_user::fetch_user_group_names($uid);
ok($groups[0] eq 'admin' &&  $groups[1] eq 'info', 'fetched what group names a user is linked to');


# Delete the tmp database now when we are done with it.
END {
  EASIH::DB::drop_db($rand_dbname, $dbhost, "easih_admin", "easih");
}

