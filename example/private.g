#############################################################################
#
# This file contains some experimental code for SCSCP services,
# which is not included in the package release and collected here
# for easier release maintenance.
#
#############################################################################

#############################################################################
#
# List of necessary packages and other commands if needed
#
#############################################################################

#LoadPackage("automata");
#ReadPackage("scscp", "par/automata.g");

#############################################################################
#
# Installation of procedures to make them available for WS 
#
#############################################################################

#############################################################################
#
# procedures for automata
#
#InstallSCSCPprocedure( "EpsilonToNFA", EpsilonToNFA ); # from the 'automata' package
#InstallSCSCPprocedure( "TwoStackSerAut", TwoStackSerAut );
#InstallSCSCPprocedure( "DerivedStatesOfAutomaton", DerivedStatesOfAutomaton );


#############################################################################
#
# procedures for MIP checks from the autiso package
#
if LoadPackage("autiso") = true then
	InstallSCSCPprocedure( "CheckBin512", bin -> [ bin,CheckBin(2,9, bin) ] );
fi;

#############################################################################
#
# Karatsuba multiplication of polynomials
#
ReadPackage("scscp", "example/karatsuba.g");

KaratsubaPolynomialMultiplicationExtRepByString:=function(s1,s2)
return String( KaratsubaPolynomialMultiplicationExtRep( EvalString(s1), EvalString(s2) ) );
end;

InstallSCSCPprocedure("WS_Karatsuba", KaratsubaPolynomialMultiplicationExtRepByString, 
	"See Examples chapter in the SCSCP package manual", 2, 2 );

#############################################################################
#
# Some debugging tricks that we should not include in the public service
#
#############################################################################


#############################################################################
#
# ApplyFunction( <string with function name>, <list of arguments> );
#
# Allows to call GAP functions even if they are not installed as SCSCP 
# procedures, for example:
# EvaluateBySCSCP("ApplyFunction",["Factorial",[10]],"localhost",26133);  
# EvaluateBySCSCP("ApplyFunction",["Binomial",[50,10]],"localhost",26133);
#
ApplyFunction:=function( func, args )
return CallFuncList( EvalString( func ), args );
end;

InstallSCSCPprocedure( "ApplyFunction", ApplyFunction, 
	"1st argument is a string with the name of the function, the rest is the list of its arguments", 2, 2 );


#############################################################################
#
# EvaluateOpenMathCode( <OpenMath plain string> )
#
# Evaluates OpenMath code given as an input (without OMOBJ tags) wrapped in 
# OMPlainString, for example:
# EvaluateBySCSCP( "EvaluateOpenMathCode", 
#   [ OMPlainString("<OMA><OMS cd=\"arith1\" name=\"plus\"/><OMI>1</OMI><OMI>2</OMI></OMA>")],
#   "localhost",26133 ); 
EvaluateOpenMathCode:=function( omc );
return omc;
end;

InstallSCSCPprocedure( "EvaluateOpenMathCode", EvaluateOpenMathCode, 
	"Evaluates OpenMath code given as an input (without OMOBJ tags) wrapped in OMPlainString", 1, 1 );
	
	
#############################################################################
#
# ChangeInfoLevel( <n> )
#
# Changes InfoSCSCP level on the server without restarting it.
#
ChangeInfoLevel:=function( n )
SetInfoLevel( InfoSCSCP, n );
return true;
end;

InstallSCSCPprocedure( "ChangeInfoLevel", ChangeInfoLevel, 
	"To change InfoSCSCP level on the server without restarting", 1, 1 );
	
	
#############################################################################
#
# SCSCPRestoreErrorsOnServer( )
#
# After this call, the break loop will occur on the server again.
#
SCSCPRestoreErrorsOnServer:=function( )
RereadLib("error.g"); # to restore the library version of ErrorInner
return true;
end;

InstallSCSCPprocedure( "SCSCPRestoreErrorsOnServer", SCSCPRestoreErrorsOnServer, 
	"To make break loops happening on the server", 0, 0 );