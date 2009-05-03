SCSCP_TRACE_FILE           := "/dev/null";
SCSCP_TRACE_MACHINE_NUMBER := "0";
SCSCP_TRACE_PROCESS_ID     := 0;
SCSCP_TRACE_THREAD_ID      := 0;
SCSCP_RESTORE_INFO_LEVEL   := 0;


BindGlobal( "SCSCPTraceStartTracing", 
function()
local t;
t := IO_gettimeofday();
PrintTo( SCSCP_TRACE_FILE, 
	Concatenation( "\"Start Tracing\"{[2]{0,0},", String(t.tv_sec), ".", String(t.tv_usec), ", 137, ", 
	SCSCP_TRACE_MACHINE_NUMBER, "};;\n" ) );
end);


BindGlobal( "SCSCPTraceEndTracing",
function()
local t;
t := IO_gettimeofday();
AppendTo( SCSCP_TRACE_FILE, 
	Concatenation( "\"End Tracing\"{[2]{0,0},", String(t.tv_sec), ".", String(t.tv_usec), ", 145, ", 
	SCSCP_TRACE_MACHINE_NUMBER, "};;\n" ) );
end);


BindGlobal( "SCSCPTraceNewProcess",
function()
local t;
t := IO_gettimeofday();
SCSCP_TRACE_PROCESS_ID:=SCSCP_TRACE_PROCESS_ID+1;
AppendTo( SCSCP_TRACE_FILE, 
	Concatenation( "\"New Process\"{[2]{0,0},", String(t.tv_sec), ".", String(t.tv_usec), ", 153, ", 
	SCSCP_TRACE_MACHINE_NUMBER, ",", String(SCSCP_TRACE_PROCESS_ID), "};;\n" ) );
end);


BindGlobal( "SCSCPTraceEndProcess", 
function()
local t;
t := IO_gettimeofday();
AppendTo( SCSCP_TRACE_FILE, 
	Concatenation( "\"End Process\"{[2]{0,0},", String(t.tv_sec), ".", String(t.tv_usec), ", 161, ", 
	SCSCP_TRACE_MACHINE_NUMBER, ",", String(SCSCP_TRACE_PROCESS_ID), "};;\n" ) );
end);


BindGlobal( "SCSCPTraceNewThread",
function()
local t;
t := IO_gettimeofday();
SCSCP_TRACE_THREAD_ID:=SCSCP_TRACE_THREAD_ID+1;
AppendTo( SCSCP_TRACE_FILE, 
	Concatenation( "\"New Thread\"{[2]{0,0},", String(t.tv_sec), ".", String(t.tv_usec), ", 169, ", 
	SCSCP_TRACE_MACHINE_NUMBER, ",", 
	String(SCSCP_TRACE_PROCESS_ID), ",",
	String(SCSCP_TRACE_THREAD_ID), ",0};;\n" ) ); # Last zero is "Outport ID"
end);


BindGlobal( "SCSCPTraceEndThread",
function()
local t;
t := IO_gettimeofday();
AppendTo( SCSCP_TRACE_FILE, 
	Concatenation( "\"End Thread\"{[2]{0,0},", String(t.tv_sec), ".", String(t.tv_usec), ", 177, ", 
	SCSCP_TRACE_MACHINE_NUMBER, ",", 
	String(SCSCP_TRACE_PROCESS_ID), ",",
	String(SCSCP_TRACE_THREAD_ID), "};;\n" ) );
end);


BindGlobal( "SCSCPTraceRunThread",
function()
local t;
t := IO_gettimeofday();
AppendTo( SCSCP_TRACE_FILE, 
	Concatenation( "\"Run Thread\"{[2]{0,0},", String(t.tv_sec), ".", String(t.tv_usec), ", 185, ", 
	SCSCP_TRACE_MACHINE_NUMBER, ",", 
	String(SCSCP_TRACE_PROCESS_ID), ",",
	String(SCSCP_TRACE_THREAD_ID), "};;\n" ) );
end);


BindGlobal( "SCSCPTraceSuspendThread",
function()
local t;
t := IO_gettimeofday();
AppendTo( SCSCP_TRACE_FILE, 
	Concatenation( "\"Suspend Thread\"{[2]{0,0},", String(t.tv_sec), ".", String(t.tv_usec), ", 193, ", 
	SCSCP_TRACE_MACHINE_NUMBER, ",", 
	String(SCSCP_TRACE_PROCESS_ID), ",",
	String(SCSCP_TRACE_THREAD_ID), "};;\n" ) );
end);


BindGlobal( "SCSCPTraceBlockThread",
function()
local t;
t := IO_gettimeofday();
AppendTo( SCSCP_TRACE_FILE, 
	Concatenation( "\"Block Thread\"{[2]{0,0},", String(t.tv_sec), ".", String(t.tv_usec), ", 201, ", 
	SCSCP_TRACE_MACHINE_NUMBER, ",", 
	String(SCSCP_TRACE_PROCESS_ID), ",",
	String(SCSCP_TRACE_THREAD_ID), ",0,0};;\n" ) );
	# last two zeroes are "Inport ID" and "Block Reason"
end);


