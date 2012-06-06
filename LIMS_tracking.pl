#!/usr/bin/perl 
# 
# 
# Kim Brugger (11 May 2012), contact: kim.brugger@easih.ac.uk



use strict;
use warnings;
use Data::Dumper;
use lib '/home/kb468/projects/conductor/modules';

use EASIH::LIMS;
use Time::Local;

my $to = 'kim.brugger@easih.ac.uk'; #global
my $mailcount; #global

my $run_name = shift;

my @orders = EASIH::LIMS::fetch_orders( );


foreach my $order (@orders ) {

#  next if ( $$order{'label'} eq 'Cancelled' ||
#	    $$order{'label'} eq 'Completed');


  next if ( $$order{'order_id'} != 42 );

  my ($order_status, $state_stamp) = EASIH::LIMS::order_status( $$order{'order_id'} );

  $order_status =~ s/\d+ - //;


  if (1) {

    print join("\t", 
	       $$order{'order_id'},
	       $$order{'order_name'},
	       $$order{'num_samples'},
	       $$order{'order_state'},
	       $order_status, $state_stamp, time2timestamp($state_stamp)) . "\n";

    print join("\t", EASIH::LIMS::samples_in_order($$order{'order_id'})) . "\n";
  }

#  next;

#  EASIH::LIMS::sample_statuses_from_order($$order{'order_id'});
  my $status = EASIH::LIMS::sample_statuses($$order{'order_id'}, $order_status );
  foreach my $sample ( keys %$status ) {
    if ( ref ($$status{$sample}) eq 'HASH' ) {
      foreach my $sample_status ( sort { $$status{$sample}{$a} cmp $$status{$sample}{$b}} keys %{$$status{$sample}} ) {
	print "$sample\t$sample_status\t$$status{$sample}{$sample_status}\t" . time2timestamp($$status{$sample}{$sample_status}) . "\n";
      }
    }
    else {
      print "$sample\t$$status{$sample}\t" .  time2timestamp($$status{$sample}) . "\n";
    }
  }
#  print Dumper();

#  last;
}

#print Dumper( \@orders );



# 
# 
# 
# Kim Brugger (06 Jun 2012)
sub time2timestamp {
  my  ($time) = @_;
  
  $time =~ /^(\d+)-(\d+)-(\d+) (\d+):(\d+):(\d+)(.*)/;
  my ($year, $month, $day, $hour, $min, $sec, $time_adj) = ($1, $2, $3, $4, $5, $6, $7);
  $hour = eval { $hour + $time_adj };
  
  use Time::Local;    
  my $stamp = timelocal($sec,$min,$hour,$day,$month,$year);

  return $stamp;
}
