#!/usr/local/bin/perl -w

use Math::SigFigs;
$runtests=shift(@ARGV);
if ( -f "t/test.pl" ) {
  require "t/test.pl";
} elsif ( -f "test.pl" ) {
  require "test.pl";
} else {
  die "ERROR: cannot find test.pl\n";
}

print "CountSigFigs...\n";
print "1..9\n"  if (! $runtests);

$tests="

0.003
1

0.103
3

1.0500
5

11.
2

11
2

110
2

110.
3

0
0

0.0
0

";

&test_Func(\&CountSigFigs,$tests,$runtests);

1;

