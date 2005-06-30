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

print "LSP...\n";
print "1..6\n"  if (! $runtests);

$tests="

100
2

110
1

110.
0

110.3
-1

100.
0

-3.20
-2

";

&test_Func(\&LSP,$tests,$runtests);

1;

