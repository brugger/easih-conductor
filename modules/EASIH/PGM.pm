package EASIH::PGM;
# 
# Doing the dirty with the PGM-server database
# 
# 
# Kim Brugger (28 May 2012), contact: kim.brugger@easih.ac.uk

use strict;
use warnings;
use Data::Dumper;
use EASIH::Log;
use DBI;

my $dbh;

BEGIN { 
### Fetch Data from iondb (located on Ion torrent) ###
#my $dbh = DBI->connect("DBI:Pg:dbname=finch;host=mgeasihlims.medschl.cam.ac.uk", 'easih_ro') || die "Could not connect to database: $DBI::errstr";

  $dbh = DBI->connect("DBI:Pg:dbname=iondb;host=mgion01.medschl.cam.ac.uk", 'ion') || die "Could not connect to database: $DBI::errstr";
}





# 
# Translate a run_name into the internal run_id
# 
# Kim Brugger (11 May 2012)
sub run_name2run_id {
  my ($run_name) = @_;

  my $q = 'select id from rundb_experiment where "chipBarcode" = ?';
  my $sth = $dbh->prepare( $q);
  $sth->execute( $run_name );
  
  my ($id ) = $sth->fetchrow_array();
  $id ||= undef;
  return $id;
}


# 
# 
# 
# Kim Brugger (28 May 2012)
sub run_info {
  my ($run_id ) = @_;


  my $q = 'select experiments.id, "fastqLink", "pgmName", "status", "chipType", "chipBarcode" ';
  $q .= "from rundb_results results join rundb_experiment experiments on results.experiment_id = experiments.id where status = 'Completed' and experiments.id=?";
  my $sth = $dbh->prepare( $q );
  $sth->execute( $run_id );
  
  my ($id, $fq_file, $pgmName, $status, $chipType, $chipBarcode ) = $sth->fetchrow_array();

  if ( ! $id ) {
    print STDERR "Unknown run id '$run_id' on mgion01\n";
    exit -1;
  }

  return ($fq_file, $pgmName, $status, $chipType, $chipBarcode );
}



# 
# 
# 
# Kim Brugger (28 May 2012)
sub demultiplex_run {
  my($fq_file, $sample_sheet_hash) = @_;

  my %bcodes;
  my %fhs;
  my $barcode_length = 0;
  foreach my $lane ( keys %$sample_sheet_hash ) {
    
    foreach my $bcode ( keys %{$$sample_sheet_hash{$lane}} ) {
      $barcode_length = length( $bcode)    
	  if ( !$barcode_length);
      my $base_filename = $$sample_sheet_hash{$lane}{$bcode};
      my $fh;
      open ($fh, "| gzip -c > $base_filename.fq.gz") || die"Could not open '$base_filename': $!\n";
      $fhs{ "$base_filename" }  = $fh;
      $bcodes{$bcode} = "$base_filename";
    }
  }

  my %counts = ();

  open (my $fqs, $fq_file) || die "Could not open '$fq_file': $!\n";
  while(<$fqs>) {
    my $header     = $_;
    my $sequence   = <$fqs>;
    my $strand     = <$fqs>;
    my $quality    = <$fqs>;
    
    my ($bcode) = ($sequence =~ /^(.{$barcode_length})/);
    if (! $bcode || ! $bcodes{$bcode}) {
      $counts{'1'}{'Non_matched'}++;
      next;
    }
      $counts{'1'}{$bcode}++;
    my $fout = $fhs{$bcodes{$bcode}};
    print $fout "$header$sequence$strand$quality";
  }

  my $xml_report = '<?xml version="1.0" encoding="ISO-8859-1"?>'."\n<Samples>\n";
  foreach my $lane ( keys %$sample_sheet_hash ) {
    $xml_report .= "    <Lane_$lane>\n";
    foreach my $bcode ( keys %{$$sample_sheet_hash{$lane}} ) {    
      $$sample_sheet_hash{$lane}{$bcode} =~ s/.*\///;
      $xml_report .= "        <$$sample_sheet_hash{$lane}{$bcode}>\n";
      $xml_report .= "            <Barcode_Sequence>$bcode</Barcode_Sequence>\n";
      $xml_report .= "            <Read_Count>$counts{1}{$bcode}</Read_Count>\n";
      $xml_report .= "        </$$sample_sheet_hash{$lane}{$bcode}>\n";
    }
    $xml_report .= "    /<Lane_$lane>\n";
  }
  $xml_report .= "</Samples>\n";
  

  return $xml_report;
}



1;
