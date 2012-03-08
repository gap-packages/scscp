# Settings for the Kant server (adjust as necessary)
kantserver := "compute.risc.uni-linz.ac.at";
kantport := 26133;

heads:=GetAllowedHeads( kantserver, kantport );

SetInfoLevel(InfoSCSCP,4);

############################################################################
#
# Some basic examples first
#
EvaluateBySCSCP("Fibonacci", [200], kantserver, kantport : cd:="combinat1" );

EvaluateBySCSCP( "log", [3,27], kantserver, kantport : cd:="transc1" );

List ( [ "arccos", "arccot", "arccsc", "arcsec", "arcsin", "arctan", "cos", 
  "cosh", "cot", "coth", "csc", "csch", "exp", "ln", "sec", "sech", "sin", 
  "sinh", "tan", "tanh" ], proc -> 
  EvaluateBySCSCP( proc, [1], kantserver, kantport : cd:="transc1" ).object );

############################################################################
#
# Rank of the unit group of a maximal order
#
# Now we want to compute the rank of the unit group of the maximal order.
# alnuth.unit_rank does this, but it requires that its argument is a maximal
# order, the latter does not exist in GAP. Since KANT doesn't support 
# options to return cookie, we can't first call order1.maximal_order to 
# create remotely the maximal order and then call alnuth.unit_rank to get 
# its rank. Instead of that we need a helper function which will assemble 
# OpenMath representation for a maximal order from a ring and a polynomial.
# Another helper function assembles OpenMath representation for an element
# of a maximal order

SuppressOpenMathReferences := true;
x:=Indeterminate(Rationals,"x");

MaximalOrderOMString:=function( ring, pol )
return OMPlainString( Concatenation ( 
  "<OMA><OMS cd=\"order1\" name=\"maximal_order\"/>", 
  OMString( ring : noomobj ),
  OMString( pol : noomobj ),
  "</OMA>" ) );
end;

MaximalOrderElementOMString:=function ( ring, pol, vec )
return OMPlainString( Concatenation ( 
  "<OMA><OMS name=\"element_of\" cd=\"order2\"/>", 
  "<OMA><OMS cd=\"order1\" name=\"maximal_order\"/>", 
  OMString( ring : noomobj ),
  OMString( pol : noomobj ),
  "</OMA>",
  OMString( vec : noomobj ),  
  "</OMA>" ) );
end;


EvaluateBySCSCP( "unit_rank", [ MaximalOrderOMString( Rationals, x^4-2 ) ],
  kantserver, kantport : cd:="alnuth" );

EvaluateBySCSCP( "cardinality_unit_group", [ MaximalOrderOMString( Rationals, x^4-2 ) ],
  kantserver, kantport : cd:="alnuth" );
  
EvaluateBySCSCP( "cardinality_torsion_unit_group", [ MaximalOrderOMString( Rationals, x^4-2 ) ],
  kantserver, kantport : cd:="alnuth" ); 

EvaluateBySCSCP( "is_order_unit", [ MaximalOrderElementOMString( Rationals, x^4-2, [1,-1,1,-1] ) ],
  kantserver, kantport : cd:="alnuth" ); 
  
EvaluateBySCSCP( "is_torsion_unit", [ MaximalOrderElementOMString( Rationals, x^4-2, [1,-1,1,-1] ) ],
  kantserver, kantport : cd:="alnuth" ); 

EvaluateBySCSCP( "is_torsion_free_unit", [ MaximalOrderElementOMString( Rationals, x^4-2, [1,-1,1,-1] ) ],
  kantserver, kantport : cd:="alnuth" ); 

EvaluateBySCSCP( "has_norm_equation", [ 2, 4 ], kantserver, kantport : cd:="alnuth" ); 