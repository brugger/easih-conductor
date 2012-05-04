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

my $var = shift;


if ( $var =~ /^\w\d{2}\z/) {
  my $pid = EASIH::DB::Conductor::fetch_project_id( $var);

  if ($pid ) {
    my $fetched_hash = EASIH::DB::Conductor::fetch_project_hash( $pid );
    print "$$fetched_hash{name}, $$fetched_hash{notes} :: contact(s) $$fetched_hash{contacts} :: organism $$fetched_hash{organism}\n";
  }
  else {
    print "Unknown project: $var\n";
  }
}

my @results = EASIH::DB::Conductor::seach_project($var);

foreach my $fetched_hash ( @results ) {
  print "$$fetched_hash{name}, $$fetched_hash{notes} :: contact(s) $$fetched_hash{contacts} :: organism $$fetched_hash{organism}\n";
}
