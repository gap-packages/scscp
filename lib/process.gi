#############################################################################
##
#W process.gi               The SCSCP package             Alexander Konovalov
#W                                                               Steve Linton
##
#H $Id$
##
#############################################################################

SCSCP_CURRENT_SESSION_STREAM := fail;

DeclareRepresentation( "IsProcessRepresentation", 
                       IsPositionalObjectRep,
                       [ 1, 2 ] );
                       
ProcessesFamily := NewFamily( "ProcessesFamily(...)", IsProcess );
                       
ProcessDefaultType := NewType( ProcessesFamily, 
                               IsProcessRepresentation and IsProcess);

if IsReadOnlyGlobal("OnQuit") then
	MakeReadWriteGlobal("OnQuit");
fi;

OnQuit:=function()
if SCSCP_CURRENT_SESSION_STREAM <> fail then
    Print( "SCSCP : ", SCSCP_CURRENT_SESSION_STREAM );
    CloseStream( SCSCP_CURRENT_SESSION_STREAM );
    Print( " is closed\n" );
    SCSCP_CURRENT_SESSION_STREAM := fail;
    if not IsEmpty( OptionsStack )  then
        repeat
            PopOptions(  );
        until IsEmpty( OptionsStack );
        Info( InfoWarning, 1, "Options stack has been reset" );
    fi;
    return;
fi;
end;

MakeReadOnlyGlobal("OnQuit");


#############################################################################
##
#M  ViewObj( <process> )
##
InstallMethod( ViewObj, "for process",
[ IsProcessRepresentation and IsProcess ],
function( proc )
    local stream, pid;
    stream := proc![1];
    pid := proc![2];
    Print("< ");
    if IsClosedStream(stream) then
        Print("closed ");
    fi;
    Print("process at ",stream![2],":",stream![3][1], " pid=", pid, " >");
end);


#############################################################################
##
#M  PrintObj( <process> )
##
InstallMethod( PrintObj, "for process",
[ IsProcessRepresentation and IsProcess ],
function( proc )
    local stream, pid;
    stream := proc![1];
    pid := proc![2];
    Print("< ");
    if IsClosedStream(stream) then
        Print("closed ");
    fi;
    Print("process at ",stream![2],":",stream![3][1], " pid=", pid, " >");
end);


#############################################################################
#
# NewProcess( command, listargs, server, port : 
#                               output:=object/coookie/nothing/deferred, 
#                                             cd:="cdname", debuglevel:=N );
#
# The function sends the request to the SCSCP server, and
# returns the InputOutputTCPStream for waiting the result
#
InstallGlobalFunction( NewProcess,
function( command, listargs, server, port )

local tcpstream, session_id, omtext, localstream, output_option, debug_option, 
      cdname, attribs, ns, pos1, pos2, pid, token;

if ValueOption("output") <> fail then
  output_option := ValueOption("output");
else
  output_option := "object";  
fi;

if output_option = "tree" then
	output_option:="option_return_object"; 
else
	output_option:=Concatenation( "option_return_", output_option );
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

tcpstream := InputOutputTCPStream( server, port );
session_id := StartSCSCPsession( tcpstream );
SCSCP_CURRENT_SESSION_STREAM := tcpstream;

pos1 := PositionNthOccurrence(session_id,':',2);
if pos1 <> fail then
  pid := EvalString( session_id{[ pos1+1 .. Length(session_id) ]} );
else
  pid:=0;
fi;

attribs := [ [ "call_id", Concatenation( session_id, ":", RandomString(8) ) ] ];
Add( attribs, [ output_option, "" ] );
if debug_option > 0 then
  Add( attribs, [ "option_debuglevel", debug_option ] );
fi; 

if InfoLevel( InfoSCSCP ) > 2 then

  Print("#I  Composing procedure_call message: \n");
  omtext:="";
  localstream := OutputTextString( omtext, true );
  OMPutProcedureCall( localstream, 
                      command, 
                      rec(     object := listargs, 
                           attributes := attribs ) : cd:=cdname );
  if IN_SCSCP_BINARY_MODE then
    localstream:=InputTextString( omtext );
    token:=ReadByte( localstream );
    while token <> fail do
      Print( EnsureCompleteHexNum( HexStringInt( token ) ) );
      token:=ReadByte( localstream );
    od;
    Print("\n");
  else
    Print(omtext);
  fi;
  WriteAll( tcpstream, omtext );
  if IsInputOutputTCPStream( tcpstream ) then
    IO_Flush( tcpstream![1] );
  fi;
else
  
  OMPutProcedureCall( tcpstream, 
                      command, 
                      rec(     object := listargs, 
                           attributes := attribs ) : cd:=cdname );

fi;
              
Info( InfoSCSCP, 1, "Request sent ...");
SCSCP_CURRENT_SESSION_STREAM := fail;             
return Objectify( ProcessDefaultType, [ tcpstream, pid ] );
end); 


