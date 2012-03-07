package EASIH::Trace;
# 
# For debugging/error reporting, will tell what package/file/line/function we are currently in...
# 
# 
# Kim Brugger (07 Mar 2012), contact: kim.brugger@easih.ac.uk

use strict;
use warnings;



# 
# 
# 
# Kim Brugger (07 Mar 2012)
sub Package {
  return (caller(0))[0];
}


# 
# 
# 
# Kim Brugger (07 Mar 2012)
sub File {
  return (caller(0))[1];
}


# 
# 
# 
# Kim Brugger (07 Mar 2012)
sub Line {
  return (caller(0))[2];
}

# 
# 
# 
# Kim Brugger (07 Mar 2012)
sub Function {
  return (caller(1))[3];
}



# 
# 
# 
# Kim Brugger (07 Mar 2012)
sub Full {
  my ($package, $file, $line, $function) = _full();
  return "$package/$file l.$line f.$function";
      
}


# 
# 
# 
# Kim Brugger (07 Mar 2012)
sub _full {
  return(Package(), File(), Line(), Function);
}



1;




