package EASIH::Conductor;
# 
# 
# 
# 
# Kim Brugger (13 Jun 2011), contact: kim.brugger@easih.ac.uk

use strict;
use warnings;
use Data::Dumper;
use File::stat;

use EASIH::DB::Conductor;
use EASIH::Log;

BEGIN {
  my $dbhost = 'localhost';
  my $dbname = "conductor";
  my $dbi = EASIH::DB::Conductor::connect($dbname, $dbhost, "easih_admin", "easih");
}


# 
# 
# 
# Kim Brugger (01 Mar 2012)
sub offload_illumina_runs {
  EASIH::Log::write("Checking for finished illumina runs\n", "INFO");

  my @illumina_dirs  = ('/seqs/illumina2/', 
			'/seqs/illumina3/', 
			'/seqs/illumina4/', 
			'/seqs/illumina5/');

  foreach my $illumina_dir ( @illumina_dirs ) {
    opendir(DIR, "$illumina_dir");
    my @run_dirs = sort readdir(DIR);
    closedir(DIR);
 
    while( my $run_dir = shift @run_dirs) {

      my $runfolder   = "$illumina_dir/$run_dir";
      my $eventfile   = "$runfolder/Events.log"; 
      my $RTAcomp     = "$runfolder/RTAComplete.txt";
      my $Intensities = "$runfolder/Data/Intensities"; 
      my $Basecalls   = "$runfolder/Data/Intensities/BaseCalls"; 

      # not a direcotory
      next if ( ! -d "$runfolder" );
      next if ( ! -d "$Basecalls" );
    
      next if( !-e $eventfile && !-e $RTAcomp && !-e "$runfolder/Basecalling_Netcopy_complete.txt");
      my $finished_run = 0;
      $finished_run = 1 if (-e $RTAcomp && -e "$runfolder/Basecalling_Netcopy_complete.txt");
      $finished_run = `grep -c "Copying logs to network run folder" $eventfile` 
	  if (! $finished_run && -e $eventfile);
      chomp( $finished_run );
      next if ( !$finished_run);
      

      my $rid = EASIH::DB::Conductor::fetch_run_id( $run_dir );
      if ( ! $rid ) {
	print "Unknown run: $run_dir\n";
	next;
      }
      
      my @statuses = EASIH::DB::Conductor::fetch_run_statuses($rid);
      my $tagged_as_finished = 0;
      foreach my $status ( @statuses) {

	if ( $$status[1] eq "FINISHED") {
	  $tagged_as_finished = 1;
	}
      }

      next if ($tagged_as_finished);


      EASIH::Log::write("$runfolder contains a finished run, should offload it\n", "TRACE");

      my $filename = $eventfile if ( -e $eventfile );
      $filename = $RTAcomp if ( -e $RTAcomp );
      my $sb = stat($filename);
      # use the timestamp of filename to determine a more fine grained  finishing time. Could just use a time() call.
      EASIH::DB::Conductor::insert_run_status($rid, "FINISHED", EASIH::DB::time2highres_timestamp($sb->ctime)+30);

    }
  }
}


# 
# 
# 
# Kim Brugger (01 Mar 2012)
sub offload_torrent_runs {
  EASIH::Log::write("Checking for finished torrent runs\n", "INFO");

  ### Fetch Data from iondb (located on Ion torrent) ###
  my $dbi = DBI->connect("DBI:Pg:dbname=iondb;host=mgion01.medschl.cam.ac.uk", 'ion') || die "Could not connect to database: $DBI::errstr";
  my $q = 'select experiments.id, "fastqLink", "pgmName", "status", "chipType", "chipBarcode" from rundb_results results join rundb_experiment experiments on results.experiment_id = experiments.id where status = \'Completed\' order by experiments.id';

  my $sth = $dbi->prepare( $q );
  $sth->execute();

  while (my @results = $sth->fetchrow_array()) {
    my ($id, $fq_file, $pgmName, $status, $chipType, $chipBarcode ) = @results;

    my $rid = EASIH::DB::Conductor::fetch_run_id( $chipBarcode );

    if ( ! $rid ) {
      my $mid = EASIH::DB::Conductor::fetch_sequencer_id( $pgmName );
      $rid = EASIH::DB::Conductor::insert_run( $mid, $chipBarcode );
    }

    my @statuses = EASIH::DB::Conductor::fetch_run_statuses($rid);
    my $tagged_as_finished = 0;
    foreach my $status ( @statuses) {
      
      if ( $$status[1] eq "FINISHED") {
	$tagged_as_finished = 1;
      }
    }
    
    next if ($tagged_as_finished);
    
    EASIH::Log::write("$id/$chipBarcode/$fq_file contains a '$status' run a $chipType () from $pgmName, should offload it\n", "TRACE");

    next if ( $chipBarcode ne "aa0089122");
    print "Fetching sample sheet for runid: $chipBarcode/aa0089122\n";
    
    # use the timestamp of filename to determine a more fine grained  finishing time. Could just use a time() call.
    EASIH::DB::Conductor::insert_run_status($rid, "FINISHED", EASIH::DB::highres_timestamp());
    
    my $sample_sheet = fetch_and_store_sample_sheet($rid, $chipBarcode );

    system "./runners/offload_torrent.pl -d -s $sample_sheet -r $chipBarcode";

  }
}


