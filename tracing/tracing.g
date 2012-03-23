SCSCP_TRACE_FILE           := "/dev/null";
SCSCP_TRACE_MACHINE_NUMBER := "0";
SCSCP_TRACE_PROCESS_ID     := 0;
SCSCP_TRACE_THREAD_ID      := 0;
SCSCP_RESTORE_INFO_LEVEL   := 0;


BindGlobal( "SCSCPTraceStartTracing", 
function()
local t;
t := IO_gettimeofday();
PrintTo( SCSCP_TRACE_FILE, Concatenation( 
    "\"Start Tracing\"{[2]{0,0},", 
    String(t.tv_sec), 
    ".", 
    String(t.tv_usec), 
    ", 137, ", 
	SCSCP_TRACE_MACHINE_NUMBER, "};;\n" ) );
end);


BindGlobal( "SCSCPTraceEndTracing",
function()
local t;
t := IO_gettimeofday();
AppendTo( SCSCP_TRACE_FILE, Concatenation( 
    "\"End Tracing\"{[2]{0,0},", 
    String(t.tv_sec), 
    ".", 
    String(t.tv_usec), 
    ", 145, ", 
	SCSCP_TRACE_MACHINE_NUMBER, "};;\n" ) );
end);


BindGlobal( "SCSCPTraceNewProcess",
function()
local t;
t := IO_gettimeofday();
SCSCP_TRACE_PROCESS_ID:=SCSCP_TRACE_PROCESS_ID+1;
AppendTo( SCSCP_TRACE_FILE, Concatenation( 
    "\"New Process\"{[2]{0,0},", 
    String(t.tv_sec), 
    ".", 
    String(t.tv_usec), 
    ", 153, ", 
	SCSCP_TRACE_MACHINE_NUMBER, 
	",", 
	String(SCSCP_TRACE_PROCESS_ID), "};;\n" ) );
end);


BindGlobal( "SCSCPTraceEndProcess", 
function()
local t;
t := IO_gettimeofday();
AppendTo( SCSCP_TRACE_FILE, Concatenation( 
    "\"End Process\"{[2]{0,0},", 
    String(t.tv_sec), 
    ".", 
    String(t.tv_usec), 
    ", 161, ", 
	SCSCP_TRACE_MACHINE_NUMBER, 
	",", 
	String(SCSCP_TRACE_PROCESS_ID), "};;\n" ) );
end);


BindGlobal( "SCSCPTraceNewThread",
function()
local t;
t := IO_gettimeofday();
SCSCP_TRACE_THREAD_ID:=SCSCP_TRACE_THREAD_ID+1;
AppendTo( SCSCP_TRACE_FILE, Concatenation( 
    "\"New Thread\"{[2]{0,0},", 
    String(t.tv_sec), 
    ".", 
    String(t.tv_usec), 
    ", 169, ", 
	SCSCP_TRACE_MACHINE_NUMBER, ",", 
	String(SCSCP_TRACE_PROCESS_ID), ",",
	String(SCSCP_TRACE_THREAD_ID), ",0};;\n" ) ); # Last zero is "Outport ID"
end);


BindGlobal( "SCSCPTraceEndThread",
function()
local t;
t := IO_gettimeofday();
AppendTo( SCSCP_TRACE_FILE, Concatenation( 
    "\"End Thread\"{[2]{0,0},",
    String(t.tv_sec), 
    ".", 
    String(t.tv_usec), 
    ", 177, ", 
	SCSCP_TRACE_MACHINE_NUMBER, ",", 
	String(SCSCP_TRACE_PROCESS_ID), ",",
	String(SCSCP_TRACE_THREAD_ID), "};;\n" ) );
end);


BindGlobal( "SCSCPTraceRunThread",
function()
local t;
t := IO_gettimeofday();
AppendTo( SCSCP_TRACE_FILE, Concatenation( 
    "\"Run Thread\"{[2]{0,0},", 
    String(t.tv_sec), 
    ".", 
    String(t.tv_usec), 
    ", 185, ", 
	SCSCP_TRACE_MACHINE_NUMBER, ",", 
	String(SCSCP_TRACE_PROCESS_ID), ",",
	String(SCSCP_TRACE_THREAD_ID), "};;\n" ) );
end);


BindGlobal( "SCSCPTraceSuspendThread",
function()
local t;
t := IO_gettimeofday();
AppendTo( SCSCP_TRACE_FILE, Concatenation( 
    "\"Suspend Thread\"{[2]{0,0},", 
    String(t.tv_sec), 
    ".", 
    String(t.tv_usec), 
    ", 193, ", 
	SCSCP_TRACE_MACHINE_NUMBER, ",", 
	String(SCSCP_TRACE_PROCESS_ID), ",",
	String(SCSCP_TRACE_THREAD_ID), "};;\n" ) );
end);


BindGlobal( "SCSCPTraceBlockThread",
function()
local t;
t := IO_gettimeofday();
AppendTo( SCSCP_TRACE_FILE, Concatenation( 
    "\"Block Thread\"{[2]{0,0},", 
    String(t.tv_sec), 
    ".", String(t.tv_usec), 
    ", 201, ", 
	SCSCP_TRACE_MACHINE_NUMBER, ",", 
	String(SCSCP_TRACE_PROCESS_ID), ",",
	String(SCSCP_TRACE_THREAD_ID), ",0,0};;\n" ) );
	# last two zeroes are "Inport ID" and "Block Reason"
end);


