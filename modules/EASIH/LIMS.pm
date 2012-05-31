package EASIH::LIMS;
# 
# 
# 
# 
# Kim Brugger (21 May 2012), contact: kim.brugger@easih.ac.uk

use strict;
use warnings;
use Data::Dumper;
use EASIH::Log;
use EASIH::DB;
use DBI;

my $dbh;

BEGIN { 
### Fetch Data from iondb (located on Ion torrent) ###
#my $dbh = DBI->connect("DBI:Pg:dbname=finch;host=mgeasihlims.medschl.cam.ac.uk", 'easih_ro') || die "Could not connect to database: $DBI::errstr";
#  $dbh = DBI->connect("DBI:Pg:dbname=finch;host=easihlims2.medschl.cam.ac.uk", 'easih_ro', '') || die "Could not connect to database: $DBI::errstr";
  $dbh = EASIH::DB::connect_psql('finch','easihlims2.medschl.cam.ac.uk', 'easih_ro');
  $dbh->do("SET search_path TO finch, public");
}


# 
# 
# 
# Kim Brugger (30 May 2012)
sub fetch_orders {
  
  my $q = 'select omo.order_id, tracking_id, order_name, ose.label, ost.label, ost.description, oos.num_samples from om_order_state ose, om_order_status ost, om_order_stats oos, om_order omo where ose.state_id = omo.state_id and ost.status_id = omo.status_id and oos.order_id = omo.order_id;';
  
  my @res = EASIH::DB::fetch_array_hash($dbh, $q);
  
  return @res;
}


# 
# 
# 
# Kim Brugger (31 May 2012)
sub sample_statuses_from_order {
  my ($order_id) = @_;

  my $q = qq{SELECT  name, workflow_label, status_label,  state_label, gt.template_id, wl.created_at FROM workflow_log wl, ga_template_workflow_log gtwl, ga_template gt WHERE wl.log_id = gtwl.log_id AND gt.template_id = gtwl.template_id AND wl.log_id IN (select log_id FROM ga_template_workflow_log gtwl, om_order_ga_template oogt WHERE gtwl.template_id = oogt.template_id AND oogt.order_id = ?)};

  my @db_res = EASIH::DB::fetch_array_hash($dbh, $q, $order_id);

  my %samples;
  foreach my $db_res ( @db_res ) {
    next if ( $$db_res{ state_label} ne "Ready");

    my @template_ids = template_id2sample_ids($$db_res{ 'template_id'});
    foreach my $template_id ( @template_ids ) {
      $samples{ sample_id2sample_name( $template_id ) }{ "$$db_res{ workflow_label}/$$db_res{ status_label}" } = $$db_res{ created_at };
    }
  }
 
  return \%samples;

}



# 
# 
# 
# Kim Brugger (31 May 2012)
sub sample_statuses {
  my ($order_id) = @_;
  my %samples_status;
  # unrecieved samples does not have any status, so just setting them for all samples from active orders.
  map { $samples_status{ $_ } = 'Waiting for sample'} EASIH::LIMS::samples_in_order( $order_id );
  my $sample_statuses = sample_statuses_from_order( $order_id );
  foreach my $sample ( keys %{$sample_statuses} ) {
    $samples_status{ $sample } = $$sample_statuses{ $sample };
  }
  
  return \%samples_status;
}



# 
# 
# 
# Kim Brugger (31 May 2012)
sub template_id2sample_ids {
  my ( $template_id ) = @_;

  my $q = 'select related_to from ga_template_hierarchy where template_id = ? and depth = (select max(depth) from ga_template_hierarchy where template_id = ?)';
  return EASIH::DB::fetch_array($dbh, $q, $template_id,$template_id);
}



# 
# 
# 
# Kim Brugger (31 May 2012)
sub samples_in_order {
  my ($order_id ) = @_;

  my $q = 'select sample_name, template_name from om_sample where order_id=?';
  my @db_res = EASIH::DB::fetch_array_array($dbh, $q, $order_id);
  
  my @res;
  foreach my $db ( @db_res ) {
    my ($sample_name, $temp_name ) = @$db;
    if ( $sample_name && $temp_name ) {
      print "Both a sample_name and temp_name for order_id: $order_id ($sample_name && $temp_name)\n";
    }
    push @res, $sample_name if ( $sample_name );
    push @res, $temp_name if ( $temp_name );
  }

  return @res if (wantarray);
  return \@res;
}



# 
# 
# 
# Kim Brugger (21 May 2012)
sub fetch_by_runname {
  my ( $run_name ) = @_;
  
  my $run_id = run_name2run_id( $run_name );
  die "unknown run-name: $run_name\n" if ( ! defined $run_id );
  
#print "$run_name --> $run_id\n";

  my @res;
  
  my %samples = fetch_lanes( $run_id );
#print Dumper( \%samples );
  foreach my $sample_id ( sort {$a <=> $b} keys %samples ) {
    
    my $lane = $samples{ $sample_id };
    
    my %mids  = get_mids($sample_id);
    
    foreach my $mid ( keys %mids ) {
      
      my $name = sample_id2sample_name($mid);
      
      push @res, [$lane, $name, $mids{$mid}];
    }
    
  }
  

  return @res if ( wantarray );
  return \@res;
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
SELECT name   FROM ga_template  WHERE template_id = ?};

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


1;
