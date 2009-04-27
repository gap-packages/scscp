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
# PingSCSCPservice( server, port )
#
InstallGlobalFunction( PingSCSCPservice,
function( server, port )
local stream, initmessage, rt;
if IN_SCSCP_TRACING_MODE then SCSCPTraceSendMessage( port ); fi;
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
       100*(nr_lost/nr), "% packet loss, time ", rt , "ms\n" );
if nr_good > 0 then       
       Print( "min/avg/max = ", [ min_time, rt/nr_good, max_time], "\n" );
fi;      
end);


#############################################################################
#
# EvaluateBySCSCP( command, listargs, server, port : 
#                  output:=object/coookie/nothing/tree, 
#                  cd:="cdname", debuglevel:=N );
#
# Options object/coookie/nothing/tree are incompatible.
#
# For object/coookie/nothing see definions in the SCSCP specification.
#
# Option output:="tree" is used when it is necessary to suppress evaluation
# of the XML tree representing the OpenMath object (for example, to be used
# with "get_allowed_heads").
#
# The last option "cd" is used to specify the name of the OpenMath content
# dictionary when it is different from the transient CD used by default.
#
InstallGlobalFunction( EvaluateBySCSCP,
function( command, listargs, server, port )

local output_option, debug_option, opt, cdname, result;

if ValueOption("output") <> fail then
  output_option := ValueOption("output");
else
  output_option := "object";  
fi;

if not output_option in [ "object", "cookie", "nothing", "tree" ] then
	Error( "output must be one of ", [ "object", "cookie", "nothing", "tree" ], "\n" );
fi;

if ValueOption("cd") <> fail then
  cdname := ValueOption("cd");
else
  cdname := "";
fi;

if ValueOption("debuglevel") <> fail then
  debug_option := ValueOption("debuglevel");
else
  debug_option := 0;
fi;

result := NewProcess( command, listargs, server, port : output := output_option, cd:=cdname, debuglevel := debug_option );

Info( InfoSCSCP, 1, "Waiting for reply ...");
if output_option = "tree" then
  result := CompleteProcess( result : output:="tree" );
else
  result := CompleteProcess( result );
fi;
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