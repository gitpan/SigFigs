package Math::SigFigs;

# Copyright (c) 1995-2005 Sullivan Beck. All rights reserved.
# This program is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.

########################################################################
# HISTORY
########################################################################

# Written by:
#    Sullivan Beck (sbeck@cpan.org)
# Any suggestions, bug reports, or donations :-) should be sent to me.

# Version 1.00  1996-12-05
#    Initial creation
#
# Version 1.01  1997-01-28
#    Used croak and changed die's to confess.
#    "101" is now returned as "101." .
#    Fixed where 9.99 wasn't being correctly returned with 1 sigfig.
#       Kyle Krom <kromk@pt.Cyanamid.COM>
#
# Version 1.02  2000-01-10
#    Fixed where 1249.01 wasn't correctly rounded to 1200.
#       Janna Wemekamp <jwemekam@erin.gov.au>
#
# Version 1.03  2003-09-11
#    Fixed a bug where I left off the sign.  Steve Reaser
#       <steve_reaser@webassign.net>
#    Fixed a bug in subSF where numbers ending in zero were truncated.
#       Andrew Grall <AGrall@dcds.edu>
#
# Version 1.04  2005-06-30
#    Complete rewrite of addSF.
#      - stopped using sprintf (which does not return the same results on
#        all platforms.
#      - replaced IsReal with Simplify.

########################################################################

require 5.000;
require Exporter;
use Carp;
@ISA = qw(Exporter);
@EXPORT = qw(FormatSigFigs
             CountSigFigs
);
@EXPORT_STD   = qw(FormatSigFigs CountSigFigs addSF subSF multSF divSF
                   VERSION);
@EXPORT_DEBUG = qw(LSP Simplify);
@EXPORT_OK = (@EXPORT_STD, @EXPORT_DEBUG);

%EXPORT_TAGS = (all => \@EXPORT_STD, debug => \@EXPORT_DEBUG);

$VERSION = 1.04;

use strict;

sub addSF {
  my($n1,$n2)=@_;
  $n1 = Simplify($n1);
  $n2 = Simplify($n2);
  return ()  if (! defined $n1  ||  ! defined $n2);
  return $n2 if ($n1==0);
  return $n1 if ($n2==0);

  my $m1 = LSP($n1);
  my $m2 = LSP($n2);
  my $m  = ($m1>$m2 ? $m1 : $m2);

  my($n) = $n1+$n2;
  my($s) = ($n<0 ? "-" : "");
  $n     = -1*$n  if ($n<0);          # n = 1234.44           5678.99
  $n =~ /^(\d*)/;
  my $i = ($1);                       # i = 1234              5678
  my $l = length($i);                 # l = 4

  if ($m>0) {                         # m = 5,4,3,2,1
    if ($l >= $m+1) {                 # m = 3,2,1; l-m = 1,2,3
      $n = FormatSigFigs($n,$l-$m);   # n = 1000,1200,1230    6000,5700,5680
    } elsif ($l == $m) {              # m = 4
      if ($i =~ /^[5-9]/) {
        $n = 1 . "0"x$m;              # n =                   10000
      } else {
        return 0;                     # n = 0
      }
    } else {                          # m = 5
      return 0;
    }

  } elsif ($i>0) {                    # n = 1234.44           5678.99
    $n = FormatSigFigs($n,$l-$m);     # m = 0,-1,-2,...

  } else {                            # n = 0.1234    0.00123   0.00567
    $n =~ /\.(0*)(\d+)/;
    my ($z,$d) = ($1,$2);
    $m = -$m;

    if ($m > length($z)) {            # m = -1,-2,..  -3,-4,..  -3,-4,..
      $n = FormatSigFigs($n,$m-length($z));

    } elsif ($m == length($z)) {      # m =           -2        -2
      if ($d =~ /^[5-9]/) {
        $n = "0." . "0"x($m-1) . "1"; # n =                     0.01
      } else {
        return 0;                     # n =           0
      }

    } else {                          # m =           -1        -1
      return 0;
    }
  }

  return "$s$n";
}

sub subSF {
  my($n1,$n2)=@_;
  if ($n2<0) {
    $n2 =~ s/\-//;
  } else {
    $n2 =~ s/^\+?/-/;
  }
  addSF($n1,$n2);
}

sub multSF {
  my($n1,$n2)=@_;
  $n1 = Simplify($n1);
  $n2 = Simplify($n2);
  return ()  if (! defined $n1  ||  ! defined $n2);
  return 0   if ($n1==0  or  $n2==0);
  my($m1)=CountSigFigs($n1);
  my($m2)=CountSigFigs($n2);
  my($m)=($m1<$m2 ? $m1 : $m2);
  my($n)=$n1*$n2;
  FormatSigFigs($n,$m);
}

