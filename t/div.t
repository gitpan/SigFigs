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

print "divSF...\n";
print "1..4\n"  if (! $runtests);

$tests="

1.234
2.1
0.59

1.234
2.10
0.588

1.234
210
0.0059

1.234
210.
0.00588

";

&test_Func(\&divSF,$tests,$runtests);

1;

