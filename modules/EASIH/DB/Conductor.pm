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
use EASIH::Trace;
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
sub fetch_project_hash {
  my ( $sid ) = @_;
  my $q    = "SELECT * FROM project where pid = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);
  return EASIH::DB::fetch_hash( $dbi, $sth, $sid );
}


# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub fetch_project_array {
  my ( $sid ) = @_;
  my $q    = "SELECT * FROM project where pid = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);
  return EASIH::DB::fetch_array( $dbi, $sth, $sid );
}




# 
# 
# 
# Kim Brugger (03 May 2012)
sub seach_project {
  my ($var) = @_;
  $var = "%$var%";
  my $q    = "SELECT * FROM project where name like ? OR organism like ? OR notes like ? OR contacts like ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);

  return EASIH::DB::fetch_array_hash( $dbi, $sth, $var, $var, $var, $var );
}

# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub insert_project {
  my ($name, $organism, $notes, $contacts) = @_;

  my $pid = fetch_project_id($name);
  return $pid if ($pid);

  $notes ||= "";
  $contacts ||= "";
  $organism ||= "";

  return (EASIH::DB::insert($dbi, "project", {name => $name, organism => $organism, notes => $notes, contacts => $contacts}));
}


# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub update_project {
  my ($pid, $name, $notes) = @_;

  my %call_hash;
  $call_hash{pid}    = $pid   if ($pid);
  $call_hash{name}   = $name  if ($name);
  $call_hash{notes}  = $notes if ($notes);

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
    print STDERR EASIH::Trace::Function() . " Unknown pid: $pid\n";
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
    print STDERR EASIH::Trace::Function() . " Sequencer needs both a name and a platform\n";
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
    print STDERR EASIH::Trace::Function() . " run needs both a name and a sequencer id (mid)\n";
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
    print STDERR EASIH::Trace::Function() . " rid missing in function call\n";
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
# Kim Brugger (07 Feb 2012)
sub insert_sample_sheet_line {
  my ($rid, $lane, $sample_name, $barcode) = @_;
  
  if (! $rid || !$lane || ! $sample_name) {
    print STDERR EASIH::Trace::Function() . " run needs both a run id (rid), lane and a sample_name\n";
    return undef;
  }

  my %call_hash = ( rid         => $rid,
		    lane        => $lane,
     		    sample_name => $sample_name,
		    barcode     => $barcode);

  return (EASIH::DB::insert($dbi, "sample_sheet", \%call_hash));
}



# 
# A lot of hard coding in this one, do not like this...
# 
# Kim Brugger (24 Apr 2012), contact: kim.brugger@easih.ac.uk
sub fetch_sample_sheet {
  my ( $rid ) = @_;
  my $q    = "SELECT * FROM sample_sheet WHERE rid = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);


  my @ss = EASIH::DB::fetch_array_array( $dbi, $sth, $rid );
  my $res = "";
  for(my $i=0;$i<@ss; $i++) {
    $ss[$i][3] ||= "";
    $res .= join("\t", @{$ss[$i]}[1..3]) . "\n";
  }
  
  return $res;
}


# 
# 
# 
# Kim Brugger (24 Apr 2012), contact: kim.brugger@easih.ac.uk
sub fetch_sample_sheet_array {
  my ( $rid ) = @_;
  my $q    = "SELECT * FROM sample_sheet WHERE rid = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);

  return EASIH::DB::fetch_array_array( $dbi, $sth, $rid );
}

# 
# 
# 
# Kim Brugger (24 Apr 2012), contact: kim.brugger@easih.ac.uk
sub fetch_sample_sheet_hash {
  my ( $rid ) = @_;
  my $q    = "SELECT * FROM sample_sheet WHERE rid = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);

  return EASIH::DB::fetch_array_hash( $dbi, $sth, $rid );
}


