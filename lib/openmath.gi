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

InstallMethod( OMPutReference, 
"for a stream and an object with reference",
true,
[ IsOutputStream, IsObject ],
0,
function( stream, x )
if HasOMReference( x ) then
   OMWriteLine( stream, [ "<OMR href=\"", OMReference( x ), "\" />" ] );
else   
   OMPut( stream, x );
fi;
end);


InstallMethod( OMPut,
"for a polynomial ring",
true,
[ IsOutputStream, IsPolynomialRing ],
0,
function( stream, r )

if Length( IndeterminatesOfPolynomialRing( r ) ) = 1 then

  SetOMReference( r, Concatenation("polyring", String(Random([1..10000]) ) ) );
  OMWriteLine( stream, [ "<OMA id=\"", OMReference( r ), "\" >" ] );
  OMIndent := OMIndent + 1;
  OMPutSymbol( stream, "polyd1", "poly_ring_d_named" );
  OMPut( stream, CoefficientsRing( r ) );
  OMPutVar( stream, IndeterminatesOfPolynomialRing( r )[1] );
  OMIndent := OMIndent - 1;
  OMWriteLine( stream, [ "</OMA>" ] );

else

  SetOMReference( r, Concatenation("polyring", String(Random([1..10000]) ) ) );
  OMWriteLine( stream, [ "<OMA id=\"", OMReference( r ), "\" >" ] );
  OMIndent := OMIndent + 1;
  OMPutSymbol( stream, "polyd1", "poly_ring_d" );
  OMPut( stream, CoefficientsRing( r ) );
  OMPut( stream, Length( IndeterminatesOfPolynomialRing( r ) ) );
  OMIndent := OMIndent - 1;
  OMWriteLine( stream, [ "</OMA>" ] );

fi;
end);
 

InstallOtherMethod( OMPut, 
"for a polynomial ring and a (uni- or multivariate) polynomial (polyd1 cd)", 
true,
[ IsOutputStream, IsPolynomialRing, IsPolynomial ],
0,
function( stream, r, f )
local coeffs, deg, nr, coeffring, nrindet, extrep, term, nvars, pows, i, pos;

if not f in r then
  Error( "OMPut : the polynomial ", f, " is not in the polynomial ring ", r, "\n" );
fi;

if IsUnivariatePolynomial( f ) then

OMWriteLine( stream, [ "<OMA>" ] );
OMIndent := OMIndent + 1;
OMPutSymbol( stream, "polyd1", "DMP" );
OMPutReference( stream, r );
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

coeffring := CoefficientsRing( r );
nrindet := Length(IndeterminatesOfPolynomialRing( r ) );

OMWriteLine( stream, [ "<OMA>" ] );
OMIndent := OMIndent + 1;
OMPutSymbol( stream, "polyd1", "DMP" );
OMPutReference( stream, r );
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
"for a (uni- or multivariate) polynomial in the default ring (polyd1 cd)", 
true,
[ IsOutputStream, IsPolynomial ],
0,
function( stream, f )
OMPut( stream, DefaultRing(f), f );
end);


InstallMethod( OMPut,
"for algebraic extensions",
true,
[ IsOutputStream, IsAlgebraicExtension ],
0,
function( stream, f )
OMWriteLine( stream, [ "<OMA>" ] );
OMIndent := OMIndent + 1;
OMPutSymbol( stream, "field3", "field_by_poly" );
OMPut( stream, LeftActingDomain(f));
OMPut( stream, DefiningPolynomial(f));
OMIndent := OMIndent - 1;
OMWriteLine( stream, [ "</OMA>" ] );  
end);    


#InstallMethod( OMPut, 
#"for an algebraic element of an algebraic extension", 
#true,
#[ IsOutputStream, IsAlgebraicElement ],
#0,
#function( stream, a )
#local  fam, anam, ext, c, i, is_plus, is_times, is_power;
#fam := FamilyObj( a );
#anam := fam!.indeterminateName;
#ext := ExtRepOfObj(a);
#if Length( Filtered( ext, c -> not IsZero(c) ) ) > 1 then 
#    is_plus := true;
#    OMWriteLine( stream, [ "<OMA>" ] );
#    OMIndent := OMIndent + 1;
#    OMPutSymbol( stream, "arith1", "plus" );
#else
#  is_plus := false;    
#fi;
#for i  in [ 1 .. Length(ext) ]  do
#    if ext[i] <> fam!.baseZero  then
#        if i=1 then
#            OMPut( stream, ext[i] );
#        else
#            if ext[i] <> fam!.baseOne then
#                is_times := true;
#                OMWriteLine( stream, [ "<OMA>" ] );
#                OMIndent := OMIndent + 1;
#                OMPutSymbol( stream, "arith1", "times" );   
#                OMPut( stream, ext[i] );
#            else
#                is_times := false;
#            fi;    
#            if i>2 then
#                is_power:=true;
#                OMWriteLine( stream, [ "<OMA>" ] );
#                OMIndent := OMIndent + 1;
#                OMPutSymbol( stream, "arith1", "power" );  
#            else
#                is_power := false;    
#            fi;     
#            OMPutVar( stream, anam );
#            if is_power then
#                OMPut( stream, i-1 );
#                OMIndent := OMIndent - 1;
#                OMWriteLine( stream, [ "</OMA>" ] );
#            fi;
#            if is_times then
#                OMIndent := OMIndent - 1;
#                OMWriteLine( stream, [ "</OMA>" ] );              
#            fi;
#        fi;
#    fi;
#od;       
#if is_plus then
#    OMIndent := OMIndent - 1;
#    OMWriteLine( stream, [ "</OMA>" ] );  
#fi;                  
#end);

InstallMethod( OMPut, 
"for an algebraic element of an algebraic extension", 
true,
[ IsOutputStream, IsAlgebraicElement ],
0,
function( stream, a )
OMWriteLine( stream, [ "<OMA>" ] );
OMIndent := OMIndent + 1;
OMPutSymbol( stream, "field4", "field_by_poly_vector" );
OMWriteLine( stream, [ "<OMA>" ] );
OMIndent := OMIndent + 1;
OMPutSymbol( stream, "field3", "field_by_poly" );
OMPut( stream, FamilyObj(a)!.baseField );
OMPut( stream, FamilyObj(a)!.poly );
OMIndent := OMIndent - 1;
OMWriteLine( stream, [ "</OMA>" ] );  
OMPut( stream, ExtRepOfObj(a) );
OMIndent := OMIndent - 1;
OMWriteLine( stream, [ "</OMA>" ] );  
end); 