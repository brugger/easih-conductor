package EASIH::VCFdb;
# 
# 
# 
# 
# Kim Brugger (13 Jun 2011), contact: kim.brugger@easih.ac.uk

use strict;
use warnings;
use Data::Dumper;


use EASIH::DB;

my $dbi;

# 
# 
# 
# Kim Brugger (12 May 2011)
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
  my ($pid, $name, $VCF_header) = @_;

  my $sid = fetch_sample_id($name);
  return $sid if ( $sid );

  my %call_hash = ( pid        => $pid,
		    name       => $name,
		    VCF_header => $VCF_header);

  return (EASIH::DB::insert($dbi, "sample", \%call_hash));
}

# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub update_sample {
  my ($sid, $name, $VCF_header) = @_;

  my %call_hash;
  $call_hash{sid}        = $sid  if ($sid);
  $call_hash{name}       = $name if ($name);
  $call_hash{VCF_header} = $VCF_header if ($VCF_header);

  return (EASIH::DB::update($dbi, "sample", \%call_hash, "sid"));
}


# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub hash_fetch_variation_by_vid {
  my ( $vid ) = @_;
  my $q    = "SELECT * FROM variation where vid = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);
  return ( EASIH::DB::fetch_hash( $dbi, $sth, $vid ) );
}

# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub fetch_variation_by_chr_pos {
  my ( $chr, $pos ) = @_;
  my $q    = "SELECT * FROM variation where chr = ? AND pos = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);
  return ( EASIH::DB::fetch_array_hash( $dbi, $sth, $chr, $pos ) );
}


# 
# Should validate if an entry already exists.
# 
# Kim Brugger (07 Feb 2012)
sub insert_variation {
  my ($chr, $pos, $ref, $alt) = @_;

  my @vars = fetch_variation_by_chr_pos($chr, $pos);
  foreach my $var (@vars ) {
    my ( $vid, $v_ref, $v_alt) = ($$var{vid}, $$var{ref},$$var{alt});
    if ( $v_ref eq $ref && $v_alt eq $alt ) {
      return $vid;
    }
  }
  my %call_hash = ( chr => $chr,
		    pos => $pos,
		    ref => $ref,
		    alt => $alt,
		    status => 'unannotated');

  return (EASIH::DB::insert($dbi, "variation", \%call_hash));
}

# 
# Should validate if an entry already exists.
# 
# Kim Brugger (07 Feb 2012)
sub update_variation {
  my ($vid, $chr, $pos, $ref, $alt, $status) = @_;

  my %call_hash;
  $call_hash{vid}    = $vid    if ($vid);
  $call_hash{chr}    = $chr    if ($chr);
  $call_hash{pos}    = $pos    if ($pos);
  $call_hash{ref}    = $ref    if ($ref);
  $call_hash{alt}    = $alt    if ($alt);
  $call_hash{status} = $status if ($status);

  return (EASIH::DB::update($dbi, "variation", \%call_hash, "vid"));
}



# 
# Should validate if an entry already exists.
# 
# Kim Brugger (07 Feb 2012)
sub insert_annotation {
  my ( $call_hash ) = @_;

  foreach my $key (keys %$call_hash) {

    next if ( ! $$call_hash{ $key } );

    if ( ! grep($key, [ "vid", "gene", "transcript", "effect", "codon_pos",
			"AA_change", "grantham_score", "pfam",
			"PolyPhen", "SIFT", "condel", "GERP"])) {
      print "$key ($$call_hash{$key}) is not present in the annotation table\n";
      die Dumper( $call_hash );
      return -1;
    }
  }

  return (EASIH::DB::insert($dbi, "annotation", $call_hash));
}


# 
# Should validate if an entry already exists.
# 
# Kim Brugger (07 Feb 2012)
sub fetch_annotation {
  my ( $vid ) = @_;

  my $q    = "SELECT * FROM annotation where vid = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);
  return(EASIH::DB::fetch_array_hash( $dbi, $sth, $vid ));
}



# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub insert_sample_data {
  my ( $call_hash ) = @_;

  foreach my $key (keys %$call_hash) {

    next if ( ! $$call_hash{ $key } );
    if ( ! grep($key, [ "sid", "vid", "filter", "score", "depth", "format_keys",
			"format_values"])) {
      print "$key is not present in the annotation table\n";
      die Dumper( $call_hash );
      return -1;
    }
  }

  return (EASIH::DB::insert($dbi, "sample_data", $call_hash));
}

# 
# 
# 
# Kim Brugger (07 Feb 2012)
sub fetch_sample_data {
  my ($sid, $vid) = @_;

  my $q    = "SELECT * FROM sample_date where sid = ? AND vid = ?";
  my $sth  = EASIH::DB::prepare($dbi, $q);
  return(EASIH::DB::fetch_hash( $dbi, $sth, $sid, $vid ));
}







1;



