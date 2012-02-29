package EASIH::CRR;
# 
# Common Run Reporting for tracking progress of what is being done
# 
# 
# Kim Brugger (13 Jun 2011), contact: kim.brugger@easih.ac.uk

use strict;
use warnings;
use Data::Dumper;


my $steps = 0;

my %statuses;

# 
# 
# 
# Kim Brugger (29 Feb 2012)
sub steps {
  my ($new_steps) = @_;
  
  $steps = $new_steps if ( $new_steps && is_integer($new_steps));
  return $steps;
}



# 
# 
# 
# Kim Brugger (29 Feb 2012)
sub _add_values {
  my ($type, $step, $jobs) = @_;

  if ( ! $type ) {
    print STDERR "No type given, cannot store this\n";
    return 0;
  }
  return 0 if ( !is_integer($step));
  return 0 if ( $jobs && !is_integer($jobs));

  $statuses{$step}{$type} = $jobs || 1;
  return 1;
}



# 
# 
# 
# Kim Brugger (29 Feb 2012)
sub ok {
  my ($step, $jobs) = @_;
  
  return _add_values("ok", $step, $jobs);
}


# 
# 
# 
# Kim Brugger (29 Feb 2012)
sub failed {
  my ($step, $jobs) = @_;
  
  return _add_values("failed", $step, $jobs);
}


# 
# 
# 
# Kim Brugger (29 Feb 2012)
sub waiting {
  my ($step, $jobs) = @_;
  
  return _add_values("waiting", $step, $jobs);
}


# 
# 
# 
# Kim Brugger (29 Feb 2012)
sub running {
  my ($step, $jobs) = @_;
  
  return _add_values("running", $step, $jobs);
}


# 
# 
# 
# Kim Brugger (29 Feb 2012)
sub report {

  if (!$steps ) {
    $steps = ( sort {$b <=> $a } keys %statuses )[0];
  }

  my $res = "";
  $res = "1..$steps\n";

  for(my $step=1;$step<=$steps;$step++) {
    
    if (!$statuses{ $step}) {
      $res .= join("\t", $step, "waiting") ."\n";
    }
    else {
      foreach my $type (sort keys %{$statuses{ $step}} ) {
	if ( $statuses{ $step }{ $type } == 1) { 
	  $res .= join("\t", $step, $type) ."\n";
	}
	else {
	  $res .= join("\t", $step, $type, $statuses{ $step }{ $type }) ."\n";
	}
      }
    }
  }


  return $res;
}

# 
# 
# 
# Kim Brugger (29 Feb 2012)
sub is_integer {
  my ($value) = @_;

  return 1 if ( $value =~ /^\d+\z/);
  print STDERR "$value is not an integer\n";
  return 0;
}

1;


