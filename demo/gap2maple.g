# Settings for the Maple server (adjust as necessary)
mapleserver := "place31.placementtester.com";
mapleport := 26133;

GetAllowedHeads( mapleserver, mapleport );

SetInfoLevel(InfoSCSCP,4);

############################################################################
#
# NumberOfIntegerPartitions
#
# First we demonstrate a simple call of the function of the type Int->Int.
# This will give the ultimate answer
EvaluateBySCSCP("NumberOfIntegerPartitions",[10],
  mapleserver, mapleport : cd:="scscp_transient_maple" );

############################################################################
#
# IntegerFactorization
#
EvaluateBySCSCP("IntegerFactorization",[10^42+1],
  mapleserver, mapleport : cd:="scscp_transient_maple" );  
# now the argument is a prime
EvaluateBySCSCP("IntegerFactorization",[848654483879497562821],
  mapleserver, mapleport : cd:="scscp_transient_maple" );
# ERROR: Maple fails at the next call, while GAP does it in a moment:
# gap> FactorsInt(2^256 + 1);  
# [ 1238926361552897, 93461639715357977769163558199606896584051237541638188580280321 ]
# When Maple returns an error, GAP hangs, and the only remedy is to terminate it.
# - at least after the error message GAP should be able to proceed
# - why does Maple give up on this input?
EvaluateBySCSCP("IntegerFactorization",[2^256+1],
mapleserver, mapleport : cd:="scscp_transient_maple" );
    
############################################################################
#
# UnivariateRootFinding
#
# First we need a helper function taking a polynomial and calling the
# procedure with a list of its arguments
UnivariateRootFindingWithMaple:=function( f )
return EvaluateBySCSCP( "UnivariateRootFinding",
  [ CoefficientsOfUnivariatePolynomial(f) ], 
  mapleserver, mapleport : cd:="scscp_transient_maple" ).object;
end;  

# now create polynomials, find their roots and verify the result

x:=Indeterminate(Rationals,"x");

# RootFinding:-Isolate(6*x-2*x^2-10000*x^3);
#     [x = -0.02459510155, x = 0., x = 0.02439510155]
f:=6*x-2*x^2-10000*x^3;
res := UnivariateRootFindingWithMaple(f);
List( res, z -> Value(f,z) );

# RootFinding:-Isolate(x^4-3*x^2+2);
#     [x = -1.414213562, x = -1., x = 1., x = 1.414213562]
f:=x^4-3*x^2+2;
res := UnivariateRootFindingWithMaple(f);
List( res, z -> Value(f,z) );

############################################################################
#
# IndefiniteIntegration
#
# In this example, we form valide Maple input from OpenMath symbols for 
# objects which are non-native for GAP. The result contains cos(x) so 
# GAP can't evaluate it, but we may suppress evaluattion, request back 
# a parsed three which then may be inpected in GAP. 
#
sin:=OMPlainString("<OMA><OMS cd=\"transc1\" name=\"sin\"/><OMV name=\"x\"/></OMA>");
varx:=OMPlainString("<OMV name=\"x\"/>");
res:=EvaluateBySCSCP("IndefiniteIntegration",[sin,varx],
  mapleserver, mapleport : cd:="scscp_transient_maple", output:="tree" );;
res.object.content[2].content[2].content[3].content;  
# ERROR: We may also try to get back the result as a cookie, and then later 
# use that cookie as an argument in the next example, but this does not work 
int:=EvaluateBySCSCP("IndefiniteIntegration",[sin,varx],
  mapleserver, mapleport : cd:="scscp_transient_maple", output:="cookie" );;
# results in an error:
# Error, cannot lock repository, /usr/local/apache-tomcat-6.0.32/webapps/map\
# lenet/WEB-INF/scscpdata//scscp-store.mla

############################################################################
#
# DefiniteIntegration
#
sin:=OMPlainString("<OMA><OMS cd=\"transc1\" name=\"sin\"/><OMV name=\"x\"/></OMA>");
varx:=OMPlainString("<OMV name=\"x\"/>");
range:=OMPlainString("<OMA><OMS cd=\"interval1\" name=\"interval\"/><OMI>0</OMI><OMS cd=\"nums1\" name=\"pi\"/></OMA>");
res:=EvaluateBySCSCP("DefiniteIntegration",[sin,varx,range],
  mapleserver, mapleport : cd:="scscp_transient_maple" );
# ERROR: the next example doesn't work since the response contains sin(1)
# which GAP is unable to parse. Does it make sense to change Maple's 
# DefiniteIntegration in a way that it will always return the numerical value?
range:=[0..1];
res:=EvaluateBySCSCP("DefiniteIntegration",[sin,varx,range],
  mapleserver, mapleport : cd:="scscp_transient_maple" );

############################################################################
#
# Solve
#
# Like above, we may form OpenMath input and then call Maple
varx:=OMPlainString("<OMV name=\"x\"/>");
res:=EvaluateBySCSCP("Solve",[varx],
  mapleserver, mapleport : cd:="scscp_transient_maple" );
# Polynomial x^2-1 using arith1 CD to please Maple  
x2m1:=OMPlainString( "<OMA><OMS cd=\"arith1\" name=\"plus\"/><OMA>\
<OMS cd=\"arith1\" name=\"power\"/><OMV name=\"x\"/><OMI>2</OMI></OMA>\
<OMI>-1</OMI></OMA>");
res:=EvaluateBySCSCP("Solve",[x2m1],
  mapleserver, mapleport : cd:="scscp_transient_maple" );
