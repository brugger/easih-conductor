package EASIH::Conductor;
# 
# 
# 
# 
# Kim Brugger (13 Jun 2011), contact: kim.brugger@easih.ac.uk

use strict;
use warnings;
use Data::Dumper;

use EASIH::DB::Conductor;
use EASIH::Log;


# 
# 
# 
# Kim Brugger (01 Mar 2012)
sub offload_illumina_runs {
  EASIH::Log::write("Checking for finished illumina runs\n", "INFO");

  my @illumina_dirs  = ('/seqs/illumina2/', 
			'/seqs/illumina3/', 
			'/seqs/illumina4/');

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
      my $finished_run = 1 if (-e $RTAcomp && -e "$runfolder/Basecalling_Netcopy_complete.txt");
      $finished_run = `grep -c "Copying logs to network run folder" $eventfile` 
	  if (! $finished_run);
      chomp( $finished_run );
      next if ( !$finished_run);
      
      EASIH::Log::write("$runfolder contains a finished run, should offload it\n", "TRACE");
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
  my $q = 'select "fastqLink", "pgmName", "status", "chipType", "chipBarcode" from rundb_results results join rundb_experiment experiments on results.experiment_id = experiments.id where status = \'Completed\'';

  my $sth = $dbi->prepare( $q );
  $sth->execute();

  while (my @results = $sth->fetchrow_array()) {
    my ($fq_file, $pgmName, $status, $chipType, $chipBarcode ) = @results;
    EASIH::Log::write("mgion01:/results/analysis/$fq_file contains a '$status' run from a $chipType ($chipBarcode) on machine $pgmName, should offload it\n", "TRACE");
  }
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
