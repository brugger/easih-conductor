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


# 
# 
# 
# Kim Brugger (06 Feb 2012)
sub prepare {
  my ($dbi, $sql) = @_;

  my $sth = $dbi->prepare( $sql );

  return $sth;
}


# 
# 
# 
# Kim Brugger (06 Feb 2012)
sub fetch {
  my ($dbi, $sql) = @_;

  my $sth = $dbi->prepare( $sql );
  
  my @results;

  while (my $result = $sth_fetch_rs->fetchrow_hashref() ) {
    push @results, $result;
  }

  return @results if ( wantarray );

}



# 
# 
# 
# Kim Brugger (06 Feb 2012)
sub insert {
  my ($hash_ref)  = @_;

  $$hash_ref{type} = 'organism' if (!$$hash_ref{type});
  $$hash_ref{"subtype"} = '' if (!$$hash_ref{type});

  my $s = "INSERT INTO organism (name, alias, type, subtype) VALUES ('$$hash_ref{'name'}','$$hash_ref{'alias'}', '$$hash_ref{'type'}', '$$hash
_ref{'subtype'}')\n";
#  print STDERR "organism::save::$s\n";
  my $sth = $db::dbh->prepare($s);

  
  $sth->execute || die $DBI::errstr;
  
  # returns the oid of the organism created.
  return $sth->{mysql_insertid};
}



}



sub update {
  my ($hash_ref)  = @_;


  my $s = "UPDATE organism SET ";

  my @parts;
  # Build the rest of the sql here ...
  foreach my $key (keys %{$hash_ref}) {
    # one should not meddle with the id's since it ruins the system
    next if ($key eq 'oid');
    push @parts, "$key = ".$db::dbh->quote($$hash_ref{$key});
  }

  # collect and make sure we update the right table.
  $s .= join (', ', @parts) ." WHERE oid ='$$hash_ref{'oid'}'";

  my $sth = $db::dbh->prepare($s);
  $sth->execute  || die $DBI::errstr;;

  return $$hash_ref{'oid'};
}


1;



