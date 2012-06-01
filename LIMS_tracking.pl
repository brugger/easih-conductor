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

my @orders = EASIH::LIMS::fetch_orders( );


foreach my $order (@orders ) {

#  next if ( $$order{'label'} eq 'Cancelled' ||
#	    $$order{'label'} eq 'Completed');


#  next if ( $$order{'order_id'} != 42 );

  print Dumper( $order );
  next;

  if (0) {
    $$order{'label'} =~ s/\d+ - //;

    print join("\t", 
	       $$order{'order_id'},
	       $$order{'tracking_id'},
	       $$order{'order_name'},
	       $$order{'num_samples'},
	       $$order{'label'},
	       $$order{'description'},) . "\n";

    print join("\t", EASIH::LIMS::samples_in_order($$order{'order_id'})) . "\n";
  }

#  EASIH::LIMS::sample_statuses_from_order($$order{'order_id'});
  my $status = EASIH::LIMS::sample_statuses($$order{'order_id'}, $$order{'label'});
  foreach my $sample ( keys %$status ) {
    if ( ref ($$status{$sample}) eq 'HASH' ) {
      foreach my $sample_status ( sort { $$status{$sample}{$a} cmp $$status{$sample}{$b}} keys %{$$status{$sample}} ) {
	print "$sample\t$sample_status\t$$status{$sample}{$sample_status}\n";
      }
    }
    else {
      print "$sample\t$$status{$sample}\n";
    }
  }
  print Dumper();

}

#print Dumper( \@orders );
