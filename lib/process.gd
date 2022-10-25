###########################################################################
##
#W process.gd               The SCSCP package            Olexandr Konovalov
#W                                                             Steve Linton
##
###########################################################################


###########################################################################
##
#C  IsProcess
##
##  <#GAPDoc Label="IsProcess">
##  
##  <ManSection>
##  <Filt Name="IsProcess" />
##  <Description>
##  This is the category of processes.
##  Processes in this category are created 
##  using the function <Ref Func="NewProcess" />.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsProcess", IsObject );
DeclareCategoryCollections( "IsProcess" );


###########################################################################
##
#F  NewProcess
##
##  <#GAPDoc Label="NewProcess">
##  
##  <ManSection>
##  <Func Name="NewProcess" Arg="command listargs server port"/>
##  <Func Name="NewProcess" Arg="command listargs connection"
##        Label="for SCSCP connection" />
##  <Returns>
##    object in the category <C>IsProcess</C>
##  </Returns>	 
##  <Description>
##     In the first form, <A>command</A> and <C>server</C> are strings, 
##     <A>listargs</A> is a list of &GAP; objects and <C>port</C> is an 
##     integer.
##     <P/>
##     In the second form, an &SCSCP; connection in the category 
##     <Ref Func="NewSCSCPconnection" /> is used instead of 
##     <C>server</C> and <C>port</C>.
##     <P/>
##     Calls the &SCSCP; procedure with the name <A>command</A> 
##     and the list of arguments <A>listargs</A> at the server and port
##     given by <A>server</A> and <A>port</A> or encapsulated in the
##     <A>connection</A>. Returns an object in
##     the category <C>IsProcess</C> for the subsequent
##     waiting the result from its underlying stream.
##     <P/>
##     It accepts the following options:
##     <List>
##     <Item> 
##     <C>output:="object"</C> is used to specify that the server must
##        return the actual object evaluated as a result of the procedure 
##        call. This is the default action requested by the client if the 
##        <C>output</C> option is omitted.
##     </Item>
##     <Item>
##     <C>output:="cookie"</C>
##         is used to specify that the result of the 
##         procedure call should be stored on the server, and the
##         server should return a remote object (see <Ref Sect="Remote" /> )
##         pointing to that result (that is, a cookie);
##     </Item>
##     <Item>
##     <C>output:="nothing"</C> is used to specify that the server is 
##         supposed to reply with a <C>procedure_completed</C> message 
##         carrying no object just to signal that the call was completed 
##         successfully (for the compatibility, this will be evaluated to 
##         a <C>"procedure completed"</C> string on the client's side);
##     </Item>
##     <Item>
##     <C>cd:="cdname"</C> is used to specify that the &OpenMath; symbol 
##         corresponding to the first argument <A>command</A> should be 
##         looked up in the particular content dictionary <C>cdname</C>. 
##         Otherwise, it will be looked for in the default content 
##         dictionary (<C>scscp_transient_1</C> for the &GAP; &SCSCP; server);
##     </Item>
##     <Item>
##     <C>debuglevel:=N</C> is used to obtain additional information 
##         attributes together with the result. The &GAP; &SCSCP; server 
##         does the following: if <C>N=1</C>, it will report about the CPU 
##         time in milliseconds required to compute the result; if <C>N=2</C> 
##         it will additionally report about the amount of memory used by 
##         &GAP; in bytes will be returned (using the output of 
##         <Ref Func="MemoryUsageByGAPinKbytes" /> converted to bytes);
##         if <C>N=3</C> it will additionally report the amount of memory 
##         in bytes used by the resulting object and its subobjects (using 
##         the output of <Ref BookName="ref" Oper="MemoryUsage" />).
##     </Item>
##     <!--TODO: document "deferred" and "tree" options -->
##     </List>
##     See <Ref Func="CompleteProcess" /> and 
##     <Ref Func="EvaluateBySCSCP" /> for examples.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction ( "NewProcess" );


###########################################################################
##
#F  CompleteProcess
##
##  <#GAPDoc Label="CompleteProcess">
##  
##  <ManSection>
##  <Func Name="CompleteProcess" Arg="process"/>
##  <Returns>
##    record with components <C>object</C> and <C>attributes</C> 
##  </Returns>	 
##     <Description>
##       The function waits, if necessary, until the underlying stream 
##       of the process will contain some data, then reads the appropriate 
##       &OpenMath; object from this stream and closes it.
##       <P/>
##       It has the option <C>output</C> which may have two values:
##       <List>
##       <Item> 
##       <C>output:="cookie"</C> has the same meaning 
##                               as for the <Ref Func="NewProcess" />
##       </Item>
##       <Item>
##       <C>output:="tree"</C> is used to specify that the result 
##                             obtained from the server should be 
##                             returned as an XML parsed tree 
##                             without its evaluation.
##       </Item>
##       </List>
##  In the following example we demonstrate combination of the two 
##  previous functions to send request and get result, calling the 
##  procedure <C>WS_Factorial</C>, installed in the previous chapter: 
##  <Example>
##  <![CDATA[
##  gap> s := NewProcess( "WS_Factorial", [10], "localhost", 26133 );                  
##  < process at localhost:26133 pid=52918 >
##  gap> x := CompleteProcess(s);
##  rec( attributes := [ [ "call_id", "localhost:26133:52918:TPNiMjCT" ] ],
##    object := 3628800 )
##  ]]>
##  </Example>
##  See more examples in the description of the function 
##  <Ref Func="EvaluateBySCSCP" />, which combines the two previous 
##  functions by sending request and getting result in one call.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction ( "CompleteProcess" );


