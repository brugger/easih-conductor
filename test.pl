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
my $sid = EASIH::VCFdb::insert_sample($pid, "A470001");


print "$pid $sid\n";

while (<>) {

  next if (/^#/ || /^Pos/);

  chomp;

  my @fields = split("\t", $_);
  my ($chr, $change, $flags, $filter, $score, $depth, $genotype, $gene, $transcript, $effect, $codon_change, $AA_change, $grantham, $dbsnp, $dbsnp_flags, $HGMD, $pfam, $PolyPhen, $SIFT, $condel, $GERP) = @fields;
  ($chr, my $pos) = split(":", $chr);
  my ($ref, $alt) = split(">", $change);
  EASIH::VCFdb::insert_variation($chr, $pos, $ref, $alt);
#  EASIH::VCFdb::insert_variation($chr, $pos, $ref, $alt);

  
#  exit;
}
