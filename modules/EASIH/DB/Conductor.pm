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
# Kim Brugger (06 Mar 2012), contact: kim.brugger@easih.ac.uk
sub fetch_sequencer_id {
  my ( $name ) = @_;
  my $q    = "SELECT mid FROM sequencer WHERE name = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);
  my @line = EASIH::DB::fetch_array( $dbi, $sth, $name );
  return $line[0] || undef;
}


# 
# 
# 
# Kim Brugger (06 Mar 2012), contact: kim.brugger@easih.ac.uk
sub fetch_sequencer {
  my ( $mid ) = @_;
  my $q    = "SELECT * FROM sequencer WHERE mid = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);
  return EASIH::DB::fetch_hash( $dbi, $sth, $mid );
}


# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub insert_sequencer {
  my ($name, $platform) = @_;
  
  if (! $name || ! $platform) {
    print STDERR "Sequencer needs both a name and a platform\n";
    return undef;
  }

  my $mid = fetch_sequencer_id($name);
  return $mid if ( $mid );

  my %call_hash = ( name     => $name,
		    platform => $platform);

  return (EASIH::DB::insert($dbi, "sequencer", \%call_hash));
}

# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub update_sequencer {
  my ($mid, $name, $platform) = @_;

  my %call_hash;
  $call_hash{mid}      = $mid;
  $call_hash{name}     = $name     if ( $name     );
  $call_hash{platform} = $platform if ( $platform );

  return (EASIH::DB::update($dbi, "sequencer", \%call_hash, "mid"));
}


# 
# 
# 
# Kim Brugger (06 Mar 2012), contact: kim.brugger@easih.ac.uk
sub fetch_run_id {
  my ( $name ) = @_;
  my $q    = "SELECT rid FROM run WHERE name = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);
  my @line = EASIH::DB::fetch_array( $dbi, $sth, $name );
  return $line[0] || undef;
}


# 
# 
# 
# Kim Brugger (06 Mar 2012), contact: kim.brugger@easih.ac.uk
sub fetch_run {
  my ( $rid ) = @_;
  my $q    = "SELECT * FROM run WHERE rid = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);
  return EASIH::DB::fetch_hash( $dbi, $sth, $rid );
}


# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub insert_run {
  my ($mid, $name) = @_;
  
  if (! $mid || ! $name) {
    print STDERR "run needs both a name and a sequencer id (mid)\n";
    return undef;
  }

  my $rid = fetch_run_id($name);
  return $rid if ( $rid );

  my %call_hash = ( mid      => $mid,
     		    name     => $name);

  return (EASIH::DB::insert($dbi, "run", \%call_hash));
}

# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub update_run {
  my ($rid, $mid, $name) = @_;

  if ( $rid ) {
    print STDERR "rid missing in function call\n";
    return undef;
  }

  my %call_hash;
  $call_hash{rid}      = $rid;
  $call_hash{mid}      = $mid;
  $call_hash{name}     = $name if ( $name     );

  return (EASIH::DB::update($dbi, "run", \%call_hash, "rid"));
}


# 
# 
# 
# Kim Brugger (06 Mar 2012), contact: kim.brugger@easih.ac.uk
sub fetch_file_id {
  my ( $name ) = @_;
  my $q    = "SELECT fid FROM sample WHERE name = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);
  my @line = EASIH::DB::fetch_array( $dbi, $sth, $name );
  return $line[0] || undef;
}


# 
# 
# 
# Kim Brugger (06 Mar 2012), contact: kim.brugger@easih.ac.uk
sub fetch_file_name {
  my ( $fid ) = @_;
  my $q    = "SELECT name FROM file WHERE fid = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);
  my @line = EASIH::DB::fetch_array( $dbi, $sth, $fid );
  return $line[0] || undef;
}


# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub insert_file {
  my ($sid, $rid, $name) = @_;

  if (! $rid ) {
    print STDERR "A rid was not provided\n";
    return undef;
  }

  if (! $sid ) {
    print STDERR "A sid was not provided\n";
    return undef;
  }

  if (! $name ) {
    print STDERR "A name was not provided\n";
    return undef;
  }

  if (! fetch_sample_name($sid) ) {
    print STDERR "$sid is not a known sid\n";
    return undef;
  }

  if (! fetch_run($rid) ) {
    print STDERR "$rid is not a valid rid\n";
    return undef;
  }

  my %call_hash = ( sid => $sid,
		    rid => $rid,
		    name => $name);

  return (EASIH::DB::insert($dbi, "file", \%call_hash));
}

# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub update_file {
  my ($fid, $name) = @_;


  if (! $fid ) {
    print STDERR "A fid was not provided\n";
    return undef;
  }

  if (! $name ) {
    print STDERR "A name was not provided\n";
    return undef;
  }

  my %call_hash;
  $call_hash{fid}    = $fid  if ($fid);
  $call_hash{name}   = $name if ($name);

  return (EASIH::DB::update($dbi, "file", \%call_hash, "fid"));
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



