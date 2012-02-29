package EASIH::Log;
# 
# Generic logging module, designed for conductor
# 
# 
# Kim Brugger (29 Feb 2012), contact: kim.brugger@easih.ac.uk

use strict;
use warnings;
use Data::Dumper;


# 
# redirect STDERR to the logfile...
# 
# Kim Brugger (29 Feb 2012)
sub open {
  my ($file) = @_;

  # if we can write to the file do it, if the file do not exists, but we can 
  # write to the directory create the file.
  open (STDERR, $$file) || die  "Could not open logfile '$LOG_FILE': $!\n";

}





# 
# 
# 
# Kim Brugger (29 Feb 2012)
sub log {
  my ($message) = @_;

  printf STDERR ("%s @ %02d/%02d-%4d %02d:%02d:%02d\n",
                "HOSTNAME",$mday,$mon,$year,$hour,$min,$sec);

  #    0    1    2     3     4    5     6     7
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = gmtime(time);
  $year +=1900;$hour++;$mon++;
  $message ||= " ping...";
  $message =~ s/\n\z//;
  print STDERR "$message\n";
}




1;