# Now the same with 2*x^2-2 
2x2m2:=OMPlainString( "<OMA><OMS cd=\"arith1\" name=\"plus\"/><OMA>\
<OMS cd=\"arith1\" name=\"times\"/><OMI>2</OMI><OMA>\
<OMS cd=\"arith1\" name=\"power\"/><OMV name=\"x\"/><OMI>2</OMI></OMA>\
</OMA><OMI>-2</OMI></OMA>");
res:=EvaluateBySCSCP("Solve",[2x2m2],
  mapleserver, mapleport : cd:="scscp_transient_maple" ); 
# Now the same with x^2-2 (observe the result expressed in terms of roots of unity)
x2m2:=OMPlainString( "<OMA><OMS cd=\"arith1\" name=\"plus\"/><OMA>\
<OMS cd=\"arith1\" name=\"power\"/><OMV name=\"x\"/><OMI>2</OMI></OMA>\
<OMI>-2</OMI></OMA>");
res:=EvaluateBySCSCP("Solve",[x2m2],
  mapleserver, mapleport : cd:="scscp_transient_maple" );
# ERROR: however, x^3-2 does not work:
x3m2:=OMPlainString( "<OMA><OMS cd=\"arith1\" name=\"plus\"/><OMA>\
<OMS cd=\"arith1\" name=\"power\"/><OMV name=\"x\"/><OMI>3</OMI></OMA>\
<OMI>-2</OMI></OMA>");
res:=EvaluateBySCSCP("Solve",[x2m2],
  mapleserver, mapleport : cd:="scscp_transient_maple" );
#I Received message: 
#<OMOBJ><OMATTR><OMATP><OMS cd='scscp1' name='call_id'/><OMSTR>138.251.209.14:53245:0wngLrok</OMSTR\
#><OMS cd='scscp1' name='info_memory'/><OMI>2759336</OMI><OMS cd='scscp1' name='info_runtime'/><OMI\
#>77</OMI></OMATP><OMA><OMS cd='scscp1' name='procedure_completed'/><OMA><OMS cd='arith1' name='pow\
#er'/><OMI>2</OMI><OMA><OMS cd='arith1' name='divide'/><OMI>1</OMI><OMI>3</OMI></OMA></OMA></OMA></\
#OMATTR></OMOBJ>
##I  <?scscp end ?>
#Error, ^ cannot be used here to compute roots (use `RootInt' instead?) called from
#x[1] ^ x[2] called from
#...
# The reason is that GAP can't compute cubic root from 2. I can switch to
# floating point computations here, but the server returning to me floats
# would be probably more generic and useful for other systems too...

# Now let's create a helper function which will take a polynomial and
# print it using arith1 CD for the compatibility with Maple OpenMath-parsing
# capabilities

OMPlainStringByUnivariatePol:=function( f )
local s, c, i, a0, x, t;
c:=CoefficientsOfUnivariatePolynomial(f);
a0:=OMString(c[1]:noomobj);
if Length(c)=1 then
  return OMPlainString( a0 );
else
x:="<OMV name=\"x\"/>";
s:=[ a0 ];
for i in [ 2 .. Length(c) ] do
  if c[i]<>0 then
    if i=1 then
      t:=x;
    else
      t:=Concatenation("<OMA><OMS cd=\"arith1\" name=\"power\"/>", 
           x, OMString(i-1:noomobj), "</OMA>" );
    fi;
    if not IsOne(c[i]) then
      t:=Concatenation("<OMA><OMS cd=\"arith1\" name=\"times\"/>",
           OMString(c[i]:noomobj), t,  "</OMA>" );
    fi;
    Add( s, t );
  fi;  
od;
s:=Concatenation( s );
return OMPlainString( Concatenation( "<OMA><OMS cd=\"arith1\" name=\"plus\"/>", s, "</OMA>" ) );
fi;
end;

# Another helper function to take a polynomial and call Maple server

SolveWithMaple:=function( f )
return EvaluateBySCSCP("Solve",[OMPlainStringByUnivariatePol(f)],
  mapleserver, mapleport : cd:="scscp_transient_maple" ).object;
end;  

# Now find a solution (possibly non-unique) of the equation

x:=Indeterminate(Rationals,"x");
f:=6*x-2*x^2-10000*x^3;
r := SolveWithMaple( f );
Value( f, r );

# ERROR: f:=1+16*x-2*x^2-5*x^3 produces 
# <OMA><OMS cd='complex1' name='complex_cartesian'/><OMI>60</OMI></OMA>
# but complex_cartesian must have two arguments, so this is an error
# in Maple generating OpenMath code.

############################################################################

# So far we did not use the following procedures
# <OMS cd = 'scscp_transient_maple' name = 'PolynomialExpansion'/>
# <OMS cd = 'scscp_transient_maple' name = 'Differentiate'/>
# where
# PolynomialExpansion takes one argument: polynomial
# Differentiate takes two arguments: polynomial and a variable
# since they require an argument as a polynomial.
# We can already print polynomials in OpenMath in a way acceptable
# by Maple, but to parse the result, we have to make GAP capable of
# reading polynomials in the same format.
# Another alternative is to set another service passing polynomials 
# as lists of coefficients.

# Another services which we did not try yet are
# <OMS cd = 'scscp_transient_maple' name = 'MinimizeLinearFunction'/>
# <OMS cd = 'scscp_transient_maple' name = 'MaximizeLinearFunction'/>
# which take two arguments: a polynomial and a set of constraints
# (this is a better simplex[minimize])
# We may try them as well, having valid examples of their calls,
# reusing OMPlainStringByUnivariatePol from above.