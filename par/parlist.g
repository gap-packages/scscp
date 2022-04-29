#############################################################################
##
#W parlist.g                The SCSCP package              Olexandr Konovalov
#W                                                               Steve Linton
##
#############################################################################

SCSCPprocesses:=[];

###########################################################################
##
#F  SCSCPreset
##
##  <#GAPDoc Label="SCSCPreset">
##  
##  <ManSection>
##  <Func Name="SCSCPreset" Arg=""/>
##  <Returns>
##    nothing
##  </Returns>          
##  <Description>
##  If an error occurs during a call of <Ref Func="ParQuickWithSCSCP" />
##  and <Ref Func="ParListWithSCSCP" />, some of parallel requests may
##  be still running at the remaining services, making them inaccessible
##  for further procedure calls. <Ref Func="SCSCPreset" /> resets them
##  by closing all open streams to &SCSCP; servers.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
SCSCPreset:=function()
local proc;
for proc in SCSCPprocesses do
	if not IsClosedStream( proc![1] ) then
		CloseStream( proc![1] );
	fi;	
od;
end;

#############################################################################
#
# ParQuickWithSCSCP( commands, listargs )
#
# The idea of ParQuickWithSCSCP is to apply various methods from the first 
# argument 'commands' containing the list of names of SCSCP procedures to 
# the list of arguments 'listargs', where i-th SCSCP procedure will be 
# executed at SCSCPservers[i]
#
# Example of usage (the time of computation by these two methods
# is approximately the same, so you should expect results from both
# methods in some random order from repeated calls):
#
# ParQuickWithSCSCP( [ "WS_FactorsECM", "WS_FactorsMPQS" ], [ 2^150+1 ] );
# ParQuickWithSCSCP( [ "WS_FactorsCFRAC", "WS_FactorsMPQS" ], [ 2^150+1 ] );
#
InstallGlobalFunction( ParQuickWithSCSCP, function( commands, listargs )
local nr, res;
if Length( commands ) < Length( SCSCPservers ) then
  Error("ParQuickWithSCSCP : the number of procedures smaller than the number of services!!!\n");
fi;
SCSCPprocesses := [];
for nr in [ 1 .. Length(commands) ] do
  SCSCPprocesses[nr] := NewProcess( commands[nr], listargs, SCSCPservers[nr][1], SCSCPservers[nr][2] );
od;  
res := FirstProcess( SCSCPprocesses );
SCSCPreset(); # we want this to be a tiny bit later to prevent broken pipes
return res;
end);


