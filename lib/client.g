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
PingWebService := function( server, port )
local stream, initmessage, rt;
stream := InputOutputTCPStream( server, port );
if stream <> fail then
  initmessage := ReadLine( stream );
  Print( "Got connection initiation message ", initmessage );
  CloseStream(stream); 
  return true;
else
  return fail;
fi;    
end;


#############################################################################
#
# PingStatistic( server, port, nr )
#
PingStatistic := function( server, port, nr )
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
    Print( "Got connection initiation message nr ", i, " : ", initmessage );
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
end;


#############################################################################
#
# EvaluateBySCSCP( command, listargs, server, port )
#
EvaluateBySCSCP := function( command, listargs, server, port )

local stream, initmessage, session_id, result, omtext, localstream,
      return_cookie, attribs;

if ValueOption("return_cookie") <> fail then
  return_cookie := ValueOption( "return_cookie" );
else
  return_cookie := false;  
fi;
  
stream := InputOutputTCPStream( server, port );
initmessage := ReadLine( stream );
Print( "Got connection initiation message ", initmessage );
session_id := initmessage{ [ PositionSublist(initmessage,"CAS_PID")+8 .. Length(initmessage)-1 ] };
attribs := [ [ "call_ID", session_id ] ];

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
Info( InfoSCSCP, 1, "Request sent, waiting for reply ...");
IO_Select( [ stream![1] ], [ ], [ ], [ ], 60*60, 0 );
result := OMGetObjectWithAttributes( stream );
Info( InfoSCSCP, 2, "Got back: object ", result.object, " with attributes ", result.attributes );
CloseStream(stream); 
return result;
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
#
ParEvaluateBySCSCP := function( commands, listargs, servers, ports )
local nserv, streams, nr, initmessage, session_id, fdlist, s, result;
if Length( Set ( List( [ commands, servers, ports ], Length ) ) ) <> 1 then
  Error("ParEvaluateBySCSCP : Arguments commands, servers and ports must have equal length!!!\n");
fi;
nserv := Length(ports);
streams := List( [ 1 .. nserv ], nr -> InputOutputTCPStream( servers[nr], ports[nr] ) );
for nr in [ 1 .. nserv ] do
  initmessage := ReadLine( streams[nr] );
  Print( "Got connection initiation message ", initmessage );
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
end;