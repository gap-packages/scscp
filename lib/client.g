#############################################################################
##
#W client.g                 The SCSCP package             Alexander Konovalov
#W                                                               Steve Linton
##
#H $Id$
##
#############################################################################


#############################################################################
#
# PingWebService( server, port )
#
InstallGlobalFunction( PingWebService,
function( server, port )
local stream, initmessage, rt;
stream := InputOutputTCPStream( server, port );
if stream <> fail then
  initmessage := ReadLine( stream );
  Info( InfoSCSCP, 1, "Got connection initiation message ", initmessage );
  CloseStream(stream); 
  return true;
else
  return fail;
fi;    
end);


#############################################################################
#
# PingStatistic( server, port, nr )
#
InstallGlobalFunction( PingStatistic,
function( server, port, nr )
local stream, initmessage, i, rt, rt1, rt2, res, t, 
      nr_good, nr_lost, min_time, max_time;
nr_good := 0;
nr_lost := 0;
rt:=0;
max_time := 0;
min_time := infinity;
for i in [ 1 .. nr ] do
  rt1:=Runtime();
  stream := InputOutputTCPStream( server, port );
  if stream <> fail then
    initmessage := ReadLine( stream );
    Info( InfoSCSCP, 1, "Got connection initiation message nr ", i, " : ", initmessage );
    rt2:=Runtime();
    t:=rt2-rt1;
    CloseStream(stream); 
    res := true;
  else
    res := false;
  fi; 
  if res then 
    nr_good := nr_good + 1;  
    rt := rt + t;
    if t < min_time then
      min_time := t;
    elif t > max_time then
      max_time := t;
    fi;     
  else
    nr_lost := nr_lost + 1;  
  fi;
od;
Print( nr, " packets transmitted, ", 
       nr_good, " received, ", 
       Float( 100*(nr_lost/nr) ), "% packet loss, time ", rt , "ms\n" );
if nr_good > 0 then       
       Print( "min/avg/max = ", [ min_time, Float(rt/nr_good), max_time], "\n" );
fi;      
end);


#############################################################################
#
# EvaluateBySCSCP( command, listargs, server, port )
#
InstallGlobalFunction( EvaluateBySCSCP,
function( command, listargs, server, port )

local stream, initmessage, session_id, result, omtext, localstream,
      return_cookie, attribs, ns, server_scscp_version;

if ValueOption("return_cookie") <> fail then
  return_cookie := ValueOption( "return_cookie" );
else
  return_cookie := false;  
fi;

if ValueOption("namespace") <> fail then
  ns := ValueOption( "namespace" );
else
  ns := fail;  
fi;
  
stream := InputOutputTCPStream( server, port );
initmessage := ReadLine( stream );
Info( InfoSCSCP, 1, "Got connection initiation message ", initmessage );
session_id := initmessage{ [ PositionSublist(initmessage,"system_id=")+11 .. Length(initmessage)-5 ] };
attribs := [ [ "call_ID", session_id ] ];

WriteLine( stream, "<?scscp version=\"1.0\" ?>" );
server_scscp_version := ReadLine( stream );
if server_scscp_version <> "<?scscp version=\"1.0\" ?>\n" then
  Error("Incompatible protocol versions, the server requires ", server_scscp_version );
fi;

if return_cookie then
  Add( attribs, [ "option_return_cookie", "" ] );
fi;

if InfoLevel( InfoSCSCP ) > 2 then
  Print("#I Composing procedure_call message: \n");
  omtext:="";
  localstream := OutputTextString( omtext, true );
  OMPutProcedureCall( localstream, 
                      command, 
                      rec(     object := listargs, 
                           attributes := attribs ) );
  Print(omtext);
fi;

WriteLine( stream, "<?scscp start ?>\n" );
OMPutProcedureCall( stream, 
                    command, 
                      rec(     object := listargs, 
                           attributes := attribs ) );
WriteLine( stream, "<?scscp end ?>\n" );
                            
Info( InfoSCSCP, 1, "Request sent, waiting for reply ...");
IO_Select( [ stream![1] ], [ ], [ ], [ ], 60*60, 0 );

if ns <> fail then
  result := OMGetObjectWithAttributes( stream : namespace:=ns );
else
  result := OMGetObjectWithAttributes( stream );
fi;

if return_cookie then
  result.object := RemoteObject( result.object, server, port );
fi;
Info( InfoSCSCP, 2, "Got back: object ", result.object, " with attributes ", result.attributes );
CloseStream(stream); 
return result;
end);


