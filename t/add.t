#!/usr/local/bin/perl -w

use Math::SigFigs qw(:all);
$runtests=shift(@ARGV);
if ( -f "t/test.pl" ) {
  require "t/test.pl";
} elsif ( -f "test.pl" ) {
  require "test.pl";
} else {
  die "ERROR: cannot find test.pl\n";
}

print "addSF...\n";
print "1..8\n"  if (! $runtests);

$tests="

112.345
 10
120

112.345
 11
123.

112.345
 11.1
123.4

# sprintf rounds the following wrong IMO (123.45 produced instead of 123.46)
112.345
 11.11
123.45

112.345
-10
100

112.345
-11
101.

112.345
-11.1
101.2

112.345
-11.11
101.23

";

&test_Func(\&addSF,$tests,$runtests);

1;