#############################################################################
##
## ParListWithSCSCP( inputlist, remoteprocname : noretry, timeout=int, recallfrequency=int )
##
InstallGlobalFunction( ParListWithSCSCP, function( inputlist, remoteprocname )
local noretry, status, i, itercount, recallfreq, output, callargspositions, 
      currentposition, inputposition, timeout, nr, waitinglist, descriptors, 
      s, nrdesc, retrystack, result, nrservices_alive, nrservices_needed, 
      len, infomw, connections;
       
if ValueOption("timeout")=fail then
  timeout:=60*60; # default timeout - one hour, given in seconds;
else
  timeout:=ValueOption("timeout");
fi;

if ValueOption("noretry")=fail then
  noretry:=false; # no retrying calls which exceeded the timeout
else
  noretry:=ValueOption("noretry");
fi;

if ValueOption("recallfrequency")=fail then
  recallfreq:=0; # no need in initial and perodic pinging services
else
  recallfreq:=ValueOption("recallfrequency");
fi;

infomw:=InfoLevel(InfoMasterWorker);

connections := [];
status := [ ];
nrservices_alive:=0;
nrservices_needed:=Length( inputlist );
len:=Length( inputlist );

for i in [ 1 .. Length(SCSCPservers) ] do
    if PingSCSCPservice( SCSCPservers[i][1], SCSCPservers[i][2] )=fail then
    	status[i]:=0; # the server is not alive  
    	Info( InfoSCSCP, 1, SCSCPservers[i], " is not responding and will not be used!" );
    else 
        connections[i] := NewSCSCPconnection( SCSCPservers[i][1], SCSCPservers[i][2] );
    	status[i]:=1; # the server is alive and ready to accept
        Info( InfoSCSCP, 1, SCSCPservers[i], " responded and attached to the computation!" );
        nrservices_alive := nrservices_alive + 1;
        if nrservices_alive >= nrservices_needed then
        	break;
        fi;
    fi;   
od;

if nrservices_alive = 0 then
	Error( "Can not start computation - no SCSCP service available!\n" );
fi;

output := [ ];
callargspositions := [ ];
retrystack:= [ ];
currentposition := 0;
SCSCPprocesses := [ ];
itercount:=0;

while true do
  itercount:=itercount+1;
  if recallfreq <> 0 then
    if IsInt(itercount/recallfreq) then
      nrservices_needed := Length( inputlist ) - currentposition + Length(retrystack);
      for i in [ 1 .. Length(SCSCPservers) ] do
        if status[i]=0 then
  	      if PingSCSCPservice( SCSCPservers[i][1], SCSCPservers[i][2] )=fail then
            Info( InfoSCSCP, 1, SCSCPservers[i], "is still not responding and can not be used!" );
          else  
            connections[i]:=NewSCSCPconnection( SCSCPservers[i][1], SCSCPservers[i][2] );
            status[i]:=1; # alive and ready to accept
            Info( InfoSCSCP, 1, SCSCPservers[i], " responded and attached to the computation!" );
            nrservices_alive := nrservices_alive + 1;
    	    if nrservices_alive >= nrservices_needed then
      		  break;
    	    fi;
          fi;
        fi;
      od;    
      itercount:=0;
    fi;
  fi;
  #
  # is next task available (from the initial list or retry stack)?
  #
  while currentposition < Length( inputlist ) or Length( retrystack ) > 0 do
    #
    # search for next available service
    #
    nr := Position( status, 1 );
    if nr<>fail then
      #
      # there is a service number 'nr' that is ready to accept procedure call
      #
      if Length( retrystack ) > 0 then
        inputposition := retrystack[ Length( retrystack ) ];
        Unbind( retrystack[ Length( retrystack ) ] );
      else
      	currentposition := currentposition + 1;
      	inputposition := currentposition;
      fi;	
      # remember which argument was sent to this service
      callargspositions[nr] := inputposition;
      SCSCPprocesses[nr] := NewProcess( remoteprocname, 
                                        [ inputlist[inputposition] ], 
                                        connections[nr] );
      if infomw <> 0 then                       
        if infomw = 1 then
      	  Print( inputposition, "/", len, "\r");
        elif infomw = 2 or infomw = 3 then
      	  Print( "#I  ", inputposition, "/", len, ":master --> ", 
                SCSCPservers[nr][1], ":", SCSCPservers[nr][2], "\n" );
        else
      	  Print( "#I  ", inputposition, "/", len, ":master --> ", 
                SCSCPservers[nr][1], ":", SCSCPservers[nr][2], " : ", inputlist[inputposition], "\n" );
        fi;        
	  fi;
      status[nr] := 2; # status 2 means that we are waiting to hear from this service
    else
      break; # if we are here all services are busy
    fi;
  od;  
  #
  # see are there any waiting tasks
  #
  waitinglist:= Filtered( [ 1 .. Length(status) ], i -> status[i]=2 );
  if Length( waitinglist ) = 0 then
  	if Length( callargspositions ) = 0 then
  	  # no next tasks, no waiting tasks and no arguments sent off - computation completed!
  	  if not noretry and ( Length(output) <> Length(inputlist) or not IsDenseList(output) ) then
  	    Error( "The output list does not match the input list!\n" );
  	  else
  	    for i in [1..Length(connections)] do
  	      if not IsClosedStream ( connections[i]![1] ) then
  	        CloseSCSCPconnection( connections[i] );
  	      fi;  
  	    od;
        return output;
      fi;
    else
      Error( "Tasks for arguments ", 
      			inputlist{ Filtered( [ 1 .. Length(callargspositions) ], 
      				i -> IsBound( callargspositions[i] ) ) }, " are lost!\n");
    fi;  
  fi;
  #
  # waiting until any of the running tasks will be completed
  #
  descriptors := List( SCSCPprocesses{waitinglist}, s -> IO_GetFD( s![1]![1] ) );  
  if IN_SCSCP_TRACING_MODE then SCSCPTraceSuspendThread(); fi;
  IO_select( descriptors, [ ], [ ], timeout, 0 );
  if IN_SCSCP_TRACING_MODE then SCSCPTraceRunThread(); fi;
  nrdesc := First( [ 1 .. Length(descriptors) ], i -> descriptors[i] <> fail );
  # if nothing came and timeout has passed then nrdesc=fail
  # This may happen when server was terminated by ^C and is in a break loop,
  # so no procedure_terminated message will appear on the client's side
  if nrdesc=fail then
    if noretry then
      nr := Random( waitinglist );
  	  TerminateProcess( SCSCPprocesses[nr] );
  	  if not IsClosedStream( SCSCPprocesses[nr]![1] ) then
		CloseStream( SCSCPprocesses[nr]![1] );
	  fi;	
	  CloseSCSCPconnection( connections[nr] );
      result:=fail;
    else  
   	  Error( "ParSCSCP: waited for ", timeout, " seconds with no response from ", SCSCPservers{waitinglist}, "\n" );  
   	fi;
  else	
  	nr := waitinglist[ nrdesc ];
  	result := CompleteProcess( SCSCPprocesses[nr] );
  fi;
  
  if result=fail then
    if noretry then
      Info( InfoSCSCP, 2, SCSCPservers[nr], " : timeout exceeded, procedure call terminated" );
      status[nr]:=1;
    else
 	  # the service SCSCPservers[nr] seems to crash, mark it as unavailable
 	  if PingSCSCPservice( SCSCPservers[nr][1], SCSCPservers[nr][2] ) = fail then
 		Print( SCSCPservers[nr], " is no longer available \n" );
 	 	status[nr]:=0;
 	 	nrservices_alive := nrservices_alive - 1;
		if nrservices_alive = 0 then
		  Error( "Can not continue computation - no SCSCP service left available!\n" );
		fi;
 	  else
 		Error("ParSCSCP: failed to get result from ", SCSCPservers[nr] );
 	  fi;
      # we need to retry the call with argument inputlist[callargspositions[nr] ]
      Add( retrystack, callargspositions[nr] );
    fi;
  else
    #
    # processing the result
    #
    if infomw <> 0 then                       
      if infomw > 2 then
        Print( "#I  ", SCSCPservers[nr][1], ":", SCSCPservers[nr][2], 
               " --> ", callargspositions[nr], "/", len, ":master" );
        if infomw > 4 then
          Print( " : ", result.object, "\n" );
        else
          Print("\n"); 
        fi;
      fi;        
	fi;
    status[nr]:=1;
    output[ callargspositions[nr] ] := result.object;
  fi;
  Unbind(callargspositions[nr]);
od; # end of the outer loop
end);