localorbits:=[];

ResetOrbits:=function()
localorbits:=[];
return true;
end;

NewOrbit := function( G, pnt )
local orb;
orb := Orbit( G, pnt );
Add( localorbits, orb );
return true;
end;

NewOrbitOnRight := function( G, pnt )
local orb;
orb := Orbit( G, pnt, OnRight );
Add( localorbits, orb );
return true;
end;

IsKnownElement:=function( elt )
local orb;
return ForAny( localorbits, orb -> elt in orb);
end;

NumberOfStoredOrbits:=function()
return Length(localorbits);
end;

InstallSCSCPprocedure( "ResetOrbits", ResetOrbits );
InstallSCSCPprocedure( "NewOrbit", NewOrbit );
InstallSCSCPprocedure( "NewOrbitOnRight", NewOrbitOnRight );
InstallSCSCPprocedure( "IsKnownElement", IsKnownElement );
InstallSCSCPprocedure( "NumberOfStoredOrbits", NumberOfStoredOrbits );
