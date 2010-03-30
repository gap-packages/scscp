#############################################################################
# 
# Functions for the computation of the lower bound of the number of orbits
# (this is the server's part, see scscp/examples/orbits.g for the client's)
# 
#############################################################################

# locally maintained list of known orbits
localorbits:=[];

# emptying the local list of known orbits
ResetOrbits:=function()
localorbits:=[];
return true;
end;

# computing new orbit for the default action
NewOrbit := function( G, pnt )
local orb;
orb := Orbit( G, pnt );
Add( localorbits, orb );
return true;
end;

# computing new orbit for the action OnRight
NewOrbitOnRight := function( G, pnt )
local orb;
orb := Orbit( G, pnt, OnRight );
Add( localorbits, orb );
return true;
end;

# checking if an element is from any of the locally stored known orbits
IsKnownElement:=function( elt )
local orb;
return ForAny( localorbits, orb -> elt in orb);
end;

# returning the number of locally stored known orbits
NumberOfStoredOrbits:=function()
return Length(localorbits);
end;


InstallSCSCPprocedure( "ResetOrbits", ResetOrbits );
InstallSCSCPprocedure( "NewOrbit", NewOrbit );
InstallSCSCPprocedure( "NewOrbitOnRight", NewOrbitOnRight );
InstallSCSCPprocedure( "IsKnownElement", IsKnownElement );
InstallSCSCPprocedure( "NumberOfStoredOrbits", NumberOfStoredOrbits );
