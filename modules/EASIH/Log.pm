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
  my ($message) = @_;

  $message ||= " ping...";
  $message =~ s/\n\z//;
  
  if ( !$hostname ) {
    $hostname = hostname;
  }

  #    0    1    2     3     4    5     6     7
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = gmtime(time);
  $message = sprintf("%s @ %02d/%02d-%4d %02d:%02d:%02d\t%s\n",
		     $hostname,$mday,$mon,1900+$year,$hour,$min,$sec, $message);

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


