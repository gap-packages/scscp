#############################################################################
#
# Experimental functions for rings workflows, not included in the release.
# Currenly not working (deadlock) after changing return_nothing rules.
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