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

print "multSF...\n";
print "1..4\n"  if (! $runtests);

$tests="

1.234
2.1
2.6

1.234
2.10
2.59

1.234
210
260

1.234
210.
259.

";

&test_Func(\&multSF,$tests,$runtests);

1;

