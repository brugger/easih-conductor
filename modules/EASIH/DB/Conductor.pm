package EASIH::DB::Conductor;
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

  my $sample_name = fetch_project_name($pid);
  
  if (! $sample_name ) {
    print STDERR "Unknown pid: $pid\n";
    return undef;
  }

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
sub fetch_analysis_id {
  my ( $reference, $pipeline ) = @_;
  my $q    = "SELECT aid FROM analysis where reference = ? AND pipeline = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);
  my @line = EASIH::DB::fetch_array( $dbi, $sth, $reference, $pipeline );
  return $line[0] || undef;
}


# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub fetch_analysis {
  my ( $aid ) = @_;
  my $q    = "SELECT * FROM analysis where aid = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);
  return ( EASIH::DB::fetch_hash( $dbi, $sth, $aid ) );
}


# 
# Should validate if an entry already exists.
# 
# Kim Brugger (07 Feb 2012)
sub insert_analysis {
  my ($reference, $pipeline) = @_;

  my @vars = fetch_analysis_id($reference, $pipeline);
  return $vars[0] if ( @vars && $vars[0]);

  my %call_hash = ( reference  => $reference,
		    pipeline   => $pipeline);

  return (EASIH::DB::insert($dbi, "analysis", \%call_hash));
}


# 
# Should validate if an entry already exists.
# 
# Kim Brugger (07 Feb 2012)
sub insert_status {
  my ($sid, $status) = @_;

  my $sample_name = fetch_sample_name($sid);
  
  if (! $sample_name ) {
    print STDERR "Unknown sid: $sid\n";
    return undef;
  }


  my $stamp = Time::HiRes::gettimeofday()*100000;

  my %call_hash = ( sid    => $sid,
		    status => $status,
		    stamp  => $stamp);

  return (EASIH::DB::insert($dbi, "status", \%call_hash));
}


# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub fetch_statuses {
  my ( $sid ) = @_;
  my $q    = "SELECT * FROM status where sid = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);
  my @statuses = EASIH::DB::fetch_array_array( $dbi, $sth, $sid );
  
  @statuses = sort {$$b[2] <=> $$a[2]} @statuses;

  return @statuses if ( wantarray );
  return \@statuses;
}



1;



