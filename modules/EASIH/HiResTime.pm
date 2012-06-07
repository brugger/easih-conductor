package EASIH::HiResTime;
# 
# For high-resolution time manipulations.
# 
# 
# Kim Brugger (07 Mar 2012), contact: kim.brugger@easih.ac.uk

use strict;
use warnings;

use Time::HiRes;
use Time::Local;
use POSIX qw( strftime );


# 
# 
# 
# Kim Brugger (07 Mar 2012)
sub now {
  return Time::HiRes::gettimeofday()*100000;
}


# 
# 
# 
# Kim Brugger (04 May 2012)
sub time2HiRes {
  my ($time) = @_;
  return $time*100000;
}


# 
# 
# 
# Kim Brugger (07 Mar 2012)
sub split_HiResTime {
  my ($HiResTime) = @_;
  
  my $microsec = $HiResTime % 100000;
  $HiResTime /= 100000;
  
  return( $HiResTime, $microsec) if (wantarray );
  return [$HiResTime, $microsec];
}



# 
# 
# 
# Kim Brugger (07 Mar 2012)
sub HiRes2localtime {
  my ($HiResTime) = @_;
  my ($time, $microsec) = split_HiResTime( $HiResTime );
    
  $time =  strftime("%d/%m/%Y %H:%M:%S", localtime( $time ));
  return sprintf("%s.%05d", $time, $microsec);
}


# 
# 
# 
# Kim Brugger (07 Jun 2012)
sub HiRes2time {
  my ( $HiResTime ) = @_;
  my ( $time, $microsec) = split_HiResTime( $HiResTime );
  
  return $time;
}



# 
# 
# 
# Kim Brugger (07 Jun 2012)
sub TimeLocal {
  my ($sec,$min,$hour,$day,$month,$year) = @_;

  my $time = timelocal($sec,$min,$hour,$day,$month,$year);

  return time2HiRes($time);
}



1;




