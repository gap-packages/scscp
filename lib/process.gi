#############################################################################
##
#W process.gi               The SCSCP package              Olexandr Konovalov
#W                                                               Steve Linton
##
#############################################################################

#############################################################################
# 
# The current stream is remembered to properly close the connection 
# after an exit from a break loop
#
SCSCP_CURRENT_SESSION_STREAM := fail;


#############################################################################
# 
# IsProcessRepresentation
#
# The 1st element is a stream
# The 2nd is a process id
# The 3rd is true if the process is a part of a multi-session
# (that is, the stream should not be closed after the process is
# completed in order to continue the session without another 
# handshaking stage
# 
DeclareRepresentation( "IsProcessRepresentation", 
                       IsPositionalObjectRep,
                       [ 1, 2, 3 ] );
                       
ProcessesFamily := NewFamily( "ProcessesFamily(...)", IsProcess );
                       
ProcessDefaultType := NewType( ProcessesFamily, 
                               IsProcessRepresentation and IsProcess);

if IsReadOnlyGlobal("OnQuit") then
    MakeReadWriteGlobal("OnQuit");
    BindGlobal("OriginalOnQuit", OnQuit);
fi;

OnQuit:=function()
if SCSCP_CURRENT_SESSION_STREAM <> fail then
    if not IsClosedStream( SCSCP_CURRENT_SESSION_STREAM ) then
        Print( "SCSCP : ", SCSCP_CURRENT_SESSION_STREAM );
        CloseStream( SCSCP_CURRENT_SESSION_STREAM );
        Print( " is closed\n" );
    fi;    
    SCSCP_CURRENT_SESSION_STREAM := fail;
fi;    
OriginalOnQuit();
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
    Print( "process " );
    if proc![3] then
        Print("in session ");
    fi;    
    Print("at ",stream![2],":",stream![3][1], " pid=", pid, " >");
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
    Print( "process " );
    if proc![3] then
        Print("in session ");
    fi; 
    Print("at ",stream![2],":",stream![3][1], " pid=", pid, " >");
end);


#############################################################################
#
# NewProcess( command, listargs, <connection | server, port> : 
#                               output:=object/tree/coookie/nothing/deferred, 
#                                             cd:="cdname", debuglevel:=N );
#
# The function sends the request to the SCSCP server, and
# returns the InputOutputTCPStream for waiting the result
#
InstallGlobalFunction( NewProcess, function( arg )

local tcpstream, session_id, omtext, localstream, output_option, debug_option, 
      cdname, attribs, ns, pos1, pos2, pid, token, multisession;

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

if Length(arg)=3 then
    tcpstream  := arg[3]![1]; # connection's stream 
    session_id := arg[3]![2]; # connection's session_id
    multisession := true;
else
    tcpstream  := InputOutputTCPStream( arg[3], arg[4] );
    session_id := StartSCSCPsession( tcpstream );
    multisession := false;
fi;
    
SCSCP_CURRENT_SESSION_STREAM := tcpstream;

pos1 := PositionNthOccurrence(session_id,':',2);
if pos1 <> fail then
    pid := Int( session_id{[ pos1+1 .. Length(session_id) ]} );
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
                        arg[1], 
                        rec(     object := arg[2], 
                             attributes := attribs ) : cd:=cdname );
    if IN_SCSCP_BINARY_MODE then
        localstream:=InputTextString( omtext );
        token:=ReadByte( localstream );
        while token <> fail do
            Print( EnsureCompleteHexNum( HexStringInt( token ) ) );
            token:=ReadByte( localstream );
        od;
        Print("\n#I  Total length ", Length(omtext), " bytes \n");
    else
        Print(omtext, "#I  Total length ", Length(omtext), " characters \n");
    fi;
    WriteAll( tcpstream, omtext );
    if IsInputOutputTCPStream( tcpstream ) then
        IO_Flush( tcpstream![1] );
    fi;
  
else
  
    OMPutProcedureCall( tcpstream, 
                        arg[1], 
                        rec(     object := arg[2], 
                             attributes := attribs ) : cd:=cdname );

fi;
              
Info( InfoSCSCP, 1, "Request sent ...");
SCSCP_CURRENT_SESSION_STREAM := fail;             
return Objectify( ProcessDefaultType, [ tcpstream, pid, multisession ] );
end); 


#############################################################################
#
# CompleteProcess( <process> : output:=cookie/tree );
#
# The function waits for the process completion, 
# then collects the result and closes the stream
#
InstallGlobalFunction( CompleteProcess, function( process )
local tcpstream, result, output_option;

if ValueOption( "output" ) <> fail then
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
    Info( InfoSCSCP, 2, "CompleteProcess failed to get result from ", 
                        tcpstream![2], ":", tcpstream![3][1], ", returning fail" );
else
    Info( InfoSCSCP, 2, "Got back: object ", result.object, 
                        " with attributes ", result.attributes );
fi; 
if not process![3] then # we are in single call session
  CloseStream(tcpstream); 
fi;  
SCSCP_CURRENT_SESSION_STREAM := fail;
return result;
end);


#############################################################################
#
# TerminateProcess( <process> )
#
InstallGlobalFunction( TerminateProcess, function( process )
CloseStream(process![1]);
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
InstallGlobalFunction( SynchronizeProcesses, function( arg )
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
InstallGlobalFunction( FirstProcess, function( arg )
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
      TerminateProcess( processes[i] );
    od;
    return result;
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
    return result;
  fi;
  Info( InfoSCSCP, 1, "Closed 1st process, waiting for 2nd ...");  
  result[2] := CompleteProcess( b );
  return result;
elif descriptors[2]<>fail then # 2nd process is ready
  Info( InfoSCSCP, 1, "Process number 2 is ready");
  result[2] := CompleteProcess( b );
  if result[2].object = true then
    Info( InfoSCSCP, 1, "Process number 2 returned true, closing process number 1");
    TerminateProcess( a );
    return result;
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
InstallGlobalFunction( FirstTrueProcess, function( arg )
if Length(arg)=2 then
  return FirstTrueProcess2( arg[1], arg[2] );
else
  return FirstTrueProcessN( arg[1] );
fi;
end);

###########################################################################
##
#E 
##