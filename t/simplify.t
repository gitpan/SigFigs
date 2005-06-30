#!/usr/local/bin/perl -w

use Math::SigFigs qw(:debug);
$runtests=shift(@ARGV);
if ( -f "t/test.pl" ) {
  require "t/test.pl";
} elsif ( -f "test.pl" ) {
  require "test.pl";
} else {
  die "ERROR: cannot find test.pl\n";
}

print "Simplify...\n";
print "1..12\n"  if (! $runtests);

$tests="

0.00
0

100
100

+ 100
100

 - 100
-100

-100.
-100.

-00100
-100

54.43
54.43

054.54
54.54

0.05
0.05

00.05
0.05

.055
.055

x.055
undef

";

&test_Func(\&Simplify,$tests,$runtests);

1;

