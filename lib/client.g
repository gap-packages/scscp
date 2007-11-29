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
# NewProcess( command, listargs, server, port )
#
# The function sends the request to the SCSCP server, and
# returns the InputOutputTCPStream for waiting the result
#
InstallGlobalFunction( NewProcess,
function( command, listargs, server, port )

local stream, initmessage, session_id, omtext, localstream,
      return_cookie, attribs, ns, server_scscp_version;

if ValueOption("return_cookie") <> fail then
  return_cookie := ValueOption( "return_cookie" );
else
  return_cookie := false;  
fi;

stream := InputOutputTCPStream( server, port );
initmessage := ReadLine( stream );
Info( InfoSCSCP, 1, "Got connection initiation message \n#I  ", initmessage );
session_id := initmessage{ [ PositionSublist(initmessage,"service_id=")+11 .. Length(initmessage)-5 ] };
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

OMPutProcedureCall( stream, 
                    command, 
                      rec(     object := listargs, 
                           attributes := attribs ) );
              
Info( InfoSCSCP, 1, "Request sent ...");                           
return stream;
end); 


#############################################################################
#
# CompleteProcess( <stream> )
#
# The function waits for the process completion, 
# then collects the result and closes the stream
#
InstallGlobalFunction( CompleteProcess,
function( stream )
local result, return_cookie;

if ValueOption("return_cookie") <> fail then
  return_cookie := ValueOption( "return_cookie" );
else
  return_cookie := false;  
fi;

IO_Select( [ stream![1] ], [ ], [ ], [ ], 60*60, 0 );
result := OMGetObjectWithAttributes( stream );
# This needs to be fixed. Reference must be converted automatically to the
# remote object. Then there is no need in a option for cookie in this function.
if return_cookie then
  result.object := RemoteObject( result.object, stream![2], stream![3][1] );
fi;
Info( InfoSCSCP, 2, "Got back: object ", result.object, " with attributes ", result.attributes );
CloseStream(stream); 
return result;
end);


#############################################################################
#
# TerminateProcess( <stream> )
#
# The function is supposed to send the interrupt sygnal to the server.
# Now it just close the stream on the client side, but the server will
# recognize this only when the computation will be completed. We introduce
# this function as a nameplace for further implementing a proper interrupt
# mechanism.
#
InstallGlobalFunction( TerminateProcess,
function( stream )
CloseStream( stream );
# closing stream too early (for example, when server writes to it)
# causes server crash because of the broken pipe :( 
return;
end);


#############################################################################
#
# EvaluateBySCSCP( command, listargs, server, port )
#
InstallGlobalFunction( EvaluateBySCSCP,
function( command, listargs, server, port )

local return_cookie, result;

if ValueOption("return_cookie") <> fail then
  return_cookie := ValueOption( "return_cookie" );
else
  return_cookie := false;  
fi;

if return_cookie then
  result := NewProcess(  command, listargs, server, port : return_cookie );
else
  result := NewProcess(  command, listargs, server, port );
fi;
Info( InfoSCSCP, 1, "Waiting for reply ...");
result := CompleteProcess( result );
return result;
end);


#############################################################################
#
# SynchronizeProcesses( <list of processes> )
#
SynchronizeProcesses := function( processes )
local result, waitinglist, descriptors, s, nrdesc, i, nrprocess;
result := [];
waitinglist:=[ 1 .. Length(processes) ];
while Length(waitinglist) > 0 do
  descriptors := List( processes{waitinglist}, s -> IO_GetFD( s![1] ) );  
  IO_select( descriptors, [ ], [ ], 60*60, 0 );
  nrdesc := First( [ 1 .. Length(descriptors) ], i -> descriptors[i]<>fail );
  nrprocess := waitinglist[ nrdesc ];
  Info( InfoSCSCP, 1, "Process number ", nrprocess, " is ready");
  result[nrprocess] := CompleteProcess( processes[nrprocess] );
  SubtractSet(waitinglist,[nrprocess]); 
od;
return result;
end;


#############################################################################
#
# SynchronizeProcesses2( a, b )
#
# We can faster synchronize two processes, avoiding list manipulations
#
SynchronizeProcesses2 := function( a, b )
local result, descriptors;
result:=[];
descriptors := [ IO_GetFD( a![1] ), IO_GetFD( b![1] ) ];
IO_select( descriptors, [ ], [ ], 60*60, 0 );
if descriptors[1]<>fail then # 1st process is ready
  Info( InfoSCSCP, 1, "Process number 1 is ready");
  result[1] := CompleteProcess( a );
  Info( InfoSCSCP, 1, "Closed 1st process, waiting for 2nd ...");  
  result[2] := CompleteProcess( b );
  return result;
elif descriptors[2]<>fail then # 2nd process is ready
  Info( InfoSCSCP, 1, "Process number 2 is ready");
  result[2] := CompleteProcess( b );
  Info( InfoSCSCP, 1, "Closed 2nd process, waiting for 1st ...");  
  result[1] := CompleteProcess( a );  
  return result;
else
  Error("Error in Synchronize2, both descriptors failed!!! \n");
fi;
end;


#############################################################################
#
# FirstProcess( <list of processes> )
#
FirstProcess := function( processes )
local descriptors, nrdesc, i, result, nr;
descriptors := List( processes, s -> IO_GetFD( s![1] ) );  
IO_select( descriptors, [ ], [ ], 60*60, 0 );
nrdesc := First( [ 1 .. Length(descriptors) ], i -> descriptors[i]<>fail );
Info( InfoSCSCP, 1, "Process number ", nrdesc, " is ready");
result := CompleteProcess( processes[ nrdesc ] );
for nr in [ 1 .. Length(descriptors) ] do
  if nr <> nrdesc then
    TerminateProcess( processes[nr] );
  fi;  
od; 
return result;
end;


#############################################################################
#
# FirstProcess2( a, b )
#
# We can faster handle the case of two processes, avoiding list manipulations
#
FirstProcess2 := function( a, b )
local result, descriptors;
result:=[];
descriptors := [ IO_GetFD( a![1] ), IO_GetFD( b![1] ) ];
IO_select( descriptors, [ ], [ ], 60*60, 0 );
if descriptors[1]<>fail then # 1st process is ready
  Info( InfoSCSCP, 1, "Process number 1 is ready");
  result := CompleteProcess( a );
  TerminateProcess( b );
  return result;
elif descriptors[2]<>fail then # 2nd process is ready
  Info( InfoSCSCP, 1, "Process number 2 is ready");
  result := CompleteProcess( b );
  TerminateProcess( a );  
  return result;
else
  Error("Error in FirstProcess2, both descriptors failed!!! \n");
fi;
end;


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
local nserv, processes, nr;
if Length( Set ( List( [ commands, servers, ports ], Length ) ) ) <> 1 then
  Error("ParEvaluateBySCSCP : Arguments commands, servers and ports must have equal length!!!\n");
fi;
nserv := Length(ports);
processes := [];
for nr in [ 1 .. nserv ] do
  processes[nr] := NewProcess( commands[nr], listargs, servers[nr], ports[nr] );
od;  
return FirstProcess( processes );
end);