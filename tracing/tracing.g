SCSCP_TRACE_FILE          := 0;
SCSCP_TRACE_MACHINE_ID    := "0";
SCSCP_TRACE_PROCESS_COUNT :=0;
SCSCP_TRACE_THREAD_COUNT  :=0;
SCSCP_RESTORE_INFO_LEVEL  :=0;

SCSCPTraceStartTracing := function()
PrintTo( SCSCP_TRACE_FILE, 
	Concatenation( "\"Start Tracing\"{[2]{0,0},", REALTIME(), ", 137, ", 
	SCSCP_TRACE_MACHINE_ID, "};;\n" ) );
end;

SCSCPTraceEndTracing := function()
AppendTo( SCSCP_TRACE_FILE, 
	Concatenation( "\"End Tracing\"{[2]{0,0},", REALTIME(), ", 145, ", 
	SCSCP_TRACE_MACHINE_ID, "};;\n" ) );
end;

SCSCPTraceNewProcess := function()
SCSCP_TRACE_PROCESS_COUNT:=SCSCP_TRACE_PROCESS_COUNT+1;
AppendTo( SCSCP_TRACE_FILE, 
	Concatenation( "\"New Process\"{[2]{0,0},", REALTIME(), ", 153, ", 
	SCSCP_TRACE_MACHINE_ID, ",", String(SCSCP_TRACE_PROCESS_COUNT), "};;\n" ) );
end;

SCSCPTraceEndProcess := function()
AppendTo( SCSCP_TRACE_FILE, 
	Concatenation( "\"End Process\"{[2]{0,0},", REALTIME(), ", 161, ", 
	SCSCP_TRACE_MACHINE_ID, ",", String(SCSCP_TRACE_PROCESS_COUNT), "};;\n" ) );
end;

SCSCPTraceNewThread := function()
SCSCP_TRACE_THREAD_COUNT:=SCSCP_TRACE_THREAD_COUNT+1;
AppendTo( SCSCP_TRACE_FILE, 
	Concatenation( "\"New Thread\"{[2]{0,0},", REALTIME(), ", 169, ", 
	SCSCP_TRACE_MACHINE_ID, ",", 
	String(SCSCP_TRACE_PROCESS_COUNT), ",",
	String(SCSCP_TRACE_THREAD_COUNT), ",0};;\n" ) );
end;

SCSCPTraceRunThread := function()
AppendTo( SCSCP_TRACE_FILE, 
	Concatenation( "\"Run Thread\"{[2]{0,0},", REALTIME(), ", 185, ", 
	SCSCP_TRACE_MACHINE_ID, ",", 
	String(SCSCP_TRACE_PROCESS_COUNT), ",",
	String(SCSCP_TRACE_THREAD_COUNT), "};;\n" ) );
end;

SCSCPTraceSuspendThread := function()
AppendTo( SCSCP_TRACE_FILE, 
	Concatenation( "\"Suspend Thread\"{[2]{0,0},", REALTIME(), ", 193, ", 
	SCSCP_TRACE_MACHINE_ID, ",", 
	String(SCSCP_TRACE_PROCESS_COUNT), ",",
	String(SCSCP_TRACE_THREAD_COUNT), "};;\n" ) );
end;

SCSCPTraceBlockThread := function()
AppendTo( SCSCP_TRACE_FILE, 
	Concatenation( "\"Block Thread\"{[2]{0,0},", REALTIME(), ", 201, ", 
	SCSCP_TRACE_MACHINE_ID, ",", 
	String(SCSCP_TRACE_PROCESS_COUNT), ",",
	String(SCSCP_TRACE_THREAD_COUNT), ",0,0};;\n" ) );
end;

SCSCPTraceDeblockThread := function()
AppendTo( SCSCP_TRACE_FILE, 
	Concatenation( "\"Deblock Thread\"{[2]{0,0},", REALTIME(), ", 209, ", 
	SCSCP_TRACE_MACHINE_ID, ",", 
	String(SCSCP_TRACE_PROCESS_COUNT), ",",
	String(SCSCP_TRACE_THREAD_COUNT), "};;\n" ) );
end;

SCSCPTraceEndThread := function()
AppendTo( SCSCP_TRACE_FILE, 
	Concatenation( "\"End Thread\"{[2]{0,0},", REALTIME(), ", 177, ", 
	SCSCP_TRACE_MACHINE_ID, ",", 
	String(SCSCP_TRACE_PROCESS_COUNT), ",",
	String(SCSCP_TRACE_THREAD_COUNT), "};;\n" ) );
end;

SCSCPTraceSendMessage := function( recipient )
AppendTo( SCSCP_TRACE_FILE, 
	Concatenation( "\"Send Message\"{[2]{0,0},", REALTIME(), ", 217, ", 
	SCSCP_TRACE_MACHINE_ID, ",", 
	String(SCSCP_TRACE_PROCESS_COUNT), ",0,",
	String(recipient),
	",1,0,0};;\n" ) );
end;

SCSCPTraceReceiveMessage := function( sender )
AppendTo( SCSCP_TRACE_FILE, 
	Concatenation( "\"Receive Message\"{[2]{0,0},", REALTIME(), ", 225, ", 
	SCSCP_TRACE_MACHINE_ID, ",", 
	String(SCSCP_TRACE_PROCESS_COUNT), ",0,",
	String( sender ),
	",1,0,0,0};;\n" ) );
end;

SCSCPLogTracesTo := function( arg )
if Length(arg)=0 then
	SCSCPTraceEndTracing();
	IN_SCSCP_TRACING_MODE:=false;
	SetInfoLevel( InfoSCSCP, SCSCP_RESTORE_INFO_LEVEL );
elif Length(arg)=1 and IsString(arg[1]) then
    SCSCP_RESTORE_INFO_LEVEL := InfoLevel( InfoSCSCP );
	IN_SCSCP_TRACING_MODE := true;
	if SCSCPserverMode then
		SCSCP_TRACE_FILE := Concatenation( arg[1], ".tr" );
	else
		SCSCP_TRACE_FILE := Concatenation( arg[1], ".client.tr" );
	fi;	
	SCSCP_TRACE_PROCESS_COUNT:=0;
	SCSCP_TRACE_THREAD_COUNT:=0;
	if SCSCPserverMode then
		SCSCP_TRACE_MACHINE_ID := String(SCSCPserverPort);
	else 
		SCSCP_TRACE_MACHINE_ID := "0"; # for the client
	fi;	
	SCSCPTraceStartTracing();
fi;
end;