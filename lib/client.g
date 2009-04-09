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
#                  return_coookie/return_nothing/return_tree, omcd:="omcdname" );
#
# Options return_coookie/return_nothing/return_tree are incompatible.
#
# For return_coookie/return_nothing see definions in the SCSCP specification.
#
# Option return_tree is used when it is necessary to suppress evaluation
# of the XML tree representing the OpenMath object (for example, to be used
# with "get_allowed_heads").
#
# The last option "omcd" is used to specify the name of the OpenMath content
# dictionary when it is different from the transient CD used by default.
#
InstallGlobalFunction( EvaluateBySCSCP,
function( command, listargs, server, port )

local return_cookie, return_nothing, return_tree, debug_option, opt, omcdname, result;

if ValueOption("return_cookie") <> fail then
  return_cookie := true;
else
  return_cookie := false;  
fi;

if ValueOption("return_nothing") <> fail then
  return_nothing := true;
else
  return_nothing := false;  
fi;

if ValueOption("return_tree") <> fail then
  return_tree := true;
else
  return_tree := false;  
fi;

if Number( [ return_cookie, return_nothing, return_tree ], opt -> opt=true ) > 1 then
  Print( "WARNING: options conflict in EvaluateBySCSCP:\n",
         "you specify only one of return_cookie / return_nothing /return_tree options!\n",
         "Only the first specified option will be used therefore.\n" );
fi;

if ValueOption("omcd") <> fail then
  omcdname := ValueOption("omcd");
else
  omcdname := "";
fi;

if ValueOption("debuglevel") <> fail then
  debug_option := ValueOption("debuglevel");
else
  debug_option := 0;
fi;

if return_cookie then
  result := NewProcess( command, listargs, server, port : return_cookie, omcd:=omcdname, debuglevel := debug_option );
elif return_nothing then
  result := NewProcess( command, listargs, server, port : return_nothing, omcd:=omcdname, debuglevel := debug_option );
else
  result := NewProcess( command, listargs, server, port : omcd:=omcdname, debuglevel := debug_option );
fi;

Info( InfoSCSCP, 1, "Waiting for reply ...");
if return_tree then
  result := CompleteProcess( result : return_tree );
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