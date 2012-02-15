package EASIH::VCFdb;
# 
# 
# 
# 
# Kim Brugger (13 Jun 2011), contact: kim.brugger@easih.ac.uk

use strict;
use warnings;
use Data::Dumper;

use Time::HiRes;
use EASIH::DB;

my $dbi;

# 
# 
# 
# Kim Brugger (12 May 2011)b
sub connect {
  my ($dbname, $dbhost, $db_user, $db_pass) = @_;
  $dbhost  ||= "mgpc17";
  $db_user ||= 'easih_ro';

  $dbi = EASIH::DB::connect($dbname,$dbhost, $db_user, $db_pass);
  return $dbi;
}


# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub fetch_project_id {
  my ( $name ) = @_;
  my $q    = "SELECT pid FROM project where name = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);
  my @line = EASIH::DB::fetch_array( $dbi, $sth, $name );
  return $line[0] || undef;
}


# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub fetch_project_name {
  my ( $sid ) = @_;
  my $q    = "SELECT name FROM project where pid = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);
  my @line = EASIH::DB::fetch_array( $dbi, $sth, $sid );
  return $line[0] || undef;
}


# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub insert_project {
  my ($name) = @_;

  my $pid = fetch_project_id($name);
  return $pid if ($pid);

  return (EASIH::DB::insert($dbi, "project", {name => $name}));
}


# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub update_project {
  my ($pid, $name) = @_;

  my %call_hash;
  $call_hash{pid}    = $pid  if ($pid);
  $call_hash{name}   = $name if ($name);

  return (EASIH::DB::update($dbi, "project", \%call_hash, "pid"));
}


# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub fetch_sample_id {
  my ( $name ) = @_;
  my $q    = "SELECT sid FROM sample WHERE name = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);
  my @line = EASIH::DB::fetch_array( $dbi, $sth, $name );
  return $line[0] || undef;
}


# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub fetch_sample_name {
  my ( $sid ) = @_;
  my $q    = "SELECT name FROM sample WHERE sid = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);
  my @line = EASIH::DB::fetch_array( $dbi, $sth, $sid );
  return $line[0] || undef;
}


# 
# Should validate that the sample_id (sid) matches the project_id (pid)
# 
# Kim Brugger (07 Feb 2012)
sub insert_sample {
  my ($pid, $name) = @_;

  my $sid = fetch_sample_id($name);
  return $sid if ( $sid );

  my %call_hash = ( pid => $pid,
		    name => $name);

  return (EASIH::DB::insert($dbi, "sample", \%call_hash));
}

# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub update_sample {
  my ($sid, $name) = @_;

  my %call_hash;
  $call_hash{sid}    = $sid  if ($sid);
  $call_hash{name}   = $name if ($name);

  return (EASIH::DB::update($dbi, "sample", \%call_hash, "sid"));
}


# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub fetch_analysis_by_ref_pipeline {
  my ( $ref, $pipeline ) = @_;
  my $q    = "SELECT * FROM analysis where ref = ? AND pipeline = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);
  return ( EASIH::DB::fetch_array( $dbi, $sth, $ref, $pipeline ) );
}


# 
# Should validate if an entry already exists.
# 
# Kim Brugger (07 Feb 2012)
sub insert_analysis {
  my ($ref, $pipeline) = @_;

  my @vars = fetch_analysis_by_ref_pipeline($chr, $pos);
  return $vars[0] if ( @vars );

  my %call_hash = ( ref      => $ref,
		    pipeline => $pipeline);

  return (EASIH::DB::insert($dbi, "analysis", \%call_hash));
}

# 
# Should validate if an entry already exists.
# 
# Kim Brugger (07 Feb 2012)
sub update_variation {
  my ($aid, $ref, $pipeline) = @_;

  my %call_hash;
  $call_hash{aid}      = $aid if ($aid);
  $call_hash{ref}      = $chr if ($ref);
  $call_hash{pipeline} = $chr if ($pipeline);

  return (EASIH::DB::update($dbi, "analysis", \%call_hash, "aid"));
}




# 
# Should validate if an entry already exists.
# 
# Kim Brugger (07 Feb 2012)
sub insert_status {
  my ($pid, $status) = @_;


  my $timestamp = Time::HiRes::gettimeofday()*100000;

  my %call_hash = ( pid    => $pid,
		    status => $status,
		    stamp  => $timestamp);

  return (EASIH::DB::insert($dbi, "status", \%call_hash));
}


1;



