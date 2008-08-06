#############################################################################
##
#W openmath.gi              The SCSCP package             Alexander Konovalov
#W                                                               Steve Linton
##
#H $Id$
##
#############################################################################


#############################################################################
#
# OMPut for a univariate polynomial (polyu.poly_u_rep)
#
# This was written during the visit of Mickael Gastineau for quick
# compatibility with the TRIP system and later was commented out 
# because of switching to the 'polyd1' CD.
#
#InstallMethod( OMPut, 
#"for a univariate polynomial (polyu.poly_u_rep)", 
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


#############################################################################
#
# OMPut for an algebraic element of an algebraic extension
# (commented out because of switching to field4.field_by_poly_vector)
#
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