BindGlobal( "SCSCPTraceDeblockThread",
function()
local t;
t := IO_gettimeofday();
AppendTo( SCSCP_TRACE_FILE, 
	Concatenation( "\"Deblock Thread\"{[2]{0,0},", String(t.tv_sec), ".", String(t.tv_usec), ", 209, ", 
	SCSCP_TRACE_MACHINE_NUMBER, ",", 
	String(SCSCP_TRACE_PROCESS_ID), ",",
	String(SCSCP_TRACE_THREAD_ID), "};;\n" ) );
end);


BindGlobal( "SCSCPTraceSendMessage",
function( recipient )
local t;
t := IO_gettimeofday();
AppendTo( SCSCP_TRACE_FILE, 
	Concatenation( "\"Send Message\"{[2]{0,0},", String(t.tv_sec), ".", String(t.tv_usec), ", 217, ", 
	SCSCP_TRACE_MACHINE_NUMBER, ",", 
	String(SCSCP_TRACE_PROCESS_ID),  # "Sending Process ID"
	",0,",                           # "Sending Channel" ("Outport ID")
	String( recipient ),	         # "Receiving Processor Number"
	",1,0,0};;\n" ) );               #  1,0,0 for "Receiving Process ID", 
	                                 # "Receiving Channel" ("Inport ID") 
	                                 # and "Tag of the message"	
end);


BindGlobal( "SCSCPTraceReceiveMessage", 
function( sender )
local t;
t := IO_gettimeofday();
AppendTo( SCSCP_TRACE_FILE, 
	Concatenation( "\"Receive Message\"{[2]{0,0},", String(t.tv_sec), ".", String(t.tv_usec), ", 225, ", 
	SCSCP_TRACE_MACHINE_NUMBER, ",", 
	String(SCSCP_TRACE_PROCESS_ID),  # "Receiving Process ID"
	",0,",                           # "Receiving Channel" ("Inport ID")
	String( sender ),                # "Sending Processor ID"
	",1,0,0,0};;\n" ) );             # 1,0,0,0 for "Sending Process ID",
	                                 # "Sending Channel" ("Outport ID"),
	                                 # "Tag of the message" and "Size of message in words"
end);


BindGlobal( "SCSCPLogTracesTo",
function( arg )
if Length(arg)=0 then
    SCSCPTraceEndThread(); 
    SCSCPTraceEndProcess();
	SCSCPTraceEndTracing();
	IN_SCSCP_TRACING_MODE:=false;
	SetInfoLevel( InfoSCSCP, SCSCP_RESTORE_INFO_LEVEL );
elif Length(arg)=1 and IsString(arg[1]) then
    SCSCP_RESTORE_INFO_LEVEL := InfoLevel( InfoSCSCP );
    SetInfoLevel(InfoSCSCP,0);
	IN_SCSCP_TRACING_MODE := true;
	if SCSCPserverMode then
		SCSCP_TRACE_FILE := Concatenation( arg[1], ".tr" );
	else
		SCSCP_TRACE_FILE := Concatenation( arg[1], ".client.tr" );
	fi;	
	SCSCP_TRACE_PROCESS_ID:=0;
	SCSCP_TRACE_THREAD_ID:=0;
	if SCSCPserverMode then
		SCSCP_TRACE_MACHINE_NUMBER := String( SCSCPserverPort ); # for the server
	else 
		SCSCP_TRACE_MACHINE_NUMBER := "0"; # for the client
	fi;	
	SCSCPTraceStartTracing();
	SCSCPTraceNewProcess(); 
	SCSCPTraceNewThread(); 
	SCSCPTraceRunThread(); 
else
	Error("SCSCPLogTracesTo : the number of arguments must be 0 or 1");	
fi;	
end);


BindGlobal( "SCSCPLogTracesToGlobal",
function( arg )
local server, testname;
if Length(arg)=0 then
	SCSCPLogTracesTo();
	for server in SCSCPservers do
		EvaluateBySCSCP( "SCSCPStopTracing",[ ], server[1], server[2] );
    od;
elif Length(arg)=1 and IsString(arg[1]) then
    testname := arg[1];
	for server in SCSCPservers do
		EvaluateBySCSCP("SCSCPStartTracing",[ testname ], server[1], server[2] );
	od;
	SCSCPLogTracesTo( testname );
else
	Error("SCSCPLogTracesTo : the number of arguments must be 0 or 1");	
fi;	
end);


#############################################################################
#
# procedures to start/stop tracing
#
BindGlobal( "SCSCPStartTracing",
function( testname )
SCSCPLogTracesTo( Concatenation( testname, ".", SCSCPserverAddress, ".", String( SCSCPserverPort ) ) );
return true;
end);


BindGlobal( "SCSCPStopTracing",
function()
SCSCPLogTracesTo();
return true;
end);

