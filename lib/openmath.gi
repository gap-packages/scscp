#############################################################################
##
#W openmath.gi              The SCSCP package             Alexander Konovalov
#W                                                               Steve Linton
##
#H $Id$
##
#############################################################################


#InstallMethod( OMPut, 
#"for a univariate polynomial (polyu cd)", 
#true,
#[ IsOutputStream, IsUnivariatePolynomial ],
#0,
#function( stream, f )
#local coeffs, deg, nr;
#OMWriteLine( stream, [ "<OMA>" ] );
#OMIndent := OMIndent + 1;
#OMPutSymbol( stream, "polyu", "poly_u_rep" );
#OMPutVar( stream, IndeterminateOfUnivariateRationalFunction(f) );
#coeffs := CoefficientsOfUnivariatePolynomial(f);
#deg := DegreeOfLaurentPolynomial(f);
#for nr in [ deg+1, deg .. 1 ] do
#  if coeffs[nr] <> 0 then
#    OMPutApplication( stream, "polyu", "term", [ nr-1, coeffs[nr] ] );
#  fi;
#od;  
#OMIndent := OMIndent - 1;
#OMWriteLine( stream, [ "</OMA>" ] );
#end);


InstallMethod( OMPut, 
"for a (multivariate) polynomial (polyd1 cd)", 
true,
[ IsOutputStream, IsPolynomial ],
0,
function( stream, f )
local coeffs, deg, nr, defring, coeffring, nrindet, extrep, term, nvars, pows, i, pos;

if IsUnivariatePolynomial( f ) then

OMWriteLine( stream, [ "<OMA>" ] );
OMIndent := OMIndent + 1;
OMPutSymbol( stream, "polyd1", "DMP" );
OMWriteLine( stream, [ "<OMA>" ] );
OMIndent := OMIndent + 1;
OMPutSymbol( stream, "polyd1", "poly_ring_d_named" );
OMPut( stream, Rationals );
OMPutVar( stream, IndeterminateOfUnivariateRationalFunction(f) );
OMIndent := OMIndent - 1;
OMWriteLine( stream, [ "</OMA>" ] );
OMWriteLine( stream, [ "<OMA>" ] );
OMIndent := OMIndent + 1;
OMPutSymbol( stream, "polyd1", "SDMP" );
coeffs := CoefficientsOfUnivariatePolynomial(f);
deg := DegreeOfLaurentPolynomial(f);
for nr in [ deg+1, deg .. 1 ] do
  if coeffs[nr] <> 0 then
    OMPutApplication( stream, "polyd1", "term", [ coeffs[nr], nr-1 ] );
  fi;
od; 
OMIndent := OMIndent - 1;
OMWriteLine( stream, [ "</OMA>" ] );
OMIndent := OMIndent - 1;
OMWriteLine( stream, [ "</OMA>" ] );

else

defring := DefaultRing(f);
coeffring := CoefficientsRing( defring );
nrindet := Length(IndeterminatesOfPolynomialRing(defring) );

OMWriteLine( stream, [ "<OMA>" ] );
OMIndent := OMIndent + 1;
OMPutSymbol( stream, "polyd1", "DMP" );
OMWriteLine( stream, [ "<OMA>" ] );
OMIndent := OMIndent + 1;
OMPutSymbol( stream, "polyd1", "poly_ring_d" );
OMPut( stream, coeffring );
OMPut( stream, nrindet );
OMIndent := OMIndent - 1;
OMWriteLine( stream, [ "</OMA>" ] );
OMWriteLine( stream, [ "<OMA>" ] );
OMIndent := OMIndent + 1;
OMPutSymbol( stream, "polyd1", "SDMP" );
extrep := ExtRepPolynomialRatFun( f );
for nr in [ 1, 3 .. Length(extrep)-1 ] do
  term := [ extrep[nr+1] ];
  nvars := extrep[nr]{[1,3..Length(extrep[nr])-1]};
  pows := extrep[nr]{[2,4..Length(extrep[nr])]};
  for i in [1..nrindet] do
    pos := Position( nvars, i );
    if pos=fail then
      Add( term, 0);
    else
      Add( term, pows[pos] ); 
    fi;  
  od;
  OMPutApplication( stream, "polyd1", "term", term );
od; 
OMIndent := OMIndent - 1;
OMWriteLine( stream, [ "</OMA>" ] );
OMIndent := OMIndent - 1;
OMWriteLine( stream, [ "</OMA>" ] );

fi;

end);


InstallMethod( OMPut, 
"for a univariate polynomial (polyu cd)", 
true,
[ IsOutputStream, IsField ],
0,
function( stream, f )
if IsRationals(f) then
OMPut( stream, f );
elif HasDefiningPolynomial( f ) then
OMWriteLine( stream, [ "<OMA>" ] );
OMIndent := OMIndent + 1;
OMPutSymbol( stream, "field3", "field_by_poly" );
OMPut( stream, DefiningPolynomial( f ) );
OMIndent := OMIndent - 1;
OMWriteLine( stream, [ "</OMA>" ] );
else
  TryNextMethod();
fi;
end);