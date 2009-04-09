#############################################################################
#
# This file contains some experimental code for SCSCP services,
# which is not included in the package release and collected here
# for easier release maintenance.
#
# $Id$
#
#############################################################################

#############################################################################
#
# List of necessary packages and other commands if needed
#
#############################################################################

LoadPackage("automata");
ReadPackage("scscp/par/automata.g");

#############################################################################
#
# Installation of procedures to make them available for WS 
#
#############################################################################

#############################################################################
#
# procedures for automata
#
InstallSCSCPprocedure( "EpsilonToNFA", EpsilonToNFA ); # from the 'automata' package
InstallSCSCPprocedure( "TwoStackSerAut", TwoStackSerAut );
InstallSCSCPprocedure( "DerivedStatesOfAutomaton", DerivedStatesOfAutomaton );

#############################################################################
#
# procedures to extend LAGUNA package
#
ReadPackage("laguna/lib/parunits.g");
InstallSCSCPprocedure( "WS_NormalizedUnitCFpower", WS_NormalizedUnitCFpower );
InstallSCSCPprocedure( "WS_NormalizedUnitCFcommutator", WS_NormalizedUnitCFcommutator );

#############################################################################
#
# procedures for MIP checks from the autiso package
#
if LoadPackage("autiso") = true then
	InstallSCSCPprocedure( "CheckBin512", bin -> [ bin,CheckBin(2,9, bin) ] );
fi;