sub divSF {
  my($n1,$n2)=@_;
  $n1 = Simplify($n1);
  $n2 = Simplify($n2);
  return ()  if (! defined $n1  ||  ! defined $n2);
  return 0   if ($n1==0);
  return ()  if ($n2==0);
  my($m1)=CountSigFigs($n1);
  my($m2)=CountSigFigs($n2);
  my($m)=($m1<$m2 ? $m1 : $m2);
  my($n)=$n1/$n2;
  FormatSigFigs($n,$m);
}

sub FormatSigFigs {
  my($N,$n)=@_;
  my($ret);
  $N = Simplify($N);
  return ""  if (! defined($N)  or  $n !~ /^\d+$/  or  $n<1);
  my($l,$l1,$l2,$m,$s)=();
  $N=~ s/\s+//g;               # Remove all spaces
  $N=~ s/^([+-]?)//;           # Remove sign
  $s=(defined $1 ? $1 : "");
  $N=~ s/^0+//;                # Remove all leading zeros
  $N=~ s/0+$//  if ($N=~/\./); # Remove all trailing zeros (when decimal point)
  $N=~ s/\.$//;                # Remove a trailing decimal point
  $N= "0$N"  if ($N=~ /^\./);  # Turn .2 into 0.2

  # If $N has fewer sigfigs than requested, pad it with zeros and return it.
  $m=CountSigFigs($N);
  if ($m==$n) {
    $N="$N."  if (length($N)==$n);
    return "$s$N";
  } elsif ($m<$n) {
    if ($N=~ /\./) {
      return "$s$N" . "0"x($n-$m);
    } else {
      $N=~ /(\d+)$/;
      $l=length($1);
      return "$s$N"  if ($l>$n);
      return "$s$N." . "0"x($n-$l);
    }
  }

  if ($N=~ /^([1-9]\d*)\.([0-9]*)/) {     # 123.4567  (l1=3, l2=4)
    ($l1,$l2)=(length($1),length($2));
    if ($n>=$l1) {                        # keep some decimal points
      $l=$n-$l1;
      ($l2>$l) && ($N=~ s/5$/6/);         # 4.95 rounds down... make it go up
      $ret=sprintf("%.${l}f",$N);
      $m=CountSigFigs($ret);
      if ($m==$n) {
        $ret="$ret."  if ($l==0 && $m==length($ret));
        return "$s$ret";
      }

      # special case 9.99 (2) -> 10.
      #              9.99 (1) -> 10

      $l--;
      if ($l>=0) {
        $ret=sprintf("%.${l}f",$N);
        $ret="$ret."  if ($l==0);
        return "$s$ret";
      }
      return "$s$ret";
    } else {
      my($a)=substr($N,0,$n);             # Turn 1234.56 into 123.456 (n=3)
      $N =~ /^$a(.*)\.(.*)$/;
      my($b,$c)=($1,$2);
      $N="$a.$b$c";
      $N=sprintf("%.0f",$N);              # Turn it to 123
      $N .= "0" x length($b);             # Turn it to 1230
      return "$s$N";
    }

  } elsif ($N=~ /^0\.(0*)(\d*)$/) {       # 0.0123
    ($l1,$l2)=(length($1),length($2));
    ($l2>$n) && ($N=~ s/5$/6/);
    $l=$l1+$n;
    $ret=sprintf("%.${l}f",$N);
    $m=CountSigFigs($ret);
    return "$s$ret"  if ($n==$m);

    # special cases 0.099 (1) -> 0.1
    #               0.99  (1) -> 1.

    $l--;
    $ret=sprintf("%.${l}f",$N);
    $m=CountSigFigs($ret);
    $ret="$ret."  if ($l==0);
    return "$s$ret"  if ($n==$m);
    $ret =~ s/0$//;
    return "$s$ret";
  }

  return 0  if ($N==0);

  if ($N=~ /^(\d+?)(0*)$/) {              # 123
    ($l1,$l2)=(length($1),length($2));
    ($l1>$n) && ($N=~ s/5(0*)$/6$1/);
    $l=$n;
    $m=sprintf("%.${l}f",".$N");          # .123
    if ($m>1) {
      $l--;
      $m=~ s/\.\d/\.0/  if ($l==0);
    } else {
      $m =~ s/^0//;
    }
    $m=~ s/\.//;
    $N=$m . "0"x($l1+$l2-$n);
    $N="$N."  if (length($N)==$n);
    return "$s$N";
  }
  "";

}

