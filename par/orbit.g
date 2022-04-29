#############################################################################
##
#W orbit.g                  The SCSCP package              Olexandr Konovalov
#W                                                               Steve Linton
##
#############################################################################

ParOrbit:=function( G, n, services )

local hostnames, ports, nrservices, status, i, port, remoteG, orbit, 
currentposition, processes, nexttask, nr, waitinglist, descriptors,
setorbit, nrdesc, result, oldlength, r;

if Length( services[1] ) <> Length( services[2] ) then
  Error( "The third argument must be a list of two listst of equal length,\n",
         "the first is a list of hostnames and the second a list of port numbers!\n" );
fi;

hostnames:=services[1];
ports :=services[2];
nrservices := Length(ports);
status := [ ];
remoteG := [];

for i in [ 1 .. nrservices ] do
  if  PingSCSCPservice( hostnames[i], ports[i] ) then
    status[i]:=1; # alive and ready to accept
    remoteG[i] := StoreAsRemoteObject( G, hostnames[i], ports[i] ); 
  else
    status[i]:=0; # not alive  
    Print( hostnames[i],":",ports[i]," is not responding and will not be used!\n" );
  fi;   
od;

orbit := [ n ];
setorbit := [ n ];
currentposition := 0;
processes:=[];

while true do
  # is next task available?
  while currentposition<Length(orbit) do
    # search for next available service
    nr := Position( status, 1 );
    if nr<>fail then
      # there is a service number 'nr' that is ready to accept procedure call
      currentposition := currentposition + 1;
      processes[nr] := NewProcess( "PointImages", 
                                   [ remoteG[nr], orbit[currentposition] ], 
                                   hostnames[nr], ports[nr] );
      Print("Client --> ", hostnames[nr], ":", ports[nr], " : ", orbit[currentposition], "\n" );
      status[nr] := 2; # we are waiting to hear from this service
    else
      break; # all services are busy
    fi;
  od;  
  # see are there any waiting tasks
  waitinglist:= Filtered( [ 1 .. nrservices ], i -> status[i]=2 );
  if Length(waitinglist)=0 then
    # no next tasks and no waiting tasks - orbit completed
    return orbit;
  fi;
  # waiting until any of the running tasks will be completed
  descriptors := List( processes{waitinglist}, s -> IO_GetFD( s![1]![1] ) );  
  IO_select( descriptors, [ ], [ ], 60*60, 0 );
  nrdesc := First( [ 1 .. Length(descriptors) ], i -> descriptors[i]<>fail );
  nr := waitinglist[ nrdesc ];
  result := CompleteProcess( processes[nr] ).object;
  Print( hostnames[nr], ":", ports[nr], " --> Client ", " : ",  result, "\n" );
  status[nr]:=1;
  oldlength := Length(orbit);
  for r in result do
    if not r in setorbit then 
      Add( orbit, r );
      AddSet( setorbit, r );
     fi;
  od;
od;
end;



#############################################################################
# 
# Functions for the computation of the lower bound of the number of orbits
# (this is the client's part, see scscp/examples/orbits.g for the server's)
# 
#############################################################################


#############################################################################
#
# DistributeObject( <obj> ) 
#
# Takes an object <obj> and creates its remote copies on all servers from
# the list SCSCPservers. Returns a list of corresponding cookies. 
#
DistributeObject:=function( obj )
local i, cookies;
cookies:=[];
for i in [ 1 .. Length(SCSCPservers) ] do
  if  PingSCSCPservice( SCSCPservers[i][1], SCSCPservers[i][2] ) <> fail then
    cookies[i] := StoreAsRemoteObject( obj, SCSCPservers[i][1], SCSCPservers[i][2] ); 
    EvaluateBySCSCP("ResetAllOrbits", [], SCSCPservers[i][1], SCSCPservers[i][2] );
  else
    Error( SCSCPservers[i][1],":",SCSCPservers[i][2]," is not responding !!!\n" );
  fi;   
od;
return cookies;
end;


############################################################################
#
# IsElementOfKnownOrbit( <elt> ) 
#
# Checks in parallel if an element <elt> is contained in one of known orbits
# distributed across servers from the list SCSCPservers.
#
IsElementOfKnownOrbit:=function( elt )
local i, calls, res, x;
calls:=[];
for i in [ 1 .. Length(SCSCPservers) ] do
  calls[i]:=NewProcess("IsKnownElement", [elt], SCSCPservers[i][1], SCSCPservers[i][2] );
od;
res := FirstTrueProcess( calls );
return res = true;
end; 


############################################################################
#
# ResetAllOrbits( ) 
#
# Empties all lists of orbits on each server from the list SCSCPservers.
#
ResetAllOrbits:=function()
local i;
for i in [ 1 .. Length(SCSCPservers) ] do
  EvaluateBySCSCP("ResetOrbits", [], SCSCPservers[i][1], SCSCPservers[i][2] );
od;
end;


############################################################################
#
# NumberOfOrbits( <cookies>, <seeds>, <limit> )
#
# After asking servers from the list SCSCPserver about the number of known
# orbits, computes new orbits for elements from the list <seeds> until the
# resulting number of orbits will be greater or equal than <limit>, and 
# returns this limit. Otherwise, if the limit will not be achieved, will 
# run the computation for all elements from <seeds> and will return the
# resulting number of orbits.
#
NumberOfOrbits:=function( cookies, seeds, limit )
local nr, i, elt;
# ask servers about the known number of orbits
nr := 0;
for i in [ 1 .. Length(SCSCPservers) ] do
  nr := nr + EvaluateBySCSCP("NumberOfStoredOrbits", [], SCSCPservers[i][1], SCSCPservers[i][2] ).object;
od;
# When needed, the new orbit will be created at the server number i
# An idea: option to specify the threshold for creating an orbit on the
# next server in the pool (default is one, thus, the orbits are 
# created round-robin) as in the initial version. Remembering how
# many servers actually keep orbits and asking only them in parallel.
i:=0;
for elt in seeds do
  if not IsElementOfKnownOrbit( elt ) then
    nr := nr+1;
    if nr >= limit then
        return nr;
    fi;
    i := (i+1) mod Length(SCSCPservers);
    if i=0 then 
      i:=Length(SCSCPservers); 
    fi;
    # Could be "NewOrbitOnRight" in some applications
    EvaluateBySCSCP("NewOrbit", [ cookies[i], elt], SCSCPservers[i][1], SCSCPservers[i][2] );
  fi;
od;      
return nr;
end;

