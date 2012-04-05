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
use EASIH::Illumina::Summary;
use EASIH::Illumina::Sample_sheet;
use EASIH::Illumina::Config;
use EASIH::Log;

EASIH::Log::level("ALL");

my $DEVELOPMENT = 0;

my %opts;
getopts('i:r:d:o:', \%opts);

my $outdir = $opts{o} || '/data/';
my $indir  = $opts{i} || './/';

my $sample_sheet = $opts{'s'};
$sample_sheet = "$indir/sample_sheet.csv" if (!$sample_sheet && -e "$indir/sample_sheet.csv");
$sample_sheet = "$indir/Sample_sheet.csv" if (!$sample_sheet && -e "$indir/Sample_sheet.csv");
$sample_sheet = "$indir/sample_Sheet.csv" if (!$sample_sheet && -e "$indir/sample_Sheet.csv");
$sample_sheet = "$indir/Sample_Sheet.csv" if (!$sample_sheet && -e "$indir/Sample_Sheet.csv");
if (!$sample_sheet && -e "BaseCalls/sample_sheet.csv") {
  $indir = "BaseCalls";
  $sample_sheet = "$indir/sample_sheet.csv";
}
if (!$sample_sheet && -e "sample_sheet.csv") {
  $indir = "./";
  $sample_sheet = "sample_sheet.csv";
}

my ($res, $errors ) = EASIH::Illumina::Sample_sheet::readin( $sample_sheet );


print Dumper( $res );

#($res, my $removed_samples) = EASIH::Illumina::Sample_sheet::remove_easih_barcodes( $res );
#  $indexed_run = EASIH::Illumina::Sample_sheet::indexed_run( $res );  


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
