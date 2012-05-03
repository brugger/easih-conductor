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

use Test::More tests => 53;

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
my $pid = EASIH::DB::Conductor::insert_project("a99", "notes", 'tyt@tam.sd');
ok($pid, 'Inserted a99 into project');

$pid = EASIH::DB::Conductor::update_project($pid, "A99");
ok($pid, 'Updated a99 to A99 in project');

my $fetched_pid = EASIH::DB::Conductor::fetch_project_id("A99");
ok($fetched_pid == $pid, 'Fetched pid for A99 is correct');

my $fetched_name = EASIH::DB::Conductor::fetch_project_name( $pid );
ok($fetched_name eq "A99", 'Fetched project name by pid is correct');

my $fetched_hash = EASIH::DB::Conductor::fetch_project_hash( $pid );
ok($$fetched_hash{notes} eq "notes" && $$fetched_hash{contacts} eq 'tyt@tam.sd', 'Fetched project hash by pid contains the correct information');

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

$fid = EASIH::DB::Conductor::insert_file($sid, $rid, "/data/A99/A990001.1.fq");
ok($fid, "Inserted /data/A99/A990001.1.fq.gz into file");

my $updated_fid = EASIH::DB::Conductor::update_file($fid, "/data/A99/A990001.1.fq.gz");
ok(defined $updated_fid, 'Updated a file entry');

my $fetched_fid = EASIH::DB::Conductor::fetch_file_id("/data/A99/A990001.1.fq.gz");
ok ($fetched_fid == $updated_fid, 'Fetched correct fileid (fid)');

my $fetched_file_name = EASIH::DB::Conductor::fetch_file_name($fetched_fid);
ok ($fetched_file_name eq "/data/A99/A990001.1.fq.gz", 'Fetched correct file name ');


my $expected_hash = {'sid' => '1',
		     'fid' => '1',
		     'name' => '/data/A99/A990001.1.fq.gz',
		     'rid' => '1'};

my $file_hash1 = EASIH::DB::Conductor::fetch_file($fetched_fid);
my $file_hash2 = EASIH::DB::Conductor::fetch_file($fetched_file_name);
is_deeply($file_hash1, $expected_hash, "generic file fetch function returns correctly with a file id");
is_deeply($file_hash1, $file_hash2, "generic file fetch function returns correctly with file id and file name");

##           ANALYSIS             ##
my $aid = EASIH::DB::Conductor::insert_analysis("BRCA2", "NILES");
ok($aid, 'Inserted ref: BRCA2 w/ pipeline NILES into analysis');

$aid = EASIH::DB::Conductor::update_analysis($aid, "BRCA", "NILES", 100000);
ok($aid, 'Updated analysis ref to BRCA w/ pipeline NILES w/ 100000 reads');

my $fetched_aid = EASIH::DB::Conductor::fetch_analysis_id("BRCA", "NILES");
ok($aid && $fetched_aid == $aid, "Fetch aid ref: BRCA w/ pipeline NILES.");

my $analysis_ref = EASIH::DB::Conductor::fetch_analysis( $aid );
ok($analysis_ref && $$analysis_ref{reference} eq "BRCA" && $$analysis_ref{pipeline} eq "NILES", "Fetched analysis is correct");

##           RUN_STATUS           ##
my $rsid = EASIH::DB::Conductor::insert_run_status($rid, "RUN STARTED");
ok($rsid == -1, 'Insert run status');

my $rs = EASIH::DB::Conductor::fetch_run_statuses($rid);
ok($rs && $$rs[0][0] == $rid && $$rs[0][1] eq "RUN STARTED", 'fetched run_statuses');

##           FILE_STATUS           ##
my $fsid = EASIH::DB::Conductor::insert_file_status($fid, "QC STARTED");
ok($fsid == -1, 'Insert file status');

my $fs = EASIH::DB::Conductor::fetch_file_statuses($rid);
ok($fs && $$fs[0][0] == $fid && $$fs[0][1] eq "QC STARTED", 'fetched file_statuses');


##           FILE_STATUS           ##
my $sasid = EASIH::DB::Conductor::insert_sample_analysis_status($sid, "MARIS STARTED");
ok($sasid == -1, 'Insert file status');

my $sas = EASIH::DB::Conductor::fetch_sample_analysis_statuses($sid);
ok($sas && $$fs[0][0] == $sid && $$sas[0][1] eq "MARIS STARTED", 'fetched sample_analalysis_statuses');

##           CRR_STATUS           ##

my @r = (['1','ok',1], ['1','waiting',5]);

ok( $sasid = EASIH::DB::Conductor::insert_sample_crr($sid, @r ), 
    'Insert sample crr array_array');

my $crrs = EASIH::DB::Conductor::fetch_sample_crr($sid);
ok($crrs && $$crrs[0][0] == 1 , 'fetch sample crr array_array');

ok( $crrs = EASIH::DB::Conductor::delete_sample_crr($sid), 
   'deleted sample crr entries');

$crrs = EASIH::DB::Conductor::fetch_sample_crr($sid);
ok($crrs && !$$crrs[0] , 'fetched empty sample crr array_array');

##         SAMPLE SHEETS          ##

my $ssid = EASIH::DB::Conductor::insert_sample_sheet_line( undef, 1, "Z990001");
ok(!$ssid , 'insert sample_sheet_line w/ missing run id (rid)');
$ssid = EASIH::DB::Conductor::insert_sample_sheet_line( $rid, undef, "Z990001");
ok(!$ssid , 'insert sample_sheet_line w/ missing lane');
$ssid = EASIH::DB::Conductor::insert_sample_sheet_line( $rid, 1);
ok(!$ssid , 'insert sample_sheet_line w/ sample name');

$ssid = EASIH::DB::Conductor::insert_sample_sheet_line( $rid, 1, "Z990001");
ok($ssid == -1 , 'Inserted line into sample sheet wo/ barcode');
$ssid = EASIH::DB::Conductor::insert_sample_sheet_line( $rid, 2, "Z990002", "ACGT");
ok($ssid == -1 , 'Inserted line into sample sheet w/ barcode');
EASIH::DB::Conductor::insert_sample_sheet_line( $rid, 2, "Z990003", "CAGT");
EASIH::DB::Conductor::insert_sample_sheet_line( $rid, 3, "Z990004", "GACT");
EASIH::DB::Conductor::insert_sample_sheet_line( 5, 3, "Z990004", "GACT");

my $array_ss = EASIH::DB::Conductor::fetch_sample_sheet_array($rid);
my $hash_ss  = EASIH::DB::Conductor::fetch_sample_sheet_hash($rid);
my $ss       = EASIH::DB::Conductor::fetch_sample_sheet($rid);

ok($$array_ss[0][2] eq "Z990001" , 'Fetched correct array sample sheet');
ok($$hash_ss[1]{'barcode'} eq "ACGT" , 'Fetched correct hash sample sheet');


# Delete the tmp database now when we are done with it.
END {
  EASIH::DB::drop_db($rand_dbname, $dbhost, "easih_admin", "easih");
}

