#############################################################################
##
#W orbit.g                  The SCSCP package             Alexander Konovalov
#W                                                               Steve Linton
##
#H $Id$
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


# Added for Sergey Shpectorov

DistributeObject:=function( obj )
local i, cookies;
cookies:=[];
for i in [ 1 .. Length(SCSCPservers) ] do
  if  PingSCSCPservice( SCSCPservers[i][1], SCSCPservers[i][2] ) <> fail then
    cookies[i] := StoreAsRemoteObject( obj, SCSCPservers[i][1], SCSCPservers[i][2] ); 
    EvaluateBySCSCP("ResetOrbits", [], SCSCPservers[i][1], SCSCPservers[i][2] );
  else
    Error( SCSCPservers[i][1],":",SCSCPservers[i][2]," is not responding !!!\n" );
  fi;   
od;
return cookies;
end;


IsElementOfKnownOrbit:=function( elt )
local i, calls, res, x;
calls:=[];
for i in [ 1 .. Length(SCSCPservers) ] do
  calls[i]:=NewProcess("IsKnownElement", [elt], SCSCPservers[i][1], SCSCPservers[i][2] );
od;
res := List( SynchronizeProcesses( calls ), x -> x.object);
return ForAny( res, x -> x = true );
end; 


NumberOfOrbits:=function( cookies, seeds, limit )
local nr, i, neworbplace, elt;
nr := 0;
for i in [ 1 .. Length(SCSCPservers) ] do
  nr := nr + EvaluateBySCSCP("NumberOfStoredOrbits", [], SCSCPservers[i][1], SCSCPservers[i][2] ).object;
od;
neworbplace:=0;
for elt in seeds do
  if not IsElementOfKnownOrbit( elt ) then
    nr := nr+1;
    if nr >= limit then
        return nr;
    fi;
    neworbplace := (neworbplace+1) mod Length(SCSCPservers);
    if neworbplace=0 then 
      neworbplace:=Length(SCSCPservers); 
    fi;
    EvaluateBySCSCP("NewOrbit", [ cookies[i], elt], SCSCPservers[i][1], SCSCPservers[i][2] );
  fi;
od;      
return nr;
end;