sub CountSigFigs {
  my($N)=@_;
  $N = Simplify($N);
  return ()  if (! defined($N));
  return 0   if ($N==0);

  my($tmp)=();
  if ($N=~ /^\s*[+-]?\s*0*([1-9]\d*)\s*$/) {
    $tmp=$1;
    $tmp=~ s/0*$//;
    return length($tmp);
  } elsif ($N=~ /^\s*[+-]?\s*0*\.0*(\d*)\s*$/) {
    return length($1);
  } elsif ($N=~ /^\s*[+-]?\s*0*([1-9]?\d*\.\d*)\s*$/) {
    return length($1)-1;
  }
  ();
}

########################################################################
# NOT FOR EXPORT
#
# These are exported above only for debug purposes.  They are not
# for general use.  They are not guaranteed to remain backward
# compatible (or even to exist at all) in future versions.
########################################################################

# This returns the power of the least sigificant digit.
sub LSP {
  my($n) = @_;
  $n =~ s/\-//;
  if ($n =~ /(.*)\.(.+)/) {
    return -length($2);
  } elsif ($n =~ /\.$/) {
    return 0;
  } else {
    return length($n) - CountSigFigs($n);
  }
}

# This prepares a number by converting it to it's simplest correct
# form.
sub Simplify {
  my($n)    = @_;
  return undef  if (! defined $n);
  return undef  if ($n !~ /^\s*([+-]?)\s*0*(\d+\.?\d*)\s*$/  and
                    $n !~ /^\s*([+-]?)\s*0*(\.\d+)\s*$/);
  $n="$1$2";
  return 0  if ($n==0);
  $n=~ s/\+//;
  return $n;
}

1;

########################################################################
########################################################################
# POD
########################################################################
########################################################################

=head1 NAME

Math::SigFigs - do math with correct handling of significant figures

=head1 SYNOPSIS

If you only need to use CountSigFigs and FormatSigFigs, use the first
form.  If you are going to be doing arithmetic, use the second line.

  use Math::SigFigs;
  use Math::SigFigs qw(:all);

The following routines do simple counting/formatting:

  $n=CountSigFigs($num);
  $num=FormatSigFigs($num,$n);

Use the following routines to do arithmetic operations.

  $num=addSF($n1,$n2);
  $num=subSF($n1,$n2);
  $num=multSF($n1,$n2);
  $num=divSF($n1,$n2);

=head1 DESCRIPTION

In many scientific applications, it is often useful to be able to format
numbers with a given number of significant figures, or to do math in
such a way as to maintain the correct number of significant figures.
The rules for significant figures are too complicated to be handled solely
using the sprintf function (unless you happen to be Randal Schwartz :-).

These routines allow you to correctly handle significan figures.

It can count the number of significan figures, format a number to a
given number of significant figures, and do basic arithmetic.

=head1 ROUTINES

=over 4

=item CountSigFigs

  $n=CountSigFigs($N);

This returns the number of significant figures in a number.  It returns
() if $N is not a number.

  $N      $n
  -----   --
  240     2
  240.    3
  241     3
  0240    2
  0.03    1
  0       0
  0.0     0

=item FormatSigFigs

  $str=FormatSigFigs($N,$n)

This returns a string containing $N formatted to $n significant figures.
This will work for all cases except something like "2400" formatted to
3 significant figures.

  $N     $n   $str
  ------ --   -------
  2400    1   2000
  2400    2   2400
  2400    3   2400
  2400    4   2400.
  2400    5   2400.0

  141     3   141.
  141     2   140

  0.039   1   0.04
  0.039   2   0.039

  9.9     1   10
  9.9     2   9.9
  9.9     3   9.90

=item addSF, subSF, multSF, divSF

These routines add/subtract/multiply/divide two numbers while maintaining
the proper number of significant figures.

=back

=head1 KNOWN PROBLEMS

=over 4

=item Without scientific notation, some numbers are ambiguous

These routines do not work with scientific notation (exponents).  As a
result, it is impossible to unambiguously format some numbers.  For
example,

  $str=FormatSigFigs("2400",3);

will by necessity return the string "2400" which does NOT have 3
significant figures.  This is not a bug.  It is simply a fundamental
problem with working with significant figures when not using scientific
notation.

=item A bug in some printf library calls on the Mac

One of the tests

   FormatSigFigs(0.99,1)  =>  1.

fails on at least some Mac OS versions.  It gives "0." instead of "1."
and comes when the call:

   printf("%.0f","0.99")

returns 0 instead of 1.  I have not added a workaround for this.

=back

=head1 AUTHOR

Sullivan Beck (sbeck@cpan.org)

=cut
