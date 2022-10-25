#############################################################################
#
# This is the SCSCP server configuration file.
# The service provider can start the server just by the command 
# $ gap liouvilleserver.g
#
#############################################################################

#############################################################################
#
# Load necessary packages and read external files. 
# Put here and other commands if needed.
#
#############################################################################

LogTo(); # to close log file if it was opened from .gaprc
LoadPackage("scscp");
LoadPackage("factint");

#############################################################################
#
# Procedures and functions available for the SCSCP server
# (you can also install procedures contained in other files,
# including standard GAP procedures and functions) by adding
# appropriate calls to InstallSCSCPprocedure below.
#
#############################################################################


#############################################################################

# Simple procedures for tests and demos
InstallSCSCPprocedure( "Identity", x -> x, "Identity procedure for tests", 1, 1 );
InstallSCSCPprocedure( "Factorial", Factorial, "See ?Factorial in GAP", 1, 1 );
InstallSCSCPprocedure( "Phi", Phi, "Euler's totient function, see ?Phi in GAP", 1, 1 );

#############################################################################
#
# We store the list of 3432 primes less than 32000, extending the 
# list of 168 primes less than 1000, that is defined in GAP
#
MakeReadWriteGlobal( "Primes" );
Primes := Filtered( [ 1 .. 32000 ], IsPrimeInt );;
MakeReadOnlyGlobal( "Primes" );


LiouvilleFunction:=function( n )
#
# For an integer n, the Liouville's function of n is equal to (-1)^r(n), 
# where r(n) is the number of prime factors of n, counted according to 
# their multiplicity, with r(1)=0.
#
if n=1 then
  return 1;
elif Length( FactorsInt(n) ) mod 2 = 0  then
  return 1;
else
  return -1;
fi;
end;


#############################################################################
#
# The summatory Liouville's function L(x) is the sum
# of values of LiouvilleFunction(n) for all n from [ 1 .. x ].
#
# G. Pólya in 1919 conjectured that L(x)<=0 for all x >=2.
#
# C.B.Haselgrove in 1958 proved that this conjecture is false
# and there are infinitely many integers x with L(x)>0, but
# he neither presented such x nor give the upper bound for 
# the minimal x with L(x)>0. 
#
# A computer-aided search reported in [ R. Sherman Lehman, 
# On Liouville's Function, Mathematics of Computation, Vol.14, 
# No.72 (Oct., 1960), pp.311-320 ] found the counterexample to 
# be L(906180359)=+1, without claiming its minimality.
#
# The smallest counterexample is n = 906150257, reported in
# [ M. Tanaka, A Numerical Investigation on Cumulative Sum of the 
# Liouville Function. Tokyo Journal of Mathematics 3, (1980) 187-189 ]
# The Pólya conjecture fails to hold for most values of n in the region 
# of 906150257 <= n <= 906488079. In this region, the function reaches 
# a maximum value of 829 at n = 906316571.
#
SummatoryLiouvilleFunction := function( x )
local s,n;
s := 0;
n := 1;
repeat
  s := s + LiouvilleFunction(n);
  n := n+1;
until n>x;
return s;
end;


PartialSummatoryLiouvilleFunction := function( interval )
#
# To parallelize computation of the summatory Liouville's
# function, we introduce its partial analogue to split the
# whole sum on partial sums that may be computed independently.
#
# The argument 'interval' is a list [x1,x2] of length two.
# The function returns the sum of LiouvilleFunction(n) for 
# all n from [ x1 .. x2 ].
#
local x1,x2,s,n;
x1:=interval[1];
x2:=interval[2];
s := 0;
n := x1;
repeat
  s := s + LiouvilleFunction(n);
  n := n+1;
until n>x2;
return s;
end;


InstallSCSCPprocedure( "LiouvilleFunction", LiouvilleFunction );
InstallSCSCPprocedure( "PartialSummatoryLiouvilleFunction", PartialSummatoryLiouvilleFunction );


#############################################################################
#
# Finally, we start the SCSCP server. 
#
#############################################################################

RunSCSCPserver( SCSCPserverAddress, SCSCPserverPort );
