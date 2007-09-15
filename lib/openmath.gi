#############################################################################
##
#W openmath.gi              The SCSCP package             Alexander Konovalov
#W                                                               Steve Linton
##
#H $Id:$
##
#############################################################################

InstallMethod( OMPut, 
"for a univariate polynomial (polyu cd)", 
true,
[ IsOutputStream, IsUnivariatePolynomial ],
0,
function( stream, f )
local coeffs, deg, nr;
OMWriteLine( stream, [ "<OMA>" ] );
OMIndent := OMIndent + 1;
OMPutSymbol( stream, "poly_u_rep", "polyu" );
OMPutVar( stream, IndeterminateOfUnivariateRationalFunction(f) );
coeffs := CoefficientsOfUnivariatePolynomial(f);
deg := DegreeOfLaurentPolynomial(f);
for nr in [ deg+1, deg .. 1 ] do
  if coeffs[nr] <> 0 then
    OMPutApplication( stream, "polyu", "term", [ nr-1, coeffs[nr] ] );
  fi;
od;  
OMIndent := OMIndent - 1;
OMWriteLine( stream, [ "</OMA>" ] );
end);