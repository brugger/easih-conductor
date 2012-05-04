#!/usr/bin/perl 
# 
# 
# 
# 
# Kim Brugger (03 May 2012), contact: kim.brugger@easih.ac.uk

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
use EASIH::DB;
use EASIH::DB::Conductor;

my $dbhost = 'localhost';
my $dbname = "conductor";
my $dbi = EASIH::DB::Conductor::connect($dbname, $dbhost, "easih_admin", "easih");


while(<>) {
  chomp;

  my $mid;

  if (/SOLEXA1/) {
    $mid = EASIH::DB::Conductor::insert_sequencer('ILLUMINA1', 'Illumina GaIIx');
  }
  elsif (/SOLEXA2/) {
    $mid = EASIH::DB::Conductor::insert_sequencer('ILLUMINA2', 'Illumina GaIIx');
  }
  elsif (/IL39/ || /HWI/) {
    $mid = EASIH::DB::Conductor::insert_sequencer('ILLUMINA3', 'Illumina GaIIx');
  }
  elsif ( /^\d+_(.*?)_.*/) {
    my $sequencer = $1;
    $sequencer =~ s/^MG//;
    $mid = EASIH::DB::Conductor::insert_sequencer($sequencer, 'Illumina GaIIx');
  }
  elsif ( /^(.*?)_.*/) {
    my $sequencer = $1;
    $sequencer =~ s/^MG//;
    $mid = EASIH::DB::Conductor::insert_sequencer($sequencer, 'Illumina GaIIx');
  }
  else {
    $mid = EASIH::DB::Conductor::insert_sequencer($_, 'Illumina GaIIx');
  }

  print "$mid, $_\n";
  my $pid = EASIH::DB::Conductor::insert_run($mid, $_);
}
