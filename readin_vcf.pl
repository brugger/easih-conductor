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

use EASIH::VCFdb;

EASIH::VCFdb::connect("VCFdb_dev", "mgpc17", "easih_admin", "easih");
my $pid = EASIH::VCFdb::insert_project("A47");
my $sid;

my $header = "";

while (<>) {

  if ( /#/ ) {
    next if (!/##fileformat/ && !/##FILTER/ && !/##FORMAT/);
    next if (/##contig/);
    $header .= $_;
    next;
  }
  elsif ( $header ) {
    print "$header";
#    exit;
    $sid = EASIH::VCFdb::insert_sample($pid, "A470001", $header);
    $header = undef;
  }

#  print "$pid $sid\n";

  my @fields = split("\t", $_);
  my ($chr, $pos, $id, $ref, $alt, $score, $filter, $info, $format, $format_values) = @fields;

  my $vid = EASIH::VCFdb::insert_variation($chr, $pos, $ref, $alt);
  
  my %call_hash = (sid           => $sid,
		   vid           => $vid,
		   filter        => $filter,
		   score         => $score,
		   format_keys   => $format,
		   format_values => $format_values);

#  die Dumper( \%call_hash );

  EASIH::VCFdb::insert_sample_data(\%call_hash);
}
