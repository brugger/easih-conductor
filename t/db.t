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


use Test::Simple tests => 4;
use EASIH::DB;

my $dbi = EASIH::DB::connect("done", "mgpc17", "easih_admin", "easih");
ok( $dbi, 'Connect to exsisting database' );
my $sth = EASIH::DB::prepare($dbi, "select * from sample where name like ?");
ok($sth , 'Prepare a sql statement' );

my $array_hash = EASIH::DB::fetch_array_hash($dbi, $sth, 'A0%');
ok(ref($array_hash) eq "ARRAY" && ref($$array_hash[0]) eq "HASH" , 'fetch_array_hash returns correct types' );

my $array_array = EASIH::DB::fetch_array_array($dbi, $sth, 'A0%');
ok(ref($array_array) eq "ARRAY" && ref($$array_array[0]) eq "ARRAY" , 'fetch_array_array returns correct types' );

$dbi = EASIH::DB::connect("test", "mgpc17", "easih_admin", "easih");


__END__

my %insert_hash = (a => 100,
		   b => "Loooooooooooooooooooong Value 1",
		   c => "V2");

EASIH::DB::insert($dbi, "tyt", \%insert_hash);

$insert_hash{b} = "updated long value, it was to long"; 
EASIH::DB::update($dbi, "tyt", \%insert_hash, "a");

print "Did we get here?\n";