#############################################################################
#
# CompleteProcess( <process> : return_cookie/return_tree );
#
# The function waits for the process completion, 
# then collects the result and closes the stream
#
InstallGlobalFunction( CompleteProcess,
function( process )
local tcpstream, result, output_option;

if ValueOption( "output") <> fail then
  output_option := ValueOption( "output");
else
  output_option := "object";  
fi;

tcpstream := process![1];
SCSCP_CURRENT_SESSION_STREAM := tcpstream;
if IN_SCSCP_TRACING_MODE then SCSCPTraceSuspendThread(); fi;
IO_Select( [ tcpstream![1] ], [ ], [ ], [ ], 60*60, 0 );
if IN_SCSCP_TRACING_MODE then SCSCPTraceRunThread(); fi;
if IN_SCSCP_TRACING_MODE then SCSCPTraceReceiveMessage( tcpstream![3][1] ); fi;
if output_option="tree" then
    result := OMGetObjectWithAttributes( tcpstream : return_tree );
else
    result := OMGetObjectWithAttributes( tcpstream );
fi;    

if result = fail then
	Info( InfoSCSCP, 2, "CompleteProcess failed to get result from ", tcpstream![2], ":", tcpstream![3][1], ", returning fail" );
else
	Info( InfoSCSCP, 2, "Got back: object ", result.object, " with attributes ", result.attributes );
fi;	
CloseStream(tcpstream); 
SCSCP_CURRENT_SESSION_STREAM := fail;
return result;
end);


#############################################################################
#
# TerminateProcess( <process> )
#
# The function is supposed to send the interrupt signal to the server.
# Now it just closes the stream on the client side, but the server will
# recognize this only when the computation will be completed. We introduce
# this function as a nameplace for further implementing a proper interrupt
# mechanism.
#
InstallGlobalFunction( TerminateProcess,
function( process )
# THIS WORKS ONLY LOCALLY
if process![1]![2]="localhost" then
  IO_kill( process![2], IO.SIGINT );
fi;  
end);


#############################################################################
#
# SynchronizeProcessesN( <list of processes> )
#
SynchronizeProcessesN := function( processes )
local result, waitinglist, descriptors, s, nrdesc, i, nrprocess;
result := [];
waitinglist:=[ 1 .. Length(processes) ];
while Length(waitinglist) > 0 do
  descriptors := List( processes{waitinglist}, s -> IO_GetFD( s![1]![1] ) );  
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
# SynchronizeProcesses2( <process1>, <process2> )
#
# We can faster synchronize two processes, avoiding list manipulations
#
SynchronizeProcesses2 := function( a, b )
local result, descriptors;
result:=[];
descriptors := [ IO_GetFD( a![1]![1] ), IO_GetFD( b![1]![1] ) ];
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
# SynchronizeProcesses( <list of processes> )
# SynchronizeProcesses( <process1>, ..., <processN> )
InstallGlobalFunction( SynchronizeProcesses,
function( arg )
if Length(arg)=2 then
  return SynchronizeProcesses2( arg[1], arg[2] );
else
  return SynchronizeProcessesN( arg[1] );
fi;
end);


