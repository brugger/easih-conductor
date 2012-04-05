#!/usr/bin/perl 
# 
# mgion01
# sudo apg-get install  libdbd-pg-perl libdbi-perl libnet-daemon-perl libplrpc-perl
#
# mgpc17
# sudo apt-get install postgresql-client-8.4 postgresql-client-common libdbd-pg-perl
# 
# Kim Brugger (02 Mar 2012), contact: kim.brugger@easih.ac.uk


use strict;
use warnings;
use Data::Dumper;
use Getopt::Std;

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

use DBI;
use File::Temp;

use lib '/home/kb468/easih-toolbox/modules/';
use lib '/home/kb468/projects/conductor/modules/';
use EASIH;
use EASIH::Sample;
use EASIH::Log;

EASIH::Log::level("ALL");

my $DEVELOPMENT = 0;

my %opts;
getopts('r:d:o:', \%opts);

my $res_folder = "/results/analysis/";
my $outdir = $opts{o} || '/data/';
my $run_id = $opts{r} || Usage();
$run_id = 50 if ($DEVELOPMENT);

my ($fq_file, $pgmName, $status, $chipType, $chipBarcode ) =  fetch_db_info( $run_id );

EASIH::Log::write("mgion01:/results/analysis/$fq_file contains a '$status' run from a $chipType ($chipBarcode) on machine $pgmName, should offload it\n", "TRACE");

my $tmp_dir = make_tmp_dir("/tmp");
$tmp_dir = "/scratch/kb468/IT/" if ($DEVELOPMENT);
EASIH::Log::write("Will offload the data to: $tmp_dir\n", "TRACE");

my ($local_fq_file, $local_version) = offload_data($tmp_dir, $fq_file);

print "localfiles: $local_fq_file, $local_version\n";



# 
# 
# 
# Kim Brugger (02 Mar 2012)
sub offload_data {
  my ($tmp_dir, $fq_file) = @_;

  return ("/scratch/kb468/IT/R_2012_02_14_15_24_05_user_z07-10-13-14.02.12_Auto_z07-10-13-14.02.12_50.fastq",
	  "/scratch/kb468/IT/version.txt") if ($DEVELOPMENT);


# extracting the information we need for moving off the data.
  my $res_dir = $fq_file;
  $res_dir =~ s/(.*\/).*/$res_folder$1/;
  my $run_folder = $res_dir;
  $run_folder =~ s/.*\/(.*)\//$1/;

  $fq_file =~ s/.*\/(.*)/$1/;

  print "$fq_file\n";
  print "$res_dir\n";
  print "$run_folder\n";
  
  system "scp -C ionadmin\@mgion01:$res_dir/$fq_file $tmp_dir/";
  system "scp -C ionadmin\@mgion01:$res_dir/version.txt $tmp_dir/";

  return ("$tmp_dir/$fq_file", "$tmp_dir/version.txt");
}


# 
# 
# 
# Kim Brugger (02 Mar 2012)
sub make_tmp_dir {
  my ($basedir) = @_;
  $basedir ||= "/tmp";

  system "mkdir -p $basedir" if ( ! -d "$basedir");

  my ($tmp_fh, $tmp_file) = File::Temp::tempfile(DIR => $basedir );
  close ($tmp_fh);
  system "rm -f $tmp_file";
  system "mkdir $tmp_file";
  return $tmp_file;
}




# 
# 
# 
# Kim Brugger (02 Mar 2012)
sub fetch_db_info {
  my ($run_id) = @_;

### Fetch Data from iondb (located on Ion torrent) ###
  my $dbi = DBI->connect("DBI:Pg:dbname=iondb;host=mgion01.medschl.cam.ac.uk", 'ion') || die "Could not connect to database: $DBI::errstr";
  my $q = 'select experiments.id, "fastqLink", "pgmName", "status", "chipType", "chipBarcode" ';
  $q .= "from rundb_results results join rundb_experiment experiments on results.experiment_id = experiments.id where status = 'Completed' and experiments.id='$run_id'";
  my $sth = $dbi->prepare( $q );
  $sth->execute();
  
  my ($id, $fq_file, $pgmName, $status, $chipType, $chipBarcode ) = $sth->fetchrow_array();

  if ( ! $id ) {
    print STDERR "Unknown run id '$run_id' on mgion01\n";
    exit -1;
  }

  return ($fq_file, $pgmName, $status, $chipType, $chipBarcode );
}

# 
# 
# 
# Kim Brugger (02 Mar 2012)
sub Usage {
  $0 =~ s/.*\///;
  print STDERR "USAGE: $0 offloads an Ion Torrent run to the local disk.\n";
  print STDERR "USAGE: $0 -r<un id> -o[ut dir, default /data/] -h[elp, this]\n";
  exit -1;
}
