###########################################################################
##
#W client.g                The SCSCP package             Olexandr Konovalov
#W                                                             Steve Linton
##
###########################################################################


###########################################################################
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


###########################################################################
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


###########################################################################
#
# StartSCSCPsession( stream )
#
InstallGlobalFunction( StartSCSCPsession,
function( stream )
local initmessage, session_id, pos1, pos2, server_scscp_version, suggested_versions;
initmessage := ReadLine( stream );
NormalizeWhitespace( initmessage );
Info( InfoSCSCP, 1, "Got connection initiation message" );
Info( InfoSCSCP, 2, initmessage );
session_id := initmessage{ [ PositionSublist(initmessage,"service_id=")+12 .. 
                             PositionSublist(initmessage,"\" scscp_versions")-1 ] };
server_scscp_version:=initmessage{ [ PositionSublist(initmessage,"scscp_versions=")+16 .. 
                                     PositionSublist(initmessage,"\" ?>")-1 ] };
server_scscp_version := SplitString( server_scscp_version, " " );
if not SCSCP_VERSION in server_scscp_version then
  # we select the highest compatible version of the protocol or insist on our version
  suggested_versions := Intersection( server_scscp_version, SCSCP_COMPATIBLE_VERSIONS );
  if Length( suggested_versions ) > 0 then
    SCSCP_VERSION := Maximum( suggested_versions );
  fi;
fi;
Info(InfoSCSCP, 1, "Requesting version ", SCSCP_VERSION, " from the server ..."); 
WriteLine( stream, Concatenation( "<?scscp version=\"", SCSCP_VERSION, "\" ?>" ) );
server_scscp_version := ReadLine( stream );
pos1 := PositionNthOccurrence(server_scscp_version,'\"',1);
pos2 := PositionNthOccurrence(server_scscp_version,'\"',2);
if pos1=fail or pos2=fail then
  CloseStream( stream );
  Error( "Incompatible protocol versions, the server requires ", server_scscp_version );
else 
  server_scscp_version := server_scscp_version{[ pos1+1 .. pos2-1 ]};
  if server_scscp_version <> SCSCP_VERSION then
    CloseStream( stream );
    Error("Incompatible protocol versions, the server requires ", server_scscp_version );
  else
    Info(InfoSCSCP, 1, "Server confirmed version ", SCSCP_VERSION, " to the client ..."); 
    return session_id;          
  fi;  
fi;
end);


###########################################################################
#
# EvaluateBySCSCP( command, listargs, <connection | server, port> : 
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
function( arg )

local output_option, debug_option, opt, cdname, process, result;

if ValueOption("output") <> fail then
  output_option := ValueOption("output");
else
  output_option := "object";  
fi;

if not output_option in 
           [ "object", "cookie", "nothing", "tree", "deferred" ] then
	Error( "output must be one of ", 
	       [ "object", "cookie", "nothing", "tree", "deferred" ], "\n" );
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

if Length(arg)=3 then
    process := NewProcess( arg[1], arg[2], arg[3] : output := output_option, 
                                    cd:=cdname, debuglevel := debug_option );
elif Length(arg)=4 then
    process := NewProcess( arg[1], arg[2], arg[3], arg[4] : output := output_option, 
                                    cd:=cdname, debuglevel := debug_option );
else
    Error("EvaluateBySCSCP : wrong number of arguments\n");
fi;

Info( InfoSCSCP, 1, "Waiting for reply ...");
if output_option = "tree" then
  result := CompleteProcess( process : output:="tree" );
else
  result := CompleteProcess( process );
fi;

return result;

end);

###########################################################################
##
#E 
##
