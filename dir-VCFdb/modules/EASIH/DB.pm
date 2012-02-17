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
# Kim Brugger (16 Feb 2012)
sub create_db {
  my ($dbname, $dbhost, $db_user, $db_pass) = @_;
  my $drh = DBI->install_driver("mysql");
  my $rc = $drh->func('createdb', $dbname, $dbhost, $db_user, $db_pass, 'admin');
}


# 
# 
# 
# Kim Brugger (16 Feb 2012)
sub drop_db {
  my ($dbname, $dbhost, $db_user, $db_pass) = @_;
  my $drh = DBI->install_driver("mysql");
  my $rc = $drh->func('dropdb', $dbname, $dbhost, $db_user, $db_pass, 'admin');
}


# 
# 
# 
# Kim Brugger (16 Feb 2012)
sub sql_file {
  my ($dbi, $infile) = @_;

  open( my $in, $infile) || die "Could not open '$infile': $!\n";
  my @statements = split(";", join("", <$in>));
  close( $in );
  
  foreach my $statement ( @statements ) {
    $statement =~ s/\s+//;
    next if ( ! $statement );
    $dbi->do( "$statement;" );
  }

}



# 
# 
# 
# Kim Brugger (06 Feb 2012)
sub connect {
  my ($dbname, $dbhost, $db_user, $db_pass) = @_;
  $dbhost  ||= "mgpc17";
  $db_user ||= 'easih_ro';

  my $dbi = DBI->connect("DBI:mysql:$dbname:$dbhost", $db_user, $db_pass) || die "Could not connect to database: $DBI::errstr";

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
  my ($dbi, $sql, @params) = @_;

  my $sth = $sql if ( $sql->isa("DBI::st"));
  $sth = $dbi->prepare( $sql ) if ( !$sth );
  
  my @results;

  $sth->execute( @params );
 
  while (my $result = $sth->fetchrow_hashref() ) {
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
  my ($dbi, $sql, @params) = @_;

  my $sth = $sql if ( $sql->isa("DBI::st"));
  $sth = $dbi->prepare( $sql ) if ( !$sth );
  
  my @results;

  $sth->execute( @params );

  while (my @result_array = $sth->fetchrow_array() ) {
    push @results, \@result_array;
  }

  return @results if ( wantarray );
  return \@results;
}


# 
# 
# 
# Kim Brugger (06 Feb 2012)
sub fetch_array {
  my ($dbi, $sql, @params) = @_;

  my $sth = $sql if ( $sql->isa("DBI::st"));
  $sth = $dbi->prepare( $sql ) if ( !$sth );

  $sth->execute( @params );
  
  my @results = $sth->fetchrow_array();

  return @results if ( wantarray );
  return \@results;
}


# 
# 
# 
# Kim Brugger (06 Feb 2012)
sub fetch_hash {
  my ($dbi, $sql, @params) = @_;

  my $sth = $sql if ( $sql->isa("DBI::st"));
  $sth = $dbi->prepare( $sql ) if ( !$sth );
  
  $sth->execute( @params );

  my $result = $sth->fetchrow_hashref();
  
  return $result;
  
  return %$result if ( wantarray );
  return $result;
}



# 
# 
# 
# Kim Brugger (06 Feb 2012)
sub insert {
  my ($dbi, $table, $hash_ref)  = @_;

  my (@keys, @params, @values);
  foreach my $key (keys %$hash_ref ) {
#    print "$key -- $$hash_ref{ $key }\n";
    push @keys, "$key";
    push @params, "?";
    push @values, "$$hash_ref{ $key }";
  }
  
  my $query = "INSERT INTO $table (" .join(",", @keys) .") VALUES (".join(",", @params).")";
  my $sth = prepare($dbi, $query);

  $sth->execute(@values) || die $DBI::errstr;
  
  # returns the primary key (if exists), otherwise -1.
  return $sth->{mysql_insertid} || -1;
}



sub update {
  my ($dbi, $table, $hash_ref, $condition_key)  = @_;

  my $s = "UPDATE $table SET ";

  my @parts;
  # Build the rest of the sql here ...
  foreach my $key (keys %{$hash_ref}) {
    # one should not meddle with the id's since it ruins the system
    next if ($key eq $condition_key);
    push @parts, "$key = '$$hash_ref{$key}'";
  }

  # collect and make sure we update the right table.
  $s .= join (' AND ', @parts) ." WHERE $condition_key ='$$hash_ref{ $condition_key }'";

  my $sth = $dbi->prepare($s);
  $sth->execute  || die $DBI::errstr;;

  return $$hash_ref{$condition_key};
}


1;



