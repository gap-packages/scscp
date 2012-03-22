############################################################################
#
# Parallelised method to compute minimal distance for linear codes
#
LoadPackage("scscp");
LoadPackage("guava");

InstallMethod( MinimumDistance, "parallel attribute method for linear codes", 
    true, [IsLinearCode], 0, 
function(C) 
	local  k, i, j, G, F, zero, ListOfWeightVecFFE, minwt, num, n, l, 
	# new local variables
	remoteG, remoteF, remotezero, s;
	# new auxiliary code
    if not ForAny( SCSCPservers, s -> PingSCSCPservice(s[1],s[2]) = true ) then
      Print("No SCSCP servers found - using sequential version of MinimumDistance ... \n");
      TryNextMethod();
    fi;
    Print("Using parallel version of MinimumDistance ... \n");
    # auxiliary part ends here
    # now existing code from GUAVA package
	if IsBound(C!.upperBoundMinimumDistance) and 
	   IsBound(C!.lowerBoundMinimumDistance) and 
	   C!.upperBoundMinimumDistance = C!.lowerBoundMinimumDistance then 
		return C!.lowerBoundMinimumDistance;   
    fi;
    F := LeftActingDomain(C);
    n := WordLength(C);
    zero := Zero(F)*NullVector(n); 
	G := GeneratorMat(C);
    minwt:=n;
    ########################################################################
    # Old sequential code from the GUAVA package
    # for i in [1..Length(G)] do
    #   AClosestVec:=AClosestVectorCombinationsMatFFEVecFFE(G, F, zero, i, 1);
    #   if WeightVecFFE(AClosestVec)<minwt then
    #     minwt := WeightVecFFE(AClosestVec);
    #   fi;
    # od;
    ########################################################################
    # New parallel code 
    for s in [1..Length(SCSCPservers)] do
      if EvaluateBySCSCP( "ResetMinimumDistanceService", 
           [ IO_PickleToString(G), F, IO_PickleToString(zero) ], 
           SCSCPservers[s][1], SCSCPservers[s][2] ).object <> true then
        Error("Data initialisation error!!!\n");
      fi;                 
    od;
    ListOfWeightVecFFE := ParListWithSCSCP( 
                            [1..Length(G)], 
                            "AClosestVectorCombinationsMatFFEVecFFE" );
    minwt := Minimum( ListOfWeightVecFFE );
    # Parallelisation finishes here 
    ########################################################################
    # now return results
    C!.lowerBoundMinimumDistance := minwt; 
    C!.upperBoundMinimumDistance := minwt;
return(minwt);
end);

############################################################################                           
##
#E