BindGlobal( "SCSCPTraceDeblockThread",
function()
local t;
t := IO_gettimeofday();
AppendTo( SCSCP_TRACE_FILE, Concatenation( 
    "\"Deblock Thread\"{[2]{0,0},", 
    String(t.tv_sec), 
    ".", 
    String(t.tv_usec), 
    ", 209, ", 
	SCSCP_TRACE_MACHINE_NUMBER, ",", 
	String(SCSCP_TRACE_PROCESS_ID), ",",
	String(SCSCP_TRACE_THREAD_ID), "};;\n" ) );
end);


BindGlobal( "SCSCPTraceSendMessage",
function( recipient )
local t;
t := IO_gettimeofday();
AppendTo( SCSCP_TRACE_FILE, Concatenation( 
    "\"Send Message\"{[2]{0,0},", 
    String(t.tv_sec), 
    ".", 
    String(t.tv_usec), 
    ", 217, ", 
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
AppendTo( SCSCP_TRACE_FILE, Concatenation( 
    "\"Receive Message\"{[2]{0,0},", 
    String(t.tv_sec), 
    ".", 
    String(t.tv_usec), 
    ", 225, ", 
	SCSCP_TRACE_MACHINE_NUMBER, ",", 
	String(SCSCP_TRACE_PROCESS_ID),  # "Receiving Process ID"
	",0,",                           # "Receiving Channel" ("Inport ID")
	String( sender ),                # "Sending Processor ID"
	",1,0,0,0};;\n" ) );             # 1,0,0,0 for "Sending Process ID",
	                                 # "Sending Channel" ("Outport ID"),
	                                 # "Tag of the message" and 
	                                 # "Size of message in words"
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


###########################################################################
##
#F  SCSCPLogTracesToGlobal
##
##  <#GAPDoc Label="SCSCPLogTracesToGlobal">
##  
##  <ManSection>
##  <Func Name="SCSCPLogTracesToGlobal" Arg="testname"/>
##  <Func Name="SCSCPLogTracesToGlobal" Arg="" Label="to stop tracing"/>
##  <Description>
##  To analyse the performance of parallel &SCSCP; framework, we make 
##  use of the &EdenTV; program <Cite Key="EdenTV" /> developed initially 
##  to visualize the performance of parallel programs written in functional 
##  programming language Eden, and now distributed under the 
##  GNU Public License and available from
##  <URL>http://www.mathematik.uni-marburg.de/~eden/?content=EdenTV</URL>.
##  <P/>
##  Called with the string containing the name of the test, this functions
##  turns on writing information about key activity events into trace files in
##  current directories for the client and servers listed <Ref
##  Var="SCSCPservers" />. The trace file will have the name of the format
##  <A>testname</A><C>.client.tr</C> for the client and
##  <A>testname</A><C>.&lt;hostname>.&lt;port>.tr</C> for the server. After the
##  test these files should be collected from remote servers and concatenated
##  (e.g. using <File>cat</File>) together with the standard preamble from the
##  file <File>scscp/tracing/stdhead.txt</File> (we recommend to put after the
##  preamble first all traces from servers and then the client's traces to have
##  nicer diagrams). The resulting file then may be opened with &EdenTV;.
##  <P/>
##  In the following example we use a dual core MacBook laptop to generate trace 
##  files for two tests and then show their corresponding trace diagrams:
##  <Log>
##  <![CDATA[
##  SCSCPLogTracesToGlobal("quillen100");
##  ParListWithSCSCP( List( [1..100], i->[512,i]), "QuillenSeriesByIdGroup" );
##  SCSCPLogTracesToGlobal();
##  SCSCPLogTracesToGlobal( "euler" );
##  ParListWithSCSCP( [1..1000], "WS_Phi" );
##  SCSCPLogTracesToGlobal();
##  ]]>
##  </Log>
##  <Alt Only="LaTeX">\centerline{\resizebox{150mm}{!}{\includegraphics{img/quillen.pdf}}}</Alt>
##  <Alt Only="HTML">&lt;img src="img/quillen.jpg" align="left" /></Alt>
##  <Alt Only="LaTeX">\vspace{10pt}\centerline{\resizebox{150mm}{!}{\includegraphics{img/euler.pdf}}}</Alt>
##  <Alt Only="HTML">&lt;img src="img/euler.jpg" align="left" /></Alt>
##  <Alt Only="Text">/See diagrams in HTML and PDF versions of the manual/</Alt>
##  The diagrams (made on an dual core MacBook laptop), shows that in the first
##  case parallelising is efficient and master successfully distributes load to
##  workers, while in the second case a single computation is just too short,
##  so most of the time is spent on communication. To parallelize the Euler's
##  function example efficiently, tasks must rather be grouped in chunks, which
##  should be enough large to reduce the communication overload, but enough
##  small to ensure that tasks are evenly distributed.
##  <P/>
##  Of course, tracing can be used to investigate communication between a client
##  and a single server in a non-parallel context as well. For this purpose,
##  <Ref Var="SCSCPservers" /> must be modified to contain only one server.   
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
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
SCSCPLogTracesTo( 
  Concatenation( testname, ".", 
                 SCSCPserverAddress, ".", 
                 String( SCSCPserverPort ) ) );
return true;
end);


BindGlobal( "SCSCPStopTracing",
function()
SCSCPLogTracesTo();
return true;
end);

