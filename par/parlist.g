#############################################################################
##
#W parlist.g                The SCSCP package             Alexander Konovalov
#W                                                               Steve Linton
##
#H $Id: orbit.g 2299 2009-01-13 12:26:59Z alexk $
##
#############################################################################

# TODO: automatic adjustments of the timeout (see Runtimes() record)

# TODO (suggested by SL): A useful trick which Google uses is that they 
# automatically restart the last 5% or so of the computations to finish, 
# without actually knowing whether the servers have died or not. That way 
# they also compensate for servers that are just running very slowly, 
# and they lose nothing, since there are always idle servers by that point.

ReadPackage("scscp/configpar");
SCSCPprocesses:=[];

SCSCPreset:=function()
local proc;
for proc in SCSCPprocesses do
	if not IsClosedStream( proc![1] ) then
		CloseStream( proc![1] );
	fi;	
od;
end;

#############################################################################
##
## ParListWithSCSCP( inputlist, remoteprocname : timeout=int; recallfrequency=int )
##
ParListWithSCSCP := function( inputlist, remoteprocname )
local status, i, itercount, recallfreq, output, callargspositions, 
      currentposition, inputposition, timeout, nr, waitinglist, descriptors, 
      s, nrdesc, retrystack, result, nrservices_alive, nrservices_needed;
      
if IN_SCSCP_TRACING_MODE then SCSCPTraceNewProcess(); SCSCPTraceNewThread(); SCSCPTraceRunThread(); fi;
       
if ValueOption("timeout")=fail then
  timeout:=60*60; # default timeout - one hour, given in seconds;
else
  timeout:=ValueOption("timeout");
fi;

if ValueOption("recallfrequency")=fail then
  recallfreq:=0; # no need in initial and perodic pinging services
else
  recallfreq:=ValueOption("recallfreq");
fi;

status := [ ];
nrservices_alive:=0;
nrservices_needed:=Length( inputlist );

for i in [ 1 .. Length(SCSCPservers) ] do
    if IN_SCSCP_TRACING_MODE then SCSCPTraceSendMessage(SCSCPservers[i][2]); fi;
    if PingWebService( SCSCPservers[i][1], SCSCPservers[i][2] )=fail then
      status[i]:=0; # not alive  
      Info( InfoSCSCP, 1, SCSCPservers[i], " is not responding and will not be used!" );
    else  
      status[i]:=1; # alive and ready to accept
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
          if IN_SCSCP_TRACING_MODE then SCSCPTraceSendMessage(SCSCPservers[i][2]); fi;
  	      if PingWebService( SCSCPservers[i][1], SCSCPservers[i][2] )=fail then
            Info( InfoSCSCP, 1, SCSCPservers[i], "is still not responding and can not be used!" );
          else  
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
      if IN_SCSCP_TRACING_MODE then SCSCPTraceSendMessage(SCSCPservers[nr][2]); fi;
      SCSCPprocesses[nr] := NewProcess( remoteprocname, [ inputlist[inputposition] ], 
                                   SCSCPservers[nr][1], SCSCPservers[nr][2] );
      Info( InfoSCSCP, 2, "master -> ", SCSCPservers[nr], " : ", inputlist[inputposition] );
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
  	  if Length(output) <> Length(inputlist) or not IsDenseList(output) then
  	    Error( "The output list does not match the input list!\n" );
  	  else
  	    if IN_SCSCP_TRACING_MODE then SCSCPTraceEndThread(); SCSCPTraceEndProcess(); fi;
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
   	Error( "ParSCSCP: waited for ", timeout, " seconds with no response from ", SCSCPservers{waitinglist}, "\n" );  
  else	
  	nr := waitinglist[ nrdesc ];
  	if IN_SCSCP_TRACING_MODE then SCSCPTraceReceiveMessage(SCSCPservers[nr][2]); fi;
  	result := CompleteProcess( SCSCPprocesses[nr] );
  fi;
  if result = fail then
 	# the service SCSCPservers[nr] seems to crash, mark it as unavailable
 	if IN_SCSCP_TRACING_MODE then SCSCPTraceSendMessage(SCSCPservers[nr][2]); fi;
 	if PingWebService( SCSCPservers[nr][1], SCSCPservers[nr][2] ) = fail then
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
    Unbind( callargspositions[nr] );
  else
  #
  # processing the result
  #
  Info( InfoSCSCP, 2, SCSCPservers[nr], " --> master : ", result.object );
  status[nr]:=1;
  output[ callargspositions[nr] ] := result.object;
  Unbind(callargspositions[nr]);
  fi;
od; # end of the outer loop
end;