#############################################################################
#
# ParEvaluateBySCSCP( commands, listargs, servers, ports )
#
# This is a counterpart to the function EvaluateBySCSCP
# The idea of ParEvaluateBySCSCP is to apply various methods, 
# given in the first argument 'commands' as the list of names of 
# SCSCP procedures to the list of arguments 'listargs', where
# i-th SCSCP procedure will be called on servers[i]:ports[i] 
#
# Example of usage (the time of computation by these two methods
# is approximately the same, so you should expect results from both
# methods in some random order from repeated calls):
#
# ParEvaluateBySCSCP( [ "WS_FactorsECM", "WS_FactorsMPQS" ], [ 2^150+1 ], [ "localhost", "localhost" ], [ 26133, 26134 ] );
# ParEvaluateBySCSCP( [ "WS_FactorsCFRAC", "WS_FactorsMPQS" ], [ 2^150+1 ], [ "localhost", "localhost" ], [ 26133, 26134 ] );
#
InstallGlobalFunction( ParEvaluateBySCSCP,
function( commands, listargs, servers, ports )
local nserv, streams, nr, initmessage, session_id, fdlist, s, result;
if Length( Set ( List( [ commands, servers, ports ], Length ) ) ) <> 1 then
  Error("ParEvaluateBySCSCP : Arguments commands, servers and ports must have equal length!!!\n");
fi;
nserv := Length(ports);
streams := List( [ 1 .. nserv ], nr -> InputOutputTCPStream( servers[nr], ports[nr] ) );
for nr in [ 1 .. nserv ] do
  initmessage := ReadLine( streams[nr] );
  if initmessage[Length(initmessage)] = '\n' then
    initmessage:=initmessage{[1..Length(initmessage)-1]};
  fi;
  Info( InfoSCSCP, 1, "Got connection initiation message ", initmessage );
  session_id := initmessage{ [ PositionSublist(initmessage,"CAS_PID")+8 .. Length(initmessage)-1] };
  OMPutProcedureCall( streams[nr], 
                      commands[nr], 
                      rec(     object := listargs, 
                           attributes := [ [ "call_ID", Concatenation( session_id, "_", String(nr) ) ] ] ) );
  Info( InfoSCSCP, 1, "Request to service ", nr, " sent, waiting for reply ...");
od;  
fdlist := List( streams, s -> IO_GetFD( s![1] ) );
IO_select( fdlist, [ ], [ ], 60*60, 0 );
nr := First( [ 1 .. nserv ], i -> fdlist[i]<>fail );
Info( InfoSCSCP, 1, "Service number ", nr, " reported");
result := OMGetObjectWithAttributes( streams[nr] );
Info( InfoSCSCP, 2, "Got back: object ", result.object, " with attributes ", result.attributes );
for nr in [ 1 .. nserv ] do
  CloseStream( streams[nr] );
od; 
return result;
end);


