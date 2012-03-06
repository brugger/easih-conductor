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


#use EASIH::Misc;
#my $rand_dbname = EASIH::Misc::random_string(20);
my $rand_dbname = "test";
print "Database name :: $rand_dbname\n";
use EASIH::DB;
use EASIH::DB::Conductor;

use Test::Simple tests => 29;

my $dbhost = 'localhost';

# Create a random dbase that we can play with...
EASIH::DB::create_db($rand_dbname, $dbhost, "easih_admin", "easih");
my $dbi_DB = EASIH::DB::connect($rand_dbname, $dbhost, "easih_admin", "easih");
if (-e "sql/conductor.sql") {
  EASIH::DB::sql_file($dbi_DB, "sql/conductor.sql");
}
elsif (-e "../sql/conductor.sql") {
  EASIH::DB::sql_file($dbi_DB, "../sql/conductor.sql");
}

my $dbi = EASIH::DB::Conductor::connect($rand_dbname, $dbhost, "easih_admin", "easih");

ok( $dbi, 'Created and Connect to test database');

##           PROJECT              ##
my $pid = EASIH::DB::Conductor::insert_project("a99");
ok($pid, 'Inserted a99 into project');

$pid = EASIH::DB::Conductor::update_project($pid, "A99");
ok($pid, 'Updated a99 to A99 in project');

my $fetched_pid = EASIH::DB::Conductor::fetch_project_id("A99");
ok($fetched_pid == $pid, 'Fetched pid for A99 is correct');

my $fetched_name = EASIH::DB::Conductor::fetch_project_name( $pid );
ok($fetched_name eq "A99", 'Fetched project name by pid is correct');

##           SAMPLES              ##
my $sid = EASIH::DB::Conductor::insert_sample($pid + 999, "a990001");
ok(! defined $sid, "Check for invalid pid with insert sample");

$sid = EASIH::DB::Conductor::insert_sample($pid, "a990001");
ok($sid, "Inserted a990001 into sample");

$sid = EASIH::DB::Conductor::update_sample($sid, "A990001");
ok($sid, 'Updated a990001 to A990001 in sample');

my $fetched_sid = EASIH::DB::Conductor::fetch_sample_id("A990001");
ok($fetched_sid == $sid, 'Fetched sid for A990001 is correct');

$fetched_name = EASIH::DB::Conductor::fetch_sample_name( $sid );
ok($fetched_name eq "A990001", 'Fetched sample name by pid is correct');

##           SEQUENCER            ##
my $mid = EASIH::DB::Conductor::insert_sequencer(undef, "HiSeq1000");
ok(! defined $mid, "Check for missing name with insert sequencer");

$mid = EASIH::DB::Conductor::insert_sequencer(undef, "HiSeq1000");
ok(! defined $mid, "Check for missing platform with insert sequencer");

$mid = EASIH::DB::Conductor::insert_sequencer("illumina4", "HiSeq1000");
ok(defined $mid, "Inserted illumina4, HiSeq2000 into sequencer table");

my $updated_mid = EASIH::DB::Conductor::update_sequencer($mid, "Illumina4", "HiSeq 2000");
ok(defined $updated_mid, 'Updated sequencer, changed the name + platform');

my $fetched_mid = EASIH::DB::Conductor::fetch_sequencer_id("Illumina4");
ok($mid == $updated_mid, 'Fetched sid for A990001 is correct');

my $sequencer = EASIH::DB::Conductor::fetch_sequencer( $mid );
ok($sequencer && 
   $$sequencer{name} eq "Illumina4" &&
   $$sequencer{platform} eq "HiSeq 2000", 'Fetched sequencer correctly');

##           RUN            ##
my $rid = EASIH::DB::Conductor::insert_run(undef, "120229_MGILLUMINA2_00066_FC");
ok(! defined $rid, "Check for missing sequencer id (mid) with insert run");

$rid = EASIH::DB::Conductor::insert_run($updated_mid, undef);
ok(! defined $rid, "Check for missing name with insert run");

$rid = EASIH::DB::Conductor::insert_run($updated_mid, "120229_ILLUMINA2_00066_FC");
ok(defined $rid, "Inserted run");

my $updated_rid = EASIH::DB::Conductor::update_run($rid, $mid, "120229_ILLUMINA2_00066_FC");
ok(defined $updated_mid, 'Failing updateing sequencer, wrong rid');

my $fetched_rid = EASIH::DB::Conductor::fetch_run_id("120229_ILLUMINA2_00066_FC");
ok($rid == $fetched_rid, 'Fetched run id (rid) correctly');

my $run = EASIH::DB::Conductor::fetch_run( $rid );
ok($run && 
   $$run{name} eq "120229_ILLUMINA2_00066_FC" &&
   $$run{mid} eq $mid, 'Fetched run correctly');




##           FILE              ##
my $fid = EASIH::DB::Conductor::insert_file();
ok(! defined $fid, "Check for missing sid in insert sample");

$fid = EASIH::DB::Conductor::insert_file($sid, undef, undef);
ok(! defined $fid, "Check for missing rid in insert sample");

$fid = EASIH::DB::Conductor::insert_file($sid, $rid, undef);
ok(! defined $fid, "Check for missing name in insert sample");

$fid = EASIH::DB::Conductor::insert_file($sid, $rid, "/data/A99/A990001.1.fq.gz");
ok($fid, "Inserted /data/A99/A990001.1.fq.gz into file");


##           ANALYSIS             ##
my $aid = EASIH::DB::Conductor::insert_analysis("BRCA", "NILES");
ok($aid, 'Inserted ref: BRCA w/ pipeline NILES into analysis');

my $fetched_aid = EASIH::DB::Conductor::fetch_analysis_id("BRCA", "NILES");
ok($aid && $fetched_aid == $aid, "Fetch aid ref: BRCA w/ pipeline NILES.");

my $analysis_ref = EASIH::DB::Conductor::fetch_analysis( $aid );
ok($analysis_ref && $$analysis_ref{reference} eq "BRCA" && $$analysis_ref{pipeline} eq "NILES", "Fetched analysis is correct");



# Delete the tmp database now when we are done with it.
END {
  EASIH::DB::drop_db($rand_dbname, $dbhost, "easih_admin", "easih");
}