###########################################################################
##
#F  TerminateProcess
##
##  <#GAPDoc Label="TerminateProcess">
##  
##  <ManSection>
##  <Func Name="TerminateProcess" Arg="process"/>
##  <Description>
##  The function is supposed to send an <Q>out-of-band</Q>
##  interrupt signal to the server.
##  Current implementation works only when the server is running as
##  <Q>localhost</Q> by sending a <C>SIGINT</C> to the server 
##  using its PID contained in the <A>process</A>. It will do nothing
##  if the server is running remotely, as the &SCSCP; specification 
##  allows the server to ignore interrupt messages. Remote interrupts
##  will be introduced in one of the next versions of the package.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction ( "TerminateProcess" );


###########################################################################
##
#F  SynchronizeProcesses
##
##  <#GAPDoc Label="SynchronizeProcesses">
##  
##  <ManSection>
##  <Func Name="SynchronizeProcesses" Arg="process1 process2 ... processN"/>  
##  <Func Name="SynchronizeProcesses" Arg="proclist" Label="for list of processes"/>
##  <Returns>
##    list of records with components <C>object</C> and <C>attributes</C> 
##  </Returns>         
##  <Description>
##  The function collects results of from each process given in the argument,
##  and returns the list, <M>i</M>-th entry of which is the result obtained
##  from the <M>i</M>-th process. The function accepts both one argument that 
##  is a list of processes, and arbitrary number of arguments, each of them 
##  being a process.
##  <Example>
##  <![CDATA[
##  gap> a:=NewProcess( "WS_Factorial", [10], "localhost", 26133 );
##  < process at localhost:26133 pid=2064 >
##  gap> b:=NewProcess( "WS_Factorial", [20], "localhost", 26134 );
##  < process at localhost:26134 pid=1975 >
##  gap> SynchronizeProcesses(a,b);
##  [ rec( attributes := [ [ "call_id", "localhost:26133:2064:yCWBGYFO" ] ], 
##        object := 3628800 ), 
##    rec( attributes := [ [ "call_id", "localhost:26134:1975:yAAWvGTL" ] ], 
##        object := 2432902008176640000 ) ]
##  ]]>
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction ( "SynchronizeProcesses" );


###########################################################################
##
#F  FirstProcess
##
##  <#GAPDoc Label="FirstProcess">
##  
##  <ManSection>
##  <Func Name="FirstProcess" Arg="process1 process2 ... processN"/>
##  <Func Name="FirstProcess" Arg="proclist" Label="for list of processes"/>
##  <Returns>
##    records with components <C>object</C> and <C>attributes</C> 
##  </Returns>         
##  <Description>
##  The function waits for the result from each process given in the argument,
##  and returns the result coming first, terminating all remaining processes at 
##  the same time. The function accepts both one argument that is a list of 
##  processes, and arbitrary number of arguments, each of them being a process.
##  <Example>
##  <![CDATA[
##  gap> a:=NewProcess( "WS_Factorial", [10], "localhost", 26133 );
##  < process at localhost:26133 pid=2064 >
##  gap> b:=NewProcess( "WS_Factorial", [20], "localhost", 26134 );
##  < process at localhost:26134 pid=1975 >
##  gap>  FirstProcess(a,b); 
##  rec( attributes := [ [ "call_id", "localhost:26133:2064:mdb8RaO2" ] ], 
##    object := 3628800 )
##  ]]>
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction ( "FirstProcess" );


###########################################################################
##
#F  FirstTrueProcess
##
##  <#GAPDoc Label="FirstTrueProcess">
##  
##  <ManSection>
##  <Func Name="FirstTrueProcess" Arg="process1 process2 ... processN"/>
##  <Func Name="FirstTrueProcess" Arg="proclist" Label="for list of processes"/>
##  <Returns>
##    list of records
##  </Returns>  
##  <Description>
##  The function waits for the result from each process given in the argument,
##  and stops waiting as soon as the first <K>true</K> is returned, abandoning
##  all remaining processes. It returns a list containing a records with 
##  components <C>object</C> and <C>attributes</C> at the position corresponding
##  to the process that returned <K>true</K>. If none of the processes 
##  returned true, it will return a complete list of procedure call results.
##  <P/>
##  The function accepts both one argument that is a list of 
##  processes, and arbitrary number of arguments, each of them being a process.
##  <P/>
##  In the first example, the second call returns <K>true</K>:
##  <Example>
##  <![CDATA[
##  gap> a:=NewProcess( "IsPrimeInt", [2^15013-1], "localhost", 26134 );
##  < process at localhost:26134 pid=42554 >
##  gap> b:=NewProcess( "IsPrimeInt", [2^521-1], "localhost", 26133 );
##  < process at localhost:26133 pid=42448 >
##  gap> FirstTrueProcess(a,b); 
##  [ , rec( attributes := [ [ "call_id", "localhost:26133:42448:Lz1DL0ON" ] ], 
##        object := true ) ]
##  ]]>
##  </Example>
##  In the next example both calls return <K>false</K>:
##  <Example>
##  <![CDATA[
##  gap> a:=NewProcess( "IsPrimeInt", [2^520-1], "localhost", 26133 );
##  < process at localhost:26133 pid=42448 >
##  gap> b:=NewProcess( "IsPrimeInt", [2^15013-1], "localhost", 26134 );
##  < process at localhost:26134 pid=42554 >
##  gap> FirstTrueProcess(a,b); 
##  [ rec( attributes := [ [ "call_id", "localhost:26133:42448:nvsk8PQp" ] ], 
##        object := false ), 
##    rec( attributes := [ [ "call_id", "localhost:26134:42554:JnEYuXL8" ] ], 
##        object := false ) ]
##  ]]>
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction ( "FirstTrueProcess" );


###########################################################################
##
#E 
##