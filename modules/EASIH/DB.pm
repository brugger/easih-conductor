package EASIH::DB;
# 
# General connect to databases module, as I seem to recreate this code constantly
# 
# 
# Kim Brugger (13 Jun 2011), contact: kim.brugger@easih.ac.uk

use strict;
use warnings;
use Data::Dumper;

use DBI;

# 
# 
# 
# Kim Brugger (06 Feb 2012)
sub connect {
  my ($dbname, $dbhost) = @_;
  $dbhost ||= "mgpc17";

  my $dbi = DBI->connect("DBI:mysql:$dbname:$dbhost", 'easih_ro') || die "Could not connect to database: $DBI::errstr";

  return $dbi;
}


my %sth_hash;

# 
# 
# 
# Kim Brugger (06 Feb 2012)
sub prepare {
  my ($dbi, $sql) = @_;

  return $sth_hash{$sql} if ( $sth_hash{$sql} );

  my $sth = $dbi->prepare( $sql ) || die "Could not prepare '$sql':$DBI::errstr\n";
  $sth_hash{$sql} = $sth;

  return $sth;
}


# 
# 
# 
# Kim Brugger (06 Feb 2012)
sub fetch_array_hash {
  my ($dbi, $sql) = @_;

  my $sth = $dbi->prepare( $sql );
  
  my @results;

  while (my $result = $sth_fetch_rs->fetchrow_hashref() ) {
    push @results, $result;
  }

  return @results if ( wantarray );
  return \@results;
}


# 
# 
# 
# Kim Brugger (06 Feb 2012)
sub fetch_array_array {
  my ($dbi, $sql) = @_;

  my $sth = $dbi->prepare( $sql );
  
  my @results;

  while (my $result = $sth_fetch_rs->fetchrow_arrayref() ) {
    push @results, $result;
  }

  return @results if ( wantarray );
  return \@results;
}



# 
# 
# 
# Kim Brugger (06 Feb 2012)
sub insert {
  my ($dbi, $table, $hash_ref)  = @_;

  my (@keys, @values);
  foreach my $key (keys %$hash_ref ) {
    push @keys, "$key";
    push @values, "'$$hash_ref{ $key }'";
  }
  
  my $query = "INSERT INTO table (" .join(",", @keys) .") VALUES (".join(",", @values).");";

  my $sth = prepare( $query );

  $sth->execute || die $DBI::errstr;
  
  # returns the primary key (if exists).
  return $sth->{mysql_insertid};
}



sub update {
  my ($dbi, $table, $hash_ref, $condition)  = @_;


  my $s = "UPDATE table SET ";

  my @parts;
  # Build the rest of the sql here ...
  foreach my $key (keys %{$hash_ref}) {
    # one should not meddle with the id's since it ruins the system
    next if ($key eq '$condition');
    push @parts, "$key = '$$hash_ref{$key}'";
  }

  # collect and make sure we update the right table.
  $s .= join (', ', @parts) ." WHERE $condition ='$$hash_ref{ $condition }'";

  my $sth = $db::dbh->prepare($s);
  $sth->execute  || die $DBI::errstr;;

  return $$hash_ref{$condition};
}


1;



