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

my $dbhost = 'localhost';

#use EASIH::Misc;
#my $rand_dbname = EASIH::Misc::random_string(20);
my $rand_dbname = "test";
print "Database name :: $rand_dbname\n";

use Test::Simple tests => 4;
use EASIH::VCFdb;

#EASIH::DB::drop_db($rand_dbname, $dbhost, "easih_admin", "easih");

# Create a random dbase that we can play with...
EASIH::DB::create_db($rand_dbname, $dbhost, "easih_admin", "easih");
my $dbi_DB = EASIH::DB::connect($rand_dbname, $dbhost, "easih_admin", "easih");
if (-e "sql/VCFdb.sql") {
  EASIH::DB::sql_file($dbi_DB, "sql/VCFdb.sql");
}
elsif (-e "../sql/VCFdb.sql") {
  EASIH::DB::sql_file($dbi_DB, "../sql/VCFdb.sql");
}

my $dbi = EASIH::VCFdb::connect($rand_dbname, $dbhost, "easih_admin", "easih");
ok( $dbi, 'Created and Connect to test database');

##           PROJECT              ##
my $pid = EASIH::VCFdb::insert_project("a99");
ok($pid, 'Inserted a99 into project');

$pid = EASIH::VCFdb::update_project($pid, "A99");
ok($pid, 'Updated a99 to A99 in project');

my $fetched_pid = EASIH::VCFdb::fetch_project_id("A99");
ok($fetched_pid == $pid, 'Fetched pid for A99 is correct');

my $fetched_name = EASIH::VCFdb::fetch_project_name( $pid );
ok($fetched_name eq "A99", 'Fetched project name by pid is correct');


my $sid = EASIH::VCFdb::insert_sample($pid + 999, "a990001");
ok(! defined $sid, "Check for invalid pid with insert sample");

$sid = EASIH::VCFdb::insert_sample($pid, "a990001", "HEADER");
ok($sid, "Inserted a990001 into sample");
$sid = EASIH::VCFdb::update_sample($sid, "A990001", "NEW HEADER");
ok($sid, 'Updated a990001 to A990001 in sample');

my $fetched_sid = EASIH::VCFdb::fetch_sample_id("A990001");
ok($fetched_sid == $sid, 'Fetched sid for A990001 is correct');

$fetched_name = EASIH::VCFdb::fetch_sample_name( $fetched_sid );
ok($fetched_name eq "A990001", 'Fetched sample name by pid is correct');



# Delete the tmp database now when we are done with it.
END {
  EASIH::DB::drop_db($rand_dbname, $dbhost, "easih_admin", "easih");
}