#############################################################################
#
# FirstProcessN( <list of processes> )
#
FirstProcessN := function( processes )
local descriptors, nrdesc, i, result, nr;
descriptors := List( processes, s -> IO_GetFD( s![1]![1] ) );  
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
# FirstProcess2( <process1>, <process2> )
#
# We can faster handle the case of two processes, avoiding list manipulations
#
FirstProcess2 := function( a, b )
local result, descriptors;
result:=[];
descriptors := [ IO_GetFD( a![1]![1] ), IO_GetFD( b![1]![1] ) ];
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
# FirstProcess( <list of processes> )
# FirstProcess( <process1>, ..., <processN> )
#
InstallGlobalFunction( FirstProcess,
function( arg )
if Length(arg)=2 then
  return FirstProcess2( arg[1], arg[2] );
else
  return FirstProcessN( arg[1] );
fi;
end);



#############################################################################
#
# FirstTrueProcessN( <list of processes> )
#
FirstTrueProcessN := function( processes )
local result, waitinglist, descriptors, s, nrdesc, i, nrprocess;
result := [];
waitinglist:=[ 1 .. Length(processes) ];
while Length(waitinglist) > 0 do
  descriptors := List( processes{waitinglist}, s -> IO_GetFD( s![1]![1] ) );  
  IO_select( descriptors, [ ], [ ], 60*60, 0 );
  nrdesc := First( [ 1 .. Length(descriptors) ], i -> descriptors[i]<>fail );
  nrprocess := waitinglist[ nrdesc ];
  Info( InfoSCSCP, 1, "Process number ", nrprocess, " is ready");
  result[nrprocess] := CompleteProcess( processes[nrprocess] );
  SubtractSet(waitinglist,[nrprocess]);
  if result[nrprocess].object = true then
    Info( InfoSCSCP, 1, "Process number ", nrprocess, " returned true, closing remaining processes");
    for i in waitinglist do
      # TerminateProcess( processes[i] );
      CloseStream( processes[i]![1]);
    od;
    return true;
  fi;    
od;
return result;
end;


#############################################################################
#
# FirstTrueProcess2( <process1>, <process2> )
#
# We can faster handle the case of two processes, avoiding list manipulations
#
FirstTrueProcess2 := function( a, b )
local result, descriptors;
result:=[];
descriptors := [ IO_GetFD( a![1]![1] ), IO_GetFD( b![1]![1] ) ];
IO_select( descriptors, [ ], [ ], 60*60, 0 );
if descriptors[1]<>fail then # 1st process is ready
  Info( InfoSCSCP, 1, "Process number 1 is ready");
  result[1] := CompleteProcess( a );
  if result[1].object = true then
    Info( InfoSCSCP, 1, "Process number 1 returned true, closing process number 2");
    CloseStream( b![1] );
    return true;
  fi;
  Info( InfoSCSCP, 1, "Closed 1st process, waiting for 2nd ...");  
  result[2] := CompleteProcess( b );
  return result;
elif descriptors[2]<>fail then # 2nd process is ready
  Info( InfoSCSCP, 1, "Process number 2 is ready");
  result[2] := CompleteProcess( b );
  if result[2].object = true then
    Info( InfoSCSCP, 1, "Process number 2 returned true, closing process number 1");
    CloseStream( a![1] );
    # TerminateProcess( a );
    return true;
  fi;  
  Info( InfoSCSCP, 1, "Closed 2nd process, waiting for 1st ...");  
  result[1] := CompleteProcess( a );  
  return result;
else
  Error("Error in Synchronize2, both descriptors failed!!! \n");
fi;
end;


#############################################################################
#
# FirstTrueProcess( <list of processes> )
# FirstTrueProcess( <process1>, ..., <processN> )
#
InstallGlobalFunction( FirstTrueProcess,
function( arg )
if Length(arg)=2 then
  return FirstTrueProcess2( arg[1], arg[2] );
else
  return FirstTrueProcessN( arg[1] );
fi;
end);