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
use EASIH::CRR;

use Test::More tests => 12;

ok(EASIH::CRR::is_integer("tyt") == 0, 'Tested is_integer with a string');
ok(EASIH::CRR::is_integer(2.2) == 0, 'Tested is_integer with a float');
ok(EASIH::CRR::is_integer(5) == 1, 'Tested is_integer with an integer');

ok(EASIH::CRR::tasks(5) == 5, 'Created a 5 tasks process');
ok(EASIH::CRR::ok(1), "Created a finished task, not specified jobs");
ok(EASIH::CRR::ok(2, 2), "Created a finished task, with 2 job");
ok(EASIH::CRR::running(2, 3), "Created a running task, 3 jobs");
ok(EASIH::CRR::waiting(3, 4), "Created a waiting task, 4 jobs");


my $exp_report = "1..5
1\tok
2\tok\t2
2\trunning\t3
3\twaiting\t4
4\twaiting
5\twaiting\n";

my $report =  EASIH::CRR::report();
ok($report eq $exp_report, 'expected report is identical to generated report');

#print $report;

my %old_hash = EASIH::CRR::_statuses();
EASIH::CRR::parse($exp_report);
my %new_hash = EASIH::CRR::_statuses();

is_deeply(\%new_hash, \%old_hash, "Parsing of a CRR report");
ok(EASIH::CRR::failed(2, 1), "Created a failed task, 1 job");
$report =  EASIH::CRR::report();
$exp_report = "1..5
1\tok
2\tfailed
";

ok($report eq $exp_report, 'expected failed run report is identical to generated report');

