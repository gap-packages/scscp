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
  Info( InfoSCSCP, 1, "Got connection initiation message" );
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
    Info( InfoSCSCP, 1, "Got connection initiation message nr ", i );
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

local return_cookie, return_nothing, result;

if ValueOption("return_cookie") <> fail then
  return_cookie := ValueOption( "return_cookie" );
else
  return_cookie := false;  
fi;

if ValueOption("return_nothing") <> fail then
  return_nothing := ValueOption( "return_nothing" );
else
  return_nothing := false;  
fi;

if return_cookie then
  result := NewProcess(  command, listargs, server, port : return_cookie );
elif return_nothing then
  result := NewProcess(  command, listargs, server, port : return_nothing );
fi;
Info( InfoSCSCP, 1, "Waiting for reply ...");
result := CompleteProcess( result );
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