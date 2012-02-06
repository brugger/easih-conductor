package EASIH;
# 
# General catch all and configuration wrapper module for all EASIH scripts.
# 
# 
# Kim Brugger (13 Jun 2011), contact: kim.brugger@easih.ac.uk

use strict;
use warnings;
use Data::Dumper;

# Gives an error if it is not the master branch + gives access to version information.
use EASIH::Git;

use EASIH::DB;

my $dbi;

# 
# 
# 
# Kim Brugger (12 May 2011)
sub connect {
  my ($dbname, $dbhost) = @_;
  $dbname ||= "VCFdb_dev";
  $dbhost ||= "mgpc17";

  $dbi = DBI->connect("DBI:mysql:$dbname:$dbhost", 'easih_ro') || die "Could not connect to database: $DBI::errstr";

}







1;



