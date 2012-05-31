#!/usr/bin/perl 
# 
# 
# Kim Brugger (11 May 2012), contact: kim.brugger@easih.ac.uk



use strict;
use warnings;
use Data::Dumper;
use lib '/home/kb468/projects/conductor/modules';

use EASIH::LIMS;

my $to = 'kim.brugger@easih.ac.uk'; #global
my $mailcount; #global

my $run_name = shift;

my @sample_sheet = EASIH::LIMS::fetch_by_runname( $run_name );

foreach my $sample ( @sample_sheet) {
  print join(",", @$sample) . "\n";
}
