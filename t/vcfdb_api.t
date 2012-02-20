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

use Test::More tests => 37;
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
my $pid = EASIH::VCFdb::insert_project(undef);
ok(!defined $pid, 'Check for provided pid when inserting a project');

$pid = EASIH::VCFdb::insert_project("a99");
ok($pid, 'Inserted a99 into project');

$pid = EASIH::VCFdb::update_project($pid, "A99");
ok($pid, 'Updated a99 to A99 in project');

my $fetched_pid = EASIH::VCFdb::fetch_project_id("A99");
ok($fetched_pid == $pid, 'Fetched pid for A99 is correct');

my $fetched_name = EASIH::VCFdb::fetch_project_name( $pid );
ok($fetched_name eq "A99", 'Fetched project name by pid is correct');

my $sid = EASIH::VCFdb::insert_sample($pid + 999, "a990001", "HEADER");
ok(! defined $sid, "Check for provided VCF_header when inserting a sample");

$sid = EASIH::VCFdb::insert_sample(undef, "a990001", "NEW HEADER");
ok(! defined $sid, "Check for provided pid when inserting a sample");

$sid = EASIH::VCFdb::insert_sample($pid, , "NEW HEADER");
ok(! defined $sid, "Check for provided sample name when inserting a sample");

$sid = EASIH::VCFdb::insert_sample($pid + 999, "a990001");
ok(! defined $sid, "Check for invalid pid with insert sample");

$sid = EASIH::VCFdb::insert_sample($pid, "a990001", "HEADER");
ok($sid, "Inserted a990001 into sample");
$sid = EASIH::VCFdb::update_sample($sid, "A990001", "NEW HEADER");
ok($sid, 'Updated a990001 to A990001 in sample');

my $fetched_sid = EASIH::VCFdb::fetch_sample_id("A990001");
ok($fetched_sid == $sid, 'Fetched sid for A990001 is correct');

$fetched_name = EASIH::VCFdb::fetch_sample_name( $fetched_sid );
ok($fetched_name eq "A990001", 'Fetched sample name by pid is correct');

my $vid = EASIH::VCFdb::insert_variation(undef, 1000000, "AA", "T");
ok(! defined $vid, "Check for provided chr when inserting a variation");

$vid = EASIH::VCFdb::insert_variation(12, undef, "AA", "T");
ok(! defined $vid, "Check for provided pos when inserting a variation");

$vid = EASIH::VCFdb::insert_variation(12, 1000000, undef, "T");
ok(! defined $vid, "Check for provided ref when inserting a variation");

$vid = EASIH::VCFdb::insert_variation(12, 1000000, "AA", undef);
ok(! defined $vid, "Check for provided alt when inserting a variation");

$vid = EASIH::VCFdb::insert_variation(12, 1000000, "AA", "T");
ok( $vid, "Inserted 12:1000000, AA>T into variation");

my %var = EASIH::VCFdb::hash_fetch_variation_by_vid( $vid );
ok( $var{vid} eq $vid    &&
    $var{chr} eq 12      &&
    $var{pos} eq 1000000 &&
    $var{ref} eq "AA"    &&
    $var{alt} eq "T"     &&
    $var{status} eq "unannotated", "Correctly fetched 12:1000000, AA>T from variation");

my @vars = EASIH::VCFdb::fetch_variation_by_chr_pos(12, 1000000);
%var = %{$vars[0]};
ok( $var{vid} eq $vid    &&
    $var{chr} eq 12      &&
    $var{pos} eq 1000000 &&
    $var{ref} eq "AA"    &&
    $var{alt} eq "T"     &&
    $var{status} eq "unannotated", "Correctly fetched 12:1000000, AA>T from variation");

my $new_vid = EASIH::VCFdb::update_variation(undef, 1000000, "AA", "T");
ok(! defined $new_vid, "Check for provided vid when updating a variation");

$new_vid = EASIH::VCFdb::update_variation($vid, 11);
ok( $new_vid, "Updated variation chromosome");

$new_vid = EASIH::VCFdb::update_variation($vid, undef, 1000001);
ok( $new_vid, "Updated variation position");

$new_vid = EASIH::VCFdb::update_variation($vid, undef, undef, "AAA");
ok( $new_vid, "Updated variation reference in variation");

$new_vid = EASIH::VCFdb::update_variation($vid, undef, undef, undef, "TT");
ok( $new_vid, "Updated alt in variation");

$new_vid = EASIH::VCFdb::update_variation($vid, undef, undef, undef, undef, "annotated");
ok(! defined $new_vid, "Updated variation check for correct status flags");

$new_vid = EASIH::VCFdb::update_variation($vid, undef, undef, undef, undef, "analysis");
ok( $new_vid, "Updated variation check for correct status flags");

$new_vid = EASIH::VCFdb::update_variation($vid, undef, undef, undef, undef, "done");
ok( defined $new_vid, "Updated variation check for correct status flags");

%var = EASIH::VCFdb::hash_fetch_variation_by_vid( $vid );
ok( $var{vid} eq $vid    &&
    $var{chr} eq 11      &&
    $var{pos} eq 1000001 &&
    $var{ref} eq "AAA"    &&
    $var{alt} eq "TT"     &&
    $var{status} eq "done", "Updated 12:1000000, AA>T to 11:1000001 AAA>TT in variation");



my %call_hash = (filter        => "PASS",
		 score         => 1000,
		 format_keys   => "GT:AD:DP:GQ:PL",
		 format_values => "0/1:39,32:71:99:650,0,804");

my $svid = EASIH::VCFdb::insert_sample_data(\%call_hash);
ok( ! defined $svid, "Fail inserting sample data wo/ missing key ");

%call_hash = (sid           => $sid,
  	      vid           => $vid,
	      filter        => "PASS",
	      score         => 1000,
              depth         => 101,
	      format_keys   => "GT:AD:DP:GQ:PL",
	      format_values => "0/1:39,32:71:99:650,0,804");


$svid = EASIH::VCFdb::insert_sample_data(\%call_hash);
ok( defined $new_vid, "Inserted sample data ");

my $fetched_svid = EASIH::VCFdb::fetch_sample_data($sid);
ok(! defined $fetched_svid, "fetched sample data wo/ parameter ");

$fetched_svid = EASIH::VCFdb::fetch_sample_data($sid, $vid);
is_deeply( \%call_hash, $fetched_svid, "Fetched sample data ");


%call_hash = ( gene           => "BRCA", 
  	       transcript     => "TRANS", 
	       effect         => "NONE", 
	       codon_pos      => undef,, 
	       AA_change      => "Ala > tyt", 
	       grantham_score => 339, 
	       pfam           => "DUF1234", 
	       PolyPhen       => "PP_score", 
	       SIFT           => "SIFTing", 
	       condel         => "condel_score", 
	       GERP           => 123);

my $aid = EASIH::VCFdb::insert_annotation(\%call_hash);
ok( ! defined $aid, "Failing inserting annotation  wo/ missing key ");

$call_hash{ vid } = $vid;
$aid = EASIH::VCFdb::insert_annotation(\%call_hash);
ok( defined $aid, "Inserting annotation ");

my $annot = EASIH::VCFdb::fetch_annotation($vid);
is_deeply(\%call_hash, $$annot[0], "Fetched annotation data");

# Delete the tmp database now when we are done with it.
END {
  EASIH::DB::drop_db($rand_dbname, $dbhost, "easih_admin", "easih");
}