# 
# 
# 
# Kim Brugger (24 Apr 2012), contact: kim.brugger@easih.ac.uk
sub fetch_file {
  my ( $id ) = @_;
  my $q = "SELECT * FROM file WHERE name = ?";
  $q    = "SELECT * FROM file WHERE fid = ?" if ( $id =~ /^\d+\z/);
  my $sth  = EASIH::DB::prepare($dbi, $q);
  return EASIH::DB::fetch_hash( $dbi, $sth, $id );
}

# 
# 
# 
# Kim Brugger (06 Mar 2012), contact: kim.brugger@easih.ac.uk
sub fetch_file_id {
  my ( $name ) = @_;
  my $q    = "SELECT fid FROM file WHERE name = ?";
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
    print STDERR EASIH::Trace::Function() . " A rid was not provided\n";
    return undef;
  }

  if (! $sid ) {
    print STDERR EASIH::Trace::Function() . " A sid was not provided\n";
    return undef;
  }

  if (! $name ) {
    print STDERR EASIH::Trace::Function() . " A name was not provided\n";
    return undef;
  }

  if (! fetch_sample_name($sid) ) {
    print STDERR EASIH::Trace::Function() . " $sid is not a known sid\n";
    return undef;
  }

  if (! fetch_run($rid) ) {
    print STDERR EASIH::Trace::Function() . " $rid is not a valid rid\n";
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

  if (! $fid || ! $name ) {
    print STDERR EASIH::Trace::Function() . " Both a file id (fid) and a new name is needed for updating a file entry\n";
    return undef;
  }

  if (! $name ) {
    print STDERR EASIH::Trace::Function() . " A name was not provided\n";
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
  return  EASIH::DB::fetch_hash( $dbi, $sth, $aid );
}


# 
# Should validate if an entry already exists.
# 
# Kim Brugger (07 Feb 2012)
sub insert_analysis {
  my ($reference, $pipeline, $min_reads) = @_;

  my $aid = fetch_analysis_id($reference, $pipeline);
  return $aid if ( $aid );

  my %call_hash = ( reference  => $reference,
		    pipeline   => $pipeline,
		    min_reads  => $min_reads);

  return (EASIH::DB::insert($dbi, "analysis", \%call_hash));
}


# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub update_analysis {
  my ($aid, $reference, $pipeline, $min_reads) = @_;

  if (! $aid ) {
    print STDERR EASIH::Trace::Function() . " A analysis id (aid) is needed for updating an analysis entry\n";
    return undef;
  }

  my %call_hash;
  $call_hash{aid}        = $aid;
  $call_hash{reference}  = $reference if ($reference);
  $call_hash{pipeline}   = $pipeline  if ($pipeline);
  $call_hash{min_reads}  = $min_reads if ($min_reads);

  return (EASIH::DB::update($dbi, "analysis", \%call_hash, "aid"));
}


# 
# Should validate if an entry already exists.
# 
# Kim Brugger (07 Mar 2012), contact: kim.brugger@easih.ac.uk
sub insert_run_status {
  my ($rid, $status) = @_;

  my $run_name = fetch_sample_name($rid);
  
  if (! $run_name ) {
    print STDERR EASIH::Trace::Function() . " Unknown rid: $rid\n";
    return undef;
  }


  my $stamp = EASIH::DB::highres_timestamp();

  my %call_hash = ( rid    => $rid,
		    status => $status,
		    stamp  => $stamp);

  return (EASIH::DB::insert($dbi, "run_status", \%call_hash));
}

# 
# 
# 
# Kim Brugger (07 Mar 2012), contact: kim.brugger@easih.ac.uk
sub fetch_run_statuses {
  my ( $rid ) = @_;
  my $q    = "SELECT * FROM run_status where rid = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);
  my @statuses = EASIH::DB::fetch_array_array( $dbi, $sth, $rid );
  
  @statuses = sort {$$b[2] <=> $$a[2]} @statuses;

  return @statuses if ( wantarray );
  return \@statuses;
}



