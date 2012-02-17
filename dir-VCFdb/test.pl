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
  my ($chr, $change, $filter, $score, $depth, $genotype, $gene, $transcript, $effect, $codon_pos, $AA_change, $grantham_score, $dbsnp, $dbsnp_flags, $HGMD, $pfam, $PolyPhen, $SIFT, $condel, $GERP) = @fields;
  ($chr, my $pos) = split(":", $chr);
  my ($ref, $alt) = split(">", $change);
  my $vid = EASIH::VCFdb::insert_variation($chr, $pos, $ref, $alt);
#  EASIH::VCFdb::insert_variation($chr, $pos, $ref, $alt);

  print "filter => $filter, depth => $depth\n";
  
  my %call_hash = (sid    => $sid,
		   vid    => $vid,
		   filter => $filter,
		   score  => $score,
		   depth  => $depth,
		   allele_freq => $genotype eq "HOMO" ? 1:2 ,
		   allele_count => $genotype eq "HOMO" ? 1:2);

#  die Dumper( \%call_hash );

  EASIH::VCFdb::insert_sample_data(\%call_hash);

  %call_hash = ( vid            => $vid,
		 gene           => $gene, 
		 transcript     => $transcript, 
		 effect         => $effect, 
		 codon_pos      =>$codon_pos, 
		 AA_change      => $AA_change, 
		 grantham_score => $grantham_score, 
		 dbsnp          => $dbsnp, 
		 HGMD           => $HGMD, 
		 pfam           => $pfam, 
		 PolyPhen       => $PolyPhen, 
		 SIFT           => $SIFT, 
		 condel         => $condel, 
		 GERP           =>$GERP);

#  die Dumper( \%call_hash );

  EASIH::VCFdb::insert_annotation( \%call_hash );
}
