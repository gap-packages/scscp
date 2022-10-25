#############################################################################
#
# Experimental functions for rings workflows, not included in the release.
# Currently not working (deadlock) after changing return_nothing rules.
#
#############################################################################

RingTest:=function( nrservers, nrsteps, k )
local port, proc;
# in the beginning the external client sends k=0 to the port 26133, e.g.
# NewProcess( "RingTest", [ 2, 10, 0 ], "localhost", 26133 : return_nothing );
Print(k, " \c");
k:=k+1;
if k = nrsteps then
  Print( "--> ", k," : THE LIMIT ACHIEVED, TEST STOPPED !!! \n" );
  return true;
fi;
port := 26133 + ( k mod nrservers );
Print("--> ", k," : ", port, "\n");
proc:=NewProcess( "RingTest", [ nrservers, nrsteps, k ], "localhost", port : return_nothing );
return true;
end;

LeaderElectionDone:=false;
# For example, to start on 4 servers, enter:
# nr:=4;NewProcess( "LeaderElection", ["init",0,nr], "localhost", 26133) : return_nothing );
LeaderElection:=function( status, id, nr )
local proc, nextport, m;
# status is either "init", "candidate" or "leader"
if not LeaderElectionDone then
	nextport := 26133 + ((SCSCPserverPort-26133+1) mod nr);
	if status="init" then # id can be anything on the init stage
	  	Print( "Initialising, sending candidate ", [SCSCPserverPort, IO_getpid() ], " to ", nextport, "\n" );
		proc:=NewProcess( "LeaderElection", [ "candidate", [ SCSCPserverPort, IO_getpid() ], nr ], 
	    	              "localhost", nextport : return_nothing );
		return true;
	elif status="candidate" then
		if id[2] = IO_getpid() then
			LeaderElectionDone := true;
			Print( "Got ", status, " ", id, ". Election done, sending leader ", id, " to ", nextport, "\n" );
			proc:=NewProcess( "LeaderElection", [ "leader", id, nr ], "localhost", nextport : return_nothing );
			return true; 			
		else
			if id[2] < IO_getpid() then
				m := id;
			else;
				m := [ SCSCPserverPort, IO_getpid() ];
			fi;
			Print( "Got ", status, " ", id, ", sending candidate ", m , " to ", nextport, "\n" );
			proc:=NewProcess( "LeaderElection", [ status, m, nr ], "localhost", nextport : return_nothing );
			return true; 
		fi;
	else
		LeaderElectionDone := true;
		Print( "Got ", status, " ", id, ", sending ", status, " ", id, " to ", nextport, "\n" );
		proc:=NewProcess( "LeaderElection", [ status, id, nr ], "localhost", nextport : return_nothing );
		return true; 
	fi;
else
  	Print( "Got ", status, " ", id, ", doing nothing \n" );
	return true;	
fi;	
end;

ResetLeaderElection:=function()
LeaderElectionDone:=false;
Print( "Reset LeaderElectionDone to ", LeaderElectionDone, "\n" );
return true;
end;

# THIS IS AN ATTEMPT TO CREATE THE TORUS WORKFLOW (DEADLOCKING!)

TorusNodesStatus:=[];
TorusNodesOwners:=[];

ResetTorus:=function()
TorusNodesStatus:=[];
TorusNodesOwners:=[];
return true;
end;


UpdateTorusNodesStatus:=function( owner, port, status )
if not IsBound( TorusNodesStatus[port] ) then
  Print( "Client ", owner, " setting ", port, " to ", status );
else 
  Print( "Client ", owner, " switching ", port, " from ", TorusNodesStatus[port], " to ", status );	
fi;
if not IsBound( TorusNodesStatus[port] ) then
  TorusNodesStatus[port]:=status;
  TorusNodesOwners[port]:=owner;
  Print(" - OK! \n" );
  return true;
elif TorusNodesStatus[port]=true and status=false then
  if port in TorusNodesOwners then
    Print(" - refused, ", port, " is busy! \n" );
    return false;  
  else   
    TorusNodesStatus[port]:=false;
    TorusNodesOwners[port]:=owner;
    Print(" - OK! \n" );
    return true;
  fi;  
elif TorusNodesStatus[port]=false and status=true then
  if TorusNodesOwners[port]=owner then
  	TorusNodesStatus[port]:=true;
  	TorusNodesOwners[port]:=0;
    Print(" - OK! \n" );
    return true;
  else
    Print(" - refused, ", owner, " is not an owner of ", port, " ! \n" );
    return false; 
  fi;  
elif TorusNodesStatus[port]=true and status=true then
  Print(" - nothing to do! \n" );
  return true;
elif TorusNodesStatus[port]=false and status=false then
  Print(" - refused! \n" );
  return false;
else
  Error("UpdateTorusNodesStatus : unhandled combination!\n");  
fi;    
end;


TorusTest:=function( nrrows, nrcols, nrsteps, k, waiterport )
local port, proc, r, st;
# First start UpdateTorusNodesStatus at port 'waiterport'. Then to begin the test,
# some external client sends k=0 to the port 26133, e.g.
# NewProcess( "TorusTest", [ 2, 2, 10, 0, 26137 ], "localhost", 26133 : return_nothing );
Print("Got ", k, " \c");
k:=k+1;
if k = nrsteps then
  Print( "||--> ", k," : THE LIMIT ACHIEVED, TEST STOPPED !!! \n" );
  return true;
fi;
r := QuotientRemainder( SCSCPserverPort-26133, nrcols ); 
port := 26133 + r[1]*nrcols + ((r[2]+1) mod nrcols);
Print("|--> horizontally --> ", k," : ", port, "\n");
repeat 
    Exec("sleep 5");
	st:=EvaluateBySCSCP( "UpdateTorusNodesStatus", [ SCSCPserverPort, port, false ], "localhost", waiterport );
until st.object=true;	
proc:=NewProcess( "TorusTest", [ nrrows, nrcols, nrsteps, k, waiterport], "localhost", port : return_nothing );
EvaluateBySCSCP( "UpdateTorusNodesStatus", [ SCSCPserverPort, port, true ], "localhost", waiterport );
port := 26133 + ( (SCSCPserverPort-26133+nrcols ) mod (nrcols*nrrows) );
Print("|--> vertically --> ", k," : ", port, "\n");
repeat 
    Exec("sleep 5");
	st:=EvaluateBySCSCP( "UpdateTorusNodesStatus", [ SCSCPserverPort, port, false ], "localhost", waiterport );
until st.object=true;	
proc:=NewProcess( "TorusTest", [ nrrows, nrcols, nrsteps, k, waiterport ], "localhost", port : return_nothing );
EvaluateBySCSCP( "UpdateTorusNodesStatus", [ SCSCPserverPort, port, true ], "localhost", waiterport );
return true;
end;