# 
# 
# 
# Kim Brugger (21 May 2012)
sub fetch_and_store_sample_sheet {
  my ($rid, $run_name ) = @_;

  use EASIH::LIMS;
  use EASIH::Sample;

  my $ss_fn = "/scratch/kb468/sample_sheet.$run_name.csv";
  open(my $ss_fh, "> $ss_fn") || die "Could not open file: $!\n";
  print $ss_fh join("\t", "Lane", "Name", "Barcode") . "\n";

  my @lims_sample_sheet = EASIH::LIMS::fetch_by_runname( $run_name );
  my @conductor_sample_sheet = EASIH::DB::Conductor::fetch_sample_sheet_hash( $rid );
  my %conductor_sample_sheet;
  if ( @conductor_sample_sheet ) {
    EASIH::Log::write( "Sample sheet already exists for '$rid'\n", "WARN");
    foreach my $entry ( @conductor_sample_sheet ) {
      $conductor_sample_sheet{ $$entry{ lane }}{ $$entry{ sample_name }} = $$entry{ barcode     };
      $conductor_sample_sheet{ $$entry{ lane }}{ $$entry{ barcode     }} = $$entry{ sample_name };
    }
  }

  foreach my $entry ( @lims_sample_sheet ) {
    my ($lane, $sample, $mid) = @$entry;

    if (@conductor_sample_sheet) {
      if ( $conductor_sample_sheet{ $lane }{ $sample } eq $mid ) {
	next;
      }
      else {
	EASIH::Log::write( "conductor and LIMS samplesheet disagree for rid:$rid, lane:$lane, sample:$sample disagree. conductor mid: $conductor_sample_sheet{ $lane }{ $sample }, lims mid: $mid\nThis needs to be manually resolved!! \n", "ERROR");
	next;
      }
    }
    
    if (! EASIH::Sample::validate_sample($sample)) {
      EASIH::Log::write("invalid sample name '$sample' in LIMS for run: $run_name\n", "ERROR");
      next;
    }

    my $project = EASIH::Sample::extract_project( $sample );
    my $pid = EASIH::DB::Conductor::fetch_project_id( $project );

    # This should not happen, but there is no reason to kill off a sample sheet offloading by this. Should probably send some email around to notify people of this!
    $pid = EASIH::DB::Conductor::insert_project( $project ) 
	if ( ! $project );

    my $sid = EASIH::DB::Conductor::insert_sample( $pid, $sample );

    my $base_filename = $sample;

    # check to see if files has already been created for this sample; If it has create a sample_name, with the next _version
    my @file_entries = EASIH::DB::Conductor::fetch_files_from_sample( $sid );
    if ( @file_entries ) {
      my @files;
      foreach my $file_entry ( @file_entries ) {
	push @files, $$file_entry{name};
      }
      $base_filename = EASIH::Sample::next_sample_name($sample, \@files);
    }

    ($base_filename, my $error) = EASIH::Sample::sample2outfilename( $base_filename);
    
    if ( $error ) {
      EASIH::Log::write("Sample name creation error: $error\n", "ERROR");
      next;
    }
      
    my $fid = EASIH::DB::Conductor::insert_file($sid, $rid, $base_filename);

    EASIH::DB::Conductor::insert_sample_sheet_line($rid, $lane, $sample, $mid, $fid);
    print $ss_fh join("\t", $lane, $base_filename, $mid) . "\n";
  }
  close ( $ss_fh );
  
  return( $ss_fn );
}



# 
# 
# 
# Kim Brugger (01 Mar 2012)
sub QC_files {
  EASIH::Log::write("Checking for files to QC\n", "INFO");
  
  
}




# 
# 
# 
# Kim Brugger (01 Mar 2012)
sub pass_QCed_files {
  EASIH::Log::write("Checking for files to pass or fail on QC\n", "INFO");
  
}





1;