#############################################################################
#
# NewThread( command, listargs, server, port )
#
# The function performs initial steps from EvaluateBySCSCP, and then
# returns the InputOutputTCPStream for waiting the result
#
InstallGlobalFunction( NewThread,
function( command, listargs, server, port )

local stream, initmessage, session_id, omtext, localstream,
      return_cookie, attribs, ns, server_scscp_version;

if ValueOption("return_cookie") <> fail then
  return_cookie := ValueOption( "return_cookie" );
else
  return_cookie := false;  
fi;

if ValueOption("namespace") <> fail then
  ns := ValueOption( "namespace" );
else
  ns := fail;  
fi;

stream := InputOutputTCPStream( server, port );
initmessage := ReadLine( stream );
Info( InfoSCSCP, 1, "Got connection initiation message ", initmessage );
session_id := initmessage{ [ PositionSublist(initmessage,"system_id=")+11 .. Length(initmessage)-5 ] };
attribs := [ [ "call_ID", session_id ] ];

WriteLine( stream, "<?scscp version=\"1.0\" ?>" );
server_scscp_version := ReadLine( stream );
if server_scscp_version <> "<?scscp version=\"1.0\" ?>\n" then
  Error("Incompatible protocol versions, the server requires ", server_scscp_version );
fi;
  
if return_cookie then
  Add( attribs, [ "option_return_cookie", "" ] );
fi;

if InfoLevel( InfoSCSCP ) > 2 then
  Print("#I Composing procedure_call message: \n");
  omtext:="";
  localstream := OutputTextString( omtext, true );
  OMPutProcedureCall( localstream, 
                      command, 
                      rec(     object := listargs, 
                           attributes := attribs ) );
  Print(omtext);
fi;

WriteLine( stream, "<?scscp start ?>\n" );
OMPutProcedureCall( stream, 
                    command, 
                      rec(     object := listargs, 
                           attributes := attribs ) );
WriteLine( stream, "<?scscp end ?>\n" );
              
Info( InfoSCSCP, 1, "Request sent, returning stream ...");                           
return stream;
end); 


#############################################################################
#
# CloseThread( <stream> )
#
# The function performs final steps from EvaluateBySCSCP
# and returns the result of the procedure call
#
InstallGlobalFunction( CloseThread,
function( stream )

local result, return_cookie, ns;

if ValueOption("return_cookie") <> fail then
  return_cookie := ValueOption( "return_cookie" );
else
  return_cookie := false;  
fi;

if ValueOption("namespace") <> fail then
  ns := ValueOption( "namespace" );
else
  ns := fail;  
fi;

Info( InfoSCSCP, 1, "Waiting for reply ...");

IO_Select( [ stream![1] ], [ ], [ ], [ ], 60*60, 0 );

if ns <> fail then
  result := OMGetObjectWithAttributes( stream : namespace:=ns );
else
  result := OMGetObjectWithAttributes( stream );
fi;

if return_cookie then
  result.object := RemoteObject( result.object, stream![2], stream![3][1] );
fi;
Info( InfoSCSCP, 2, "Got back: object ", result.object, " with attributes ", result.attributes );
CloseStream(stream); 
return result;
end);


#############################################################################
#
# Synchronize( <list of threads> )
#
Synchronize := function( threads )
local result, waitinglist, descriptors, s, nrdesc, i, nrthread;
result := [];
waitinglist:=[ 1 .. Length(threads) ];
while Length(waitinglist) > 0 do
  descriptors := List( threads{waitinglist}, s -> IO_GetFD( s![1] ) );  
  IO_select( descriptors, [ ], [ ], 60*60, 0 );
  nrdesc := First( [ 1 .. Length(descriptors) ], i -> descriptors[i]<>fail );
  nrthread := waitinglist[ nrdesc ];
  Info( InfoSCSCP, 1, "Thread number ", nrthread, " is ready");
  result[nrthread] := CloseThread( threads[nrthread] );
  SubtractSet(waitinglist,[nrthread]); 
od;
return result;
end;


#############################################################################
#
# Synchronize2( a, b )
#
# We can faster synchronize two threads, avoiding list manipulations
#
Synchronize2 := function( a, b )
local result, descriptors;
result:=[];
descriptors := [ IO_GetFD( a![1] ), IO_GetFD( b![1] ) ];
IO_select( descriptors, [ ], [ ], 60*60, 0 );
if descriptors[1]<>fail then # 1st thread is ready
  Info( InfoSCSCP, 1, "Thread number 1 is ready");
  result[1] := CloseThread( a );
  result[2] := CloseThread( b );
  return result;
elif descriptors[1]<>fail then # 2nd thread is ready
  Info( InfoSCSCP, 1, "Thread number 2 is ready");
  result[2] := CloseThread( b );
  result[1] := CloseThread( a );  
  return result;
else
  Error("Error in SynchronizeTwoThreads, both descriptors failed!!! \n");
fi;
end;