# 
# Should validate if an entry already exists.
# 
# Kim Brugger (07 Mar 2012), contact: kim.brugger@easih.ac.uk
sub insert_file_status {
  my ($fid, $status) = @_;

  my $file_name = fetch_file_name($fid);
  
  if (! $file_name ) {
    print STDERR EASIH::Trace::Function() . " Unknown file id (fid): $fid\n";
    return undef;
  }


  my $stamp = EASIH::DB::highres_timestamp();

  my %call_hash = ( fid    => $fid,
		    status => $status,
		    stamp  => $stamp);

  return (EASIH::DB::insert($dbi, "file_status", \%call_hash));
}

# 
# 
# 
# Kim Brugger (07 Mar 2012), contact: kim.brugger@easih.ac.uk
sub fetch_file_statuses {
  my ( $fid ) = @_;
  my $q    = "SELECT * FROM file_status where fid = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);
  my @statuses = EASIH::DB::fetch_array_array( $dbi, $sth, $fid );
  
  @statuses = sort {$$b[2] <=> $$a[2]} @statuses;

  return @statuses if ( wantarray );
  return \@statuses;
}



# 
# Should validate if an entry already exists.
# 
# Kim Brugger (07 Mar 2012), contact: kim.brugger@easih.ac.uk
sub insert_sample_analysis_status {
  my ($sid, $status) = @_;

  my $sample_name = fetch_sample_name($sid);
  
  if (! $sample_name ) {
    print STDERR EASIH::Trace::Function() . " Unknown sid: $sid\n";
    return undef;
  }


  my $stamp = EASIH::DB::highres_timestamp();

  my %call_hash = ( sid    => $sid,
		    status => $status,
		    stamp  => $stamp);

  return (EASIH::DB::insert($dbi, "sample_analysis_status", \%call_hash));
}


# 
# 
# 
# Kim Brugger (07 Mar 2012), contact: kim.brugger@easih.ac.uk
sub fetch_sample_analysis_statuses {
  my ( $sid ) = @_;
  my $q    = "SELECT * FROM sample_analysis_status where sid = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);
  my @statuses = EASIH::DB::fetch_array_array( $dbi, $sth, $sid );
  
  @statuses = sort {$$b[2] <=> $$a[2]} @statuses;

  return @statuses if ( wantarray );
  return \@statuses;
}





# 
# 
# 
# Kim Brugger (07 Mar 2012), contact: kim.brugger@easih.ac.uk
sub fetch_sample_crr {
  my ( $sid ) = @_;
  my $q = "SELECT task, type, count FROM sample_crr where sid = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);
  my @statuses = EASIH::DB::fetch_array_array( $dbi, $sth, $sid);
  
  @statuses = sort {$$b[1] cmp $$a[1]} @statuses;

  return @statuses if ( wantarray );
  return \@statuses;
}



# 
# Should validate if an entry already exists.
# 
# Kim Brugger (07 Mar 2012), contact: kim.brugger@easih.ac.uk
sub insert_sample_crr {
  my ($sid, @crr) = @_;

  my $sample_name = fetch_sample_name($sid);
  if (! $sample_name ) {
    print STDERR EASIH::Trace::Function() . " Unknown sample id (sid): $sid\n";
    return undef;
  }

  @crr = @{$crr[0]} if ( ref($crr[0][0]) eq 'ARRAY');

  for( my $i = 0; $i < @crr; $i++ ) {
    
    my %call_hash = ( sid    => $sid,
		      task   => $crr[$i][0],
		      type   => $crr[$i][1],
		      count  => $crr[$i][2]);

    EASIH::DB::insert($dbi, "sample_crr", \%call_hash);

  }
  
  return 1;
}



# 
# 
# 
# Kim Brugger (07 Mar 2012), contact: kim.brugger@easih.ac.uk
sub delete_sample_crr {
  my ($sid) = @_;

  my $sample_name = fetch_sample_name($sid);
  if (! $sample_name ) {
    print STDERR EASIH::Trace::Function() . " Unknown sample id (sid): $sid\n";
    return undef;
  }

  my $q = "DELETE FROM sample_crr WHERE sid = ?";
  EASIH::DB::do($dbi, $q, $sid);
}




1;



