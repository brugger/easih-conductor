package EASIH::Log;
# 
# Generic logging module, designed for conductor
# 
# 
# Kim Brugger (29 Feb 2012), contact: kim.brugger@easih.ac.uk

use strict;
use warnings;
use Data::Dumper;
use Fcntl qw/ :flock /;
use Sys::Hostname;
my $log_file;

my $hostname;
my $program;

use constant {
  OFF       => -1,
  FATAL     => 0,
  ERROR     => 1,
  WARN      => 2,
  INFO      => 3,
  DEBUG     => 4,
  TRACE     => 5,
  TRACE_INT => 6,
  ALL       => 7,
};

use constant LEVELS => qw( FATAL ERROR  WARN INFO DEBUG TRACE TRACE_INT ALL);
my $level = 2;



# 
# 
# 
# Kim Brugger (01 Mar 2012)
sub level {
  my ($new_level) = @_;

  $new_level = _toLevel( $new_level );
  
  if ( defined $new_level ) {
    $level = $new_level;
    return $level;
  }
  else {
    print STDERR "$new_level is invalid, should be either an integer ranging from -1 to 7 or one of the following keywords: OFF FATAL ERROR  WARN INFO DEBUG TRACE TRACE_INT ALL\n";
  return undef;
  }
}



# 
# 
# 
# Kim Brugger (01 Mar 2012)
sub _toLevel {
  my ($new_level) = @_;

  return undef if ( ! defined $new_level);

  if ( $new_level =~ /^\d+\z/ && $new_level >= -1 && $new_level <= 7 ) {
    return $level;
  }
  else {
    if ($new_level eq "OFF") {
	return $level;
    }
    
    for(my $i=0;$i<=7;$i++) {
      if ((LEVELS)[$i] eq $new_level) {
	return $i;
      }
    }
  } 

  return undef;
}



# 
# 
# 
# Kim Brugger (29 Feb 2012)
sub file {
  my ($filename) = @_;
  
  $log_file = $filename;
}


# 
# 
# 
# Kim Brugger (29 Feb 2012)
sub write {
  my ($message, $message_level) = @_;  

  $message_level ||= WARN;
  $message_level = _toLevel($message_level);

  return if ( $level == -1 || $message_level > $level );

  $message ||= " ping...";
  $message =~ s/\n\z//;
  
  if ( !$hostname ) {
    $hostname = hostname;
  }

  if ( !$program ) {
    $program = $0;
    $program =~ s/.*\///;
  }

  #    0    1    2     3     4    5     6     7
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = gmtime(time);
  $message = sprintf("%s@%s %02d/%02d-%4d %02d:%02d:%02d :: %s :: %s\n",
		     $program, $hostname,$mday,$mon,1900+$year,$hour,$min,$sec, (LEVELS)[ $message_level ], $message);

  if ( $log_file ) {
    open (my $fh , ">> ", $log_file) or die  "$0 [$$]: open: $!";
    flock $fh, LOCK_EX      or die  "$0 [$$]: flock: $!";
    print $fh  "$message" or die  "$0 [$$]: write: $!";
    close $fh               or warn "$0 [$$]: close: $!";
  }
  else {
    print STDERR "$message";
  }
}




1;


