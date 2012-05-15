#!/usr/bin/perl 
# 
# 
# Kim Brugger (11 May 2012), contact: kim.brugger@easih.ac.uk



use strict;
use warnings;
use Data::Dumper;
use DBI;

my $res_folder = "/results/analysis/";
my $CurrentRunDir; # Global ### svvd 
my $to = 'kim.brugger@easih.ac.uk'; #global
my $mailcount; #global

my $run_name = shift;


### Fetch Data from iondb (located on Ion torrent) ###
#my $dbh = DBI->connect("DBI:Pg:dbname=finch;host=mgeasihlims.medschl.cam.ac.uk", 'easih_ro') || die "Could not connect to database: $DBI::errstr";
my $dbh = DBI->connect("DBI:Pg:dbname=finch;host=easihlims2.medschl.cam.ac.uk", 'easih_ro') || die "Could not connect to database: $DBI::errstr";
$dbh->do("SET search_path TO finch, public");

my $run_id = run_name2run_id( $run_name );
die "unknown run-name: $run_name\n" if ( ! defined $run_id );

#print "$run_name --> $run_id\n";

my %samples = fetch_lanes( $run_id );
#print Dumper( \%samples );

foreach my $sample_id ( sort {$a <=> $b} keys %samples ) {

  my $lane = $samples{ $sample_id };
  
  my %mids  = get_mids($sample_id);

  foreach my $mid ( keys %mids ) {

    my $name = sample_id2sample_name($mid);

    print "$lane, $name, $mids{$mid}\n";
  }

}


# 
# Translate a run_name into the internal run_id
# 
# Kim Brugger (11 May 2012)
sub run_name2run_id {
  my ($run_name) = @_;

  my $q = "SELECT run_id FROM ga_instrument_run WHERE name = ?";

  my $sth = $dbh->prepare( $q ) or die $dbh->errstr;

  $sth->execute( $run_name ) or die $dbh->errstr;

  if ($sth->rows == 0) {
    return undef;
  }

  my @row = $sth->fetchrow_array;

  $sth->finish;

  return $row[0];

}


sub fetch_lanes {

  my $run_id = shift;

  my $query = qq{
SELECT template_id, position
  FROM ga_instrument_run_template
 WHERE run_id = ?};

  my $sth = $dbh->prepare($query)
    or die $dbh->errstr;

  $sth->execute($run_id)
    or die $dbh->errstr;

  if ($sth->rows == 0) {
    die "No templates for run '$run_id'\n";
  }

  my %template2lane;

  while (my @row = $sth->fetchrow_array) {
    $template2lane{$row[0]} = $row[1];
  }

  $sth->finish;

  return %template2lane;
}


sub get_mids {

  my $template_id = shift;

  my $query = qq{
SELECT gt.template_id, gp.bases
  FROM ga_template gt,
       ga_primer gp
 WHERE gt.mid = gp.primer_id
   AND gt.template_id IN (SELECT related_to
                            FROM ga_template_hierarchy gth
                           WHERE template_id = ?)};

  my $sth = $dbh->prepare($query)
    or die $dbh->errstr;

  $sth->execute($template_id)
    or die $dbh->errstr;

  my $indexed_template_id = '';
  my $bases = '';

  if ($sth->rows == 0) {
    #warn "No templates with MIDs for template '$template_id'\n";
    return $template_id, $bases;
  }

  my %res;

  while (my @row = $sth->fetchrow_array) {

    $res{ $row[0] } = $row[1];
  }

  $sth->finish;

  return %res;

}


sub sample_id2sample_name {

  my $template_id = shift;

  my $query = qq{
SELECT name
  FROM ga_template
 WHERE template_id = ?};

  my $sth = $dbh->prepare($query)
    or die $dbh->errstr;

  $sth->execute($template_id)
    or die $dbh->errstr;

  if ($sth->rows == 0) {
    warn "No templates with template_id '$template_id'\n";
    return 0;
  }

  my @row = $sth->fetchrow_array;

  $sth->finish;

  return $row[0];

}
