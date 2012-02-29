package EASIH::CRR;
# 
# Common Run Reporting for tracking progress of what is being done
# 
# 
# Kim Brugger (13 Jun 2011), contact: kim.brugger@easih.ac.uk

use strict;
use warnings;
use Data::Dumper;


my $tasks = 0;

my %statuses;


# 
# 
# 
# Kim Brugger (29 Feb 2012)
sub _statuses {
  return %statuses;
}

# 
# 
# 
# Kim Brugger (29 Feb 2012)
sub tasks {
  my ($new_tasks) = @_;
  
  $tasks = $new_tasks if ( $new_tasks && is_integer($new_tasks));
  return $tasks;
}



# 
# 
# 
# Kim Brugger (29 Feb 2012)
sub _add_values {
  my ($type, $task, $jobs) = @_;

  if ( ! $type ) {
    print STDERR "No type given, cannot store this\n";
    return 0;
  }
  return 0 if ( !is_integer($task));
  return 0 if ( $jobs && !is_integer($jobs));

  $statuses{$task}{$type} = $jobs || 1;
  return 1;
}

# 
# 
# 
# Kim Brugger (29 Feb 2012)
sub failed {
  my ($task, $jobs) = @_;
  
  return _add_values("failed", $task, $jobs);
}

# 
# 
# 
# Kim Brugger (29 Feb 2012)
sub ok {
  my ($task, $jobs) = @_;
  
  return _add_values("ok", $task, $jobs);
}


# 
# 
# 
# Kim Brugger (29 Feb 2012)
sub running {
  my ($task, $jobs) = @_;
  
  return _add_values("running", $task, $jobs);
}

# 
# 
# 
# Kim Brugger (29 Feb 2012)
sub waiting {
  my ($task, $jobs) = @_;
  
  return _add_values("waiting", $task, $jobs);
}



# 
# 
# 
# Kim Brugger (29 Feb 2012)
sub report {

  if (!$tasks ) {
    $tasks = ( sort {$b <=> $a } keys %statuses )[0];
  }

  my $res = "";
  $res = "1..$tasks\n";

  for(my $task=1;$task<=$tasks;$task++) {
    
    if (!$statuses{ $task}) {
      $res .= join("\t", $task, "waiting") ."\n";
    }
    else {
      foreach my $type (sort keys %{$statuses{ $task}} ) {
	if ( $statuses{ $task }{ $type } == 1) { 
	  $res .= join("\t", $task, $type) ."\n";
	}
	else {
	  $res .= join("\t", $task, $type, $statuses{ $task }{ $type }) ."\n";
	}

	goto FAILED if ( $type eq "failed");
      }
    }
  }

 FAILED:

  return $res;
}


# 
# 
# 
# Kim Brugger (29 Feb 2012)
sub readin {
  my ($file) = @_;

  open (my $in, $file) || die "Could not open '$file': $!\n";
  my $content = join("", <$in>);
  close($in);
  parse( $content );
  
}


# 
# 
# 
# Kim Brugger (29 Feb 2012)
sub parse {
  my ($report) = @_;

  undef %statuses;
  my @lines = split("\n", $report);

  foreach my $line ( @lines ) {

    if ($line =~ /^1\.\.(\d+)/ ){
      $tasks = $1;
      next;
    }

    my ($step, $status, $count) = split("\t", $line);
    if ( $status ne "ok" && $status ne "running" && $status ne "failed" && $status ne "waiting") {
      print STDERR "$status is unknown, expected: ok, running, failed or waiting\n";
      return 0;
    }
    next if (!$count && $status eq "waiting");
    if ($count && ! is_integer($count)) {
      print STDERR "$count is not an integer\n";
      return 0;
    }

    if (!is_integer($step)) {
      print STDERR "$step is not an integer\n";
      return 0;
    }

    $statuses{$step}{$status} = $count || 1;
  }

  return 1;
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


