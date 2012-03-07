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

use EASIH::Trace;

use Test::Simple tests => 4;
test_full_trace_call();

# 
# 
# 
# Kim Brugger (07 Mar 2012)
sub test_full_trace_call {

  my $res = EASIH::Trace::Package();
  ok( $res eq "main", 'returned the right package');

  $res = EASIH::Trace::File();
  ok( $res eq "t/trace.t", 'returned the right file');

  $res = EASIH::Trace::Line();
  ok( $res == __LINE__-1, 'returned the right line');

  $res = EASIH::Trace::Function();
  ok( $res eq "main::test_full_trace_call", 'returned the right function');

  
}
