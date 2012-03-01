#!/usr/bin/perl 
# 
# 
# 
# 
# Kim Brugger (29 Feb 2012), contact: kim.brugger@easih.ac.uk

use strict;
use warnings;
use Data::Dumper;

use lib '/home/kb468/projects/conductor/modules';
use EASIH::Conductor;
use EASIH::Log;

#EASIH::Log::file('conductor.log');
EASIH::Log::write("Startup\n");
EASIH::Log::level("TRACE");
my $verbose = 2;

while( 1 ) {

  EASIH::Conductor::offload_illumina_runs();
  EASIH::Conductor::offload_torrent_runs();
  
  EASIH::Conductor::QC_files();
  EASIH::Conductor::pass_QCed_files();
  
  
  last;
  
}

EASIH::Log::write("Shutdown\n");
