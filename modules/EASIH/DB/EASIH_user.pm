package EASIH::DB::EASIH_user;
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
sub fetch_user_id {
  my ( $name ) = @_;
  my $q    = "SELECT id FROM user where username = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);
  my @line = EASIH::DB::fetch_array( $dbi, $sth, $name );
  return $line[0] || undef;
}


# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub fetch_user_name {
  my ( $id ) = @_;
  my $q    = "SELECT username FROM user where id = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);
  my @line = EASIH::DB::fetch_array( $dbi, $sth, $id );
  return $line[0] || undef;
}


# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub fetch_user_hash {
  my ( $id ) = @_;
  my $q    = "SELECT * FROM user where id = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);
  return EASIH::DB::fetch_hash( $dbi, $sth, $id );
}


# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub fetch_user_array {
  my ( $id ) = @_;
  my $q    = "SELECT * FROM user where id = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);
  return EASIH::DB::fetch_array( $dbi, $sth, $id );
}


# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub insert_user {
  my ($name, $password) = @_;

  my $id = fetch_user_id($name);
  return $id if ($id);

  return (EASIH::DB::insert($dbi, "user", {username => $name, password => $password}));
}


# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub update_user {
  my ($id, $name, $password) = @_;

  my %call_hash;
  $call_hash{id}        = $id;
  $call_hash{username}  = $name     if ($name);
  $call_hash{password}  = $password if ($password);

  return (EASIH::DB::update($dbi, "user", \%call_hash, "id"));
}


# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub fetch_group_id {
  my ( $name ) = @_;
  my $q    = "SELECT id FROM groups where groupname = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);
  my @line = EASIH::DB::fetch_array( $dbi, $sth, $name );
  return $line[0] || undef;
}


# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub fetch_group_name {
  my ( $id ) = @_;
  my $q    = "SELECT groupname FROM groups where id = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);
  my @line = EASIH::DB::fetch_array( $dbi, $sth, $id );
  return $line[0] || undef;
}


# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub fetch_group_hash {
  my ( $id ) = @_;
  my $q    = "SELECT * FROM groups where id = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);
  return EASIH::DB::fetch_hash( $dbi, $sth, $id );
}


# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub fetch_group_array {
  my ( $id ) = @_;
  my $q    = "SELECT * FROM groups where id = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);
  return EASIH::DB::fetch_array( $dbi, $sth, $id );
}


# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub insert_group {
  my ($name) = @_;

  my $id = fetch_group_id($name);
  return $id if ($id);

  return (EASIH::DB::insert($dbi, "groups", {groupname => $name}));
}


# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub update_group {
  my ($id, $name) = @_;

  my %call_hash;
  $call_hash{id}        = $id;
  $call_hash{groupname} = $name     if ($name);

  return (EASIH::DB::update($dbi, "groups", \%call_hash, "id"));
}



# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub fetch_user_group_ids {
  my ( $id ) = @_;
  my $q    = "SELECT group_id FROM user_group where user_id = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);

  my @groups = EASIH::DB::fetch_array_array( $dbi, $sth, $id );
  my @results;
  foreach my $g ( @groups ) {
    push @results, $$g[0];
  }

  return @results if ( wantarray );
  return \@results;
}


# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub fetch_user_group_names {
  my ( $id ) = @_;
  my $q    = "SELECT groupname FROM user_group, groups g where user_id = ? and group_id = g.id";
  my $sth  = EASIH::DB::prepare($dbi, $q);

  my @groups = EASIH::DB::fetch_array_array( $dbi, $sth, $id );
  my @results;
  foreach my $g ( @groups ) {
    push @results, $$g[0];
  }

  return @results if ( wantarray );
  return \@results;
}


# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub fetch_group_user_ids {
  my ( $uid ) = @_;
  my $q    = "SELECT user_id FROM user_group where user_id = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);
  return EASIH::DB::fetch_array( $dbi, $sth, $uid );
}


# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub check_user_group_id {
  my ( $uid, $gid ) = @_;
  my $q    = "SELECT * FROM user_group where user_id = ? and group_id = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);
  return EASIH::DB::fetch_array( $dbi, $sth, $uid, $gid );
}




# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub insert_user_group_ids {
  my ($uid, $gid) = @_;

  my $id = check_user_group_id($uid, $gid);
  return $id if ($id && @$id);

  return (EASIH::DB::insert($dbi, "user_group", {user_id => $uid, group_id => $gid}));
}







1;



