###########################################################################
##
#W scscp.gd                 The SCSCP package            Olexandr Konovalov
#W                                                             Steve Linton
##
###########################################################################

# We declare two new Info classes for our package to be able to use them
# independently: one for the SCSCP communication and another for the 
# MasterWorker skeleton. To change the InfoLevel to k, use the command 
# of the form SetInfoLevel( Info<something>, k )

###########################################################################
##
#F  InfoSCSCP
##
##  <#GAPDoc Label="InfoSCSCP">
##  <ManSection>
##  <InfoClass Name="InfoSCSCP" Comm="Info class for SCSCP algorithms" />
##  <Description>
##  <Ref InfoClass="InfoSCSCP"/> is a special Info class for the &SCSCP; 
##  package. The amount of information to be displayed can be specified 
##  by the user by setting InfoLevel for this class from 0 to 4, and the 
##  default value of InfoLevel for the package is specified in the file 
##  <File>scscp/config.g</File>. 
##  The higher the level is, the more information will be displayed. 
##  To change the InfoLevel to <C>k</C>, use the command 
##  <C>SetInfoLevel(InfoSCSCP, k)</C>. 
##  In the following examples we demonstrate various degrees of output 
##  details using Info messages.
##  <P/>
##  Default Info level:
##  <Example>
##  <![CDATA[
##  gap> SetInfoLevel(InfoSCSCP,2);                              
##  gap> EvaluateBySCSCP( "WS_Factorial",[10],"localhost",26133); 
##  #I  Creating a socket ...
##  #I  Connecting to a remote socket via TCP/IP ...
##  #I  Got connection initiation message
##  #I  <?scscp service_name="GAP" service_version="4.dev" service_id="localhost:2\
##  6133:286" scscp_versions="1.0 1.1 1.2 1.3" ?>
##  #I  Requesting version 1.3 from the server ...
##  #I  Server confirmed version 1.3 to the client ...
##  #I  Request sent ...
##  #I  Waiting for reply ...
##  #I  <?scscp start ?>
##  #I  <?scscp end ?>
##  #I  Got back: object 3628800 with attributes 
##  [ [ "call_id", "localhost:26133:286:JL6KRQeh" ] ]
##  rec( attributes := [ [ "call_id", "localhost:26133:286:JL6KRQeh" ] ], 
##    object := 3628800 )
##  ]]>
##  </Example>
##  <P/>
##  Minimal Info level:
##  <Example>
##  <![CDATA[
##  gap> SetInfoLevel(InfoSCSCP,0);                              
##  gap> EvaluateBySCSCP( "WS_Factorial",[10],"localhost",26133);
##  rec( attributes := [ [ "call_id", "localhost:26133:286:jzjsp6th" ] ], 
##    object := 3628800 )
##  ]]>
##  </Example>
##  <P/>
##  Verbose Info level:
##  <Example>
##  <![CDATA[
##  gap> SetInfoLevel(InfoSCSCP,3);
##  gap> EvaluateBySCSCP( "WS_Factorial",[10],"localhost",26133);
##  #I  Creating a socket ...
##  #I  Connecting to a remote socket via TCP/IP ...
##  #I  Got connection initiation message
##  #I  <?scscp service_name="GAP" service_version="4.dev" service_id="localhost:2\
##  6133:286" scscp_versions="1.0 1.1 1.2 1.3" ?>
##  #I  Requesting version 1.3 from the server ...
##  #I  Server confirmed version 1.3 to the client ...
##  #I  Composing procedure_call message: 
##  <?scscp start ?>
##  <OMOBJ xmlns="http://www.openmath.org/OpenMath" version="2.0">
##  	<OMATTR>
##  		<OMATP>
##  			<OMS cd="scscp1" name="call_id"/>
##  			<OMSTR>localhost:26133:286:Jok6cQAf</OMSTR>
##  			<OMS cd="scscp1" name="option_return_object"/>
##  			<OMSTR></OMSTR>
##  		</OMATP>
##  		<OMA>
##  			<OMS cd="scscp1" name="procedure_call"/>
##  			<OMA>
##  				<OMS cd="scscp_transient_1" name="WS_Factorial"/>
##  				<OMI>10</OMI>
##  			</OMA>
##  		</OMA>
##  	</OMATTR>
##  </OMOBJ>
##  <?scscp end ?>
##  #I  Total length 396 characters 
##  #I  Request sent ...
##  #I  Waiting for reply ...
##  #I  <?scscp start ?>
##  #I Received message: 
##  <OMOBJ xmlns="http://www.openmath.org/OpenMath" version="2.0">
##  	<OMATTR>
##  		<OMATP>
##  			<OMS cd="scscp1" name="call_id"/>
##  			<OMSTR>localhost:26133:286:Jok6cQAf</OMSTR>
##  		</OMATP>
##  		<OMA>
##  			<OMS cd="scscp1" name="procedure_completed"/>
##  			<OMI>3628800</OMI>
##  		</OMA>
##  	</OMATTR>
##  </OMOBJ>
##  #I  <?scscp end ?>
##  #I  Got back: object 3628800 with attributes 
##  [ [ "call_id", "localhost:26133:286:Jok6cQAf" ] ]
##  rec( attributes := [ [ "call_id", "localhost:26133:286:Jok6cQAf" ] ], 
##    object := 3628800 )
##  gap> SetInfoLevel(InfoSCSCP,0);
##  ]]>
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareInfoClass("InfoSCSCP");


###########################################################################
##
#F  InfoMasterWorker
##
##  <#GAPDoc Label="InfoMasterWorker">
##  <ManSection>
##  <InfoClass Name="InfoMasterWorker" Comm="Info class for the Master-Worker skeleton" />
##  <Description>
##  <C>InfoMasterWorker</C> is a special Info class for the Master-Worker 
##  skeleton <Ref Func="ParListWithSCSCP" />.
##  The amount of information to be displayed can be specified by the user 
##  by setting InfoLevel for this class from 0 to 5, and the default value
##  of InfoLevel for the package is specified in the file <File>scscp/config.g</File>. 
##  The higher the level is, the more information will be displayed. 
##  To change the InfoLevel to <C>k</C>, use the command 
##  <C>SetInfoLevel(InfoMasterWorker, k)</C>. 
##  In the following examples we demonstrate various degrees of output 
##  details using Info messages.
##  <P/>
##  Default Info level:
##  <Example>
##  <![CDATA[
##  gap> SetInfoLevel(InfoMasterWorker,2);
##  gap> ParListWithSCSCP( List( [2..6], n -> SymmetricGroup(n)), "WS_IdGroup" );
##  #I  1/5:master --> localhost:26133
##  #I  2/5:master --> localhost:26134
##  #I  3/5:master --> localhost:26133
##  #I  4/5:master --> localhost:26134
##  #I  5/5:master --> localhost:26133
##  [ [ 2, 1 ], [ 6, 1 ], [ 24, 12 ], [ 120, 34 ], [ 720, 763 ] ]
##  ]]>
##  </Example>
##  <P/>
##  Minimal Info level:
##  <Example>
##  <![CDATA[
##  gap> SetInfoLevel(InfoSCSCP,0);       
##  gap> SetInfoLevel(InfoMasterWorker,0);
##  gap> ParListWithSCSCP( List( [2..6], n -> SymmetricGroup(n)), "WS_IdGroup" );
##  [ [ 2, 1 ], [ 6, 1 ], [ 24, 12 ], [ 120, 34 ], [ 720, 763 ] ]
##  ]]>
##  </Example>
##  <P/>
##  Verbose Info level:
##  <Example>
##  <![CDATA[
##  gap> SetInfoLevel(InfoMasterWorker,5);                                       
##  gap> ParListWithSCSCP( List( [2..6], n -> SymmetricGroup(n)), "WS_IdGroup" );
##  #I  1/5:master --> localhost:26133 : SymmetricGroup( [ 1 .. 2 ] )
##  #I  2/5:master --> localhost:26134 : SymmetricGroup( [ 1 .. 3 ] )
##  #I  localhost:26133 --> 1/5:master : [ 2, 1 ]
##  #I  3/5:master --> localhost:26133 : SymmetricGroup( [ 1 .. 4 ] )
##  #I  localhost:26134 --> 2/5:master : [ 6, 1 ]
##  #I  4/5:master --> localhost:26134 : SymmetricGroup( [ 1 .. 5 ] )
##  #I  localhost:26133 --> 3/5:master : [ 24, 12 ]
##  #I  5/5:master --> localhost:26133 : SymmetricGroup( [ 1 .. 6 ] )
##  #I  localhost:26134 --> 4/5:master : [ 120, 34 ]
##  #I  localhost:26133 --> 5/5:master : [ 720, 763 ]
##  [ [ 2, 1 ], [ 6, 1 ], [ 24, 12 ], [ 120, 34 ], [ 720, 763 ] ]
##  gap> SetInfoLevel(InfoMasterWorker,2);
##  ]]>
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareInfoClass("InfoMasterWorker");


###########################################################################
#
# Functions to support symbols from scscp2 CD
#
DeclareGlobalFunction( "SCSCP_RETRIEVE" );
DeclareGlobalFunction( "SCSCP_STORE_SESSION" );
DeclareGlobalFunction( "SCSCP_STORE_PERSISTENT" );
DeclareGlobalFunction( "SCSCP_UNBIND" );
DeclareGlobalFunction( "SCSCP_GET_ALLOWED_HEADS" );
DeclareGlobalFunction( "SCSCP_IS_ALLOWED_HEAD" );
DeclareGlobalFunction( "SCSCP_GET_SERVICE_DESCRIPTION" );
DeclareGlobalFunction( "SCSCP_GET_TRANSIENT_CD" );
DeclareGlobalFunction( "SCSCP_GET_SIGNATURE" );


###########################################################################
#
# Other global functions
#

###########################################################################
##
#F  InstallSCSCPprocedure
##
##  <#GAPDoc Label="InstallSCSCPprocedure">
##  
##  <ManSection>
##  <Func Name="InstallSCSCPprocedure" 
##  Arg="procname procfunc [, description ] [, narg1 [, narg2 ] [, signature ] ]"/>
##  <Returns>
##    nothing
##  </Returns>	 
##  <Description>
##  For a string <A>procname</A> and a function <A>procfunc</A>, <Ref
##  Func="InstallSCSCPprocedure" /> makes the <A>procfunc</A> available as
##  SCSCP procedure under the name <A>procname</A>, adding it to the
##  transient &OpenMath; content dictionary <C>scscp_transient_1</C> that
##  will exist during the service lifetime.
##  <P/>
##  The second argument <A>procfunc</A> may be either a standard or 
##  user-defined &GAP; function (procedure, operation, etc.).
##  <P/>
##  The rest of arguments are optional 
##  and may be used in a number of combinations:
##  <List>
##  <Item>
##    <A>description</A> is a string with the description of the procedure.
##    It may be used by the help system. If it is omitted, the procedure will
##    be reported as undocumented.
##  </Item>
##  <Item>
##    <A>narg1</A> is a non-negative integer, specifying the minimal number 
##    of arguments, and <A>narg2</A> is a non-negative integer or infinity, 
##    specifying the maximal number of arguments.
##    If <A>narg2</A> is omitted then the maximal number of arguments 
##    will be set to <A>narg1</A>. If both <A>narg1</A> and <A>narg2</A> 
##    are omitted then the minimal number of arguments will be set to zero
##    and their maximal number will be set to infinity.
##  </Item>
##  <Item>
##    <A>signature</A> is the signature record of the procedure. If the
##    <A>signature</A> is given, then the number of arguments must be
##    explicitly specified (by <A>narg1</A> with or without <A>narg2</A>) at
##    least to zero and infinity respectively (to ensure proper matching of
##    arguments). Note that it is completely acceptable for a symbol from a
##    transient content dictionary to overstate the set of symbols which may
##    occur in its children using the <C>scscp2.symbol_set_all</C> symbol,
##    and to use standard &OpenMath; errors to reject requests later at the
##    stage of their evaluation. For example, using such approach, we will
##    define the procedure <C>WS_Factorial</C> accepting not only immediate
##    <C>&lt;OMI></C> objects but anything which could be evaluated to an 
##    integer.
##    <P/>.
##    The signature must be either a list of records, where <M>i</M>-th
##    record corresponds to the <M>i</M>-th argument, or a record itself
##    meaning that it specifies the signature for all arguments. In the
##    latter case the record may be <C>rec( )</C> corresponding to the
##    <C>scscp2.symbol_set_all</C> symbol (this will be assumed by default 
##    if the signature will be omitted). 
##    <P/>
##    If more detailed description of allowed arguments is needed, the 
##    signature record (one for all arguments or a specific one) may 
##    have components <C>CDgroups</C>, <C>CDs</C> and <C>Symbols</C>. 
##    The first two are lists of names of content dictionary groups and 
##    content dictionaries, and the third is a record whose components 
##    are names of content dictionaries, containing lists of names of 
##    allowed symbols from these dictionaries,for example: 
##  <Log>
##  <![CDATA[
##  signature := rec( CDgroups := [ "scscp" ],
##                CDs := [ "arith1", "linalg1" ],
##                Symbols := rec( polyd1 := [ "DMP", "term", "SDMP" ],
##                                polyu := [ "poly_u_rep", "term" ] ) );
##  ]]>
##  </Log>
##  </Item>
##  </List>
##  
##  In the following example we define the function <C>WS_Factorial</C>
##  that takes an integers and returns its factorial, using only mandatory
##  arguments of <Ref Func="InstallSCSCPprocedure" />:
##  
##  <Log>
##  <![CDATA[
##  gap> InstallSCSCPprocedure( "WS_Factorial", Factorial );
##  InstallSCSCPprocedure : procedure WS_Factorial installed. 
##  ]]>
##  </Log>
##  
##  In the following example we install the procedure that will accept a list
##  of permutations and return the number in the &GAP; Small Groups library
##  of the group they generate (for the sake of simplicity we omit tests of
##  validity of arguments, availability of <C>IdGroup</C> for groups of given 
##  order etc.)
##  
##  <Log>
##  <![CDATA[
##  gap> IdGroupByGenerators:=function( permlist )
##  > return IdGroup( Group( permlist ) );
##  > end;
##  function( permlist ) ... end
##  gap> InstallSCSCPprocedure( "GroupIdentificationService", IdGroupByGenerators );
##  InstallSCSCPprocedure : procedure GroupIdentificationService installed. 
##  ]]>
##  </Log>
##  
##  After installation, the procedure may be reinstalled, if necessary:
##  
##  <Log>
##  <![CDATA[
##  gap> InstallSCSCPprocedure( "WS_Factorial", Factorial );
##  WS_Factorial is already installed. Do you want to reinstall it [y/n]? y
##  InstallSCSCPprocedure : procedure WS_Factorial reinstalled. 
##  ]]>
##  </Log>
##  
##  Finally, some examples of various combinations of optional arguments:
##  <Log>
##  <![CDATA[
##  InstallSCSCPprocedure( "WS_Phi", Phi, 
##                         "Euler's totient function, see ?Phi in GAP", 1, 1 );
##  InstallSCSCPprocedure( "GroupIdentificationService", 
##                         IdGroupByGenerators, 1, infinity, rec() );
##  InstallSCSCPprocedure( "IdGroup512ByCode", IdGroup512ByCode, 1 );
##  InstallSCSCPprocedure( "WS_IdGroup", IdGroup, "See ?IdGroup in GAP" );
##  ]]>
##  </Log>
##  Note that it is quite acceptable to overstate the signature of the
##  procedure and use only mandatory arguments in a call to <Ref
##  Func="InstallSCSCPprocedure" />, which will be installed then as a
##  procedure that can accept arbitrary number of arguments encoded without any
##  restrictions on &OpenMath; symbols used, because anyway the &GAP; system
##  will return an error in case of the wrong number or type of arguments,
##  though it might be a good practice to give a way to the client to get more
##  precise procedure description a priori, that is before sending request. See
##  <Ref Sect="SpecialProcedures" /> about utilities for obtaining such
##  information about the &SCSCP; service.
##  <P/>
##  Some more examples of installation of SCSCP procedures 
##  are given in the file <File>scscp/example/myserver.g</File>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "InstallSCSCPprocedure" );


###########################################################################
##
#F  RunSCSCPserver
##
##  <#GAPDoc Label="RunSCSCPserver">
##  
##  <ManSection>
##  <Func Name="RunSCSCPserver" Arg="servertype port" />
##  <Returns>
##    nothing
##  </Returns>	 
##  <Description>
##       Will start the &SCSCP; server at port given by the integer
##       <A>port</A>. The first parameter <A>servertype</A> is either
##       <K>true</K>, <K>false</K> or a string containing the server
##       hostname:
##       <List>
##       <Item>
##           when <A>servertype</A> is <K>true</K>, the server will 
##           be started in a <Q>universal</Q> mode and will accept all 
##           incoming connections;
##       </Item>
##       <Item>
##           when <A>servertype</A> is <K>false</K>, the server will 
##           be started at <File>localhost</File> and will not accept 
##           any incoming connections from outside;
##       </Item>
##       <Item>
##           when <A>servertype</A> is a string, for example,
##           <File>"scscp.gap-system.org"</File>, the server will 
##           be accessible only by specified server name (this may be useful
##           to manage accessibility if, for example,
##           the hardware has several network interfaces). 
##       </Item>
##       </List>
##  <Log>
##  <![CDATA[
##  gap> RunSCSCPserver( "localhost", 26133 );
##  Ready to accept TCP/IP connections at localhost:26133 ...
##  Waiting for new client connection at localhost:26133 ...
##  ]]>
##  </Log>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "RunSCSCPserver" );


###########################################################################
##
#F  PingSCSCPservice
##
##  <#GAPDoc Label="PingSCSCPservice">
##  
##  <ManSection>
##  <Func Name="PingSCSCPservice" Arg="hostname portnumber" />
##  <Returns>
##    <K>true</K> or <K>fail</K>
##  </Returns>	 
##  <Description>
##  This function returns <K>true</K> if the client can establish
##  connection with the SCSCP server at <A>hostname</A>:<A>portnumber</A>.
##  Otherwise, it returns <K>fail</K>.
##  <Example>
##  <![CDATA[
##  gap> PingSCSCPservice("localhost",26133);
##  true
##  gap> PingSCSCPservice("localhost",26140);                     
##  Error: rec(
##    message := "Connection refused",
##    number := 61 )
##  fail
##  ]]>
##  </Example>
##  </Description>
##  </ManSection>           
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PingSCSCPservice" );


###########################################################################
##
#F  PingStatistic
##
##  <#GAPDoc Label="PingStatistic">
##  
##  <ManSection>
##  <Func Name="PingStatistic" Arg="hostname portnumber n" />
##  <Returns>
##    nothing
##  </Returns>	 
##  <Description>
##  The function is similar to the UNIX <C>ping</C>. It tries <A>n</A> 
##  times to establish connection with the SCSCP server at 
##  <A>hostname</A>:<A>portnumber</A>, and then displays statistical 
##  information.
##  <Example>
##  <![CDATA[
##  gap> PingStatistic("localhost",26133,1000);
##  1000 packets transmitted, 1000 received, 0% packet loss, time 208ms
##  min/avg/max = [ 0, 26/125, 6 ]
##  ]]>
##  </Example>
##  </Description>
##  </ManSection>           
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PingStatistic" );


###########################################################################
##
##  StartSCSCPsession( <stream> )
##
##  <#GAPDoc Label="StartSCSCPsession">
##  <ManSection>
##  <Func Name="StartSCSCPsession" Arg="stream"/>
##  <Returns>
##    string
##  </Returns>	 
##  <Description>
##  Initialises &SCSCP; session and negotiates with the server about the
##  version of the protocol. Returns the string with the <C>service_id</C>
##  (which may be used later as a part of the call identifier) or causes
##  an error message if can not perform these tasks.
##  <Example>
##  <![CDATA[
##  gap> s := InputOutputTCPStream("localhost",26133);
##  < input/output TCP stream to localhost:26133 >
##  gap> StartSCSCPsession(s);
##  "localhost:26133:5541"
##  gap> CloseStream( s );
##  ]]>
##  </Example>
##  After the call to <Ref Func="StartSCSCPsession"/> the &SCSCP; server is
##  ready to accept procedure calls.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "StartSCSCPsession" );


###########################################################################
##
#F  EvaluateBySCSCP
##
##  <#GAPDoc Label="EvaluateBySCSCP">
##  
##  <ManSection>
##  <Func Name="EvaluateBySCSCP" Arg="command listargs server port"/>
##  <Func Name="EvaluateBySCSCP" Arg="command listargs connection"
##        Label="for SCSCP connection" />
##  <Returns>
##    record with components <C>object</C> and <C>attributes</C> 
##  </Returns>	 
##  <Description>
##  In the first form, <A>command</A> and <C>server</C> are strings, 
##  <A>listargs</A> is a list of &GAP; objects and <C>port</C> is an 
##  integer.
##  <P/>
##  In the second form, an &SCSCP; connection in the category 
##  <Ref Func="NewSCSCPconnection" /> is used instead of 
##  <C>server</C> and <C>port</C>.
##  <P/>
##  Calls the SCSCP procedure with the name <A>command</A> 
##  and the list of arguments <A>listargs</A> at the server and port
##  given by <C>server</C> and <C>port</C> or encapsulated in the
##  <A>connection</A>.
##  <P/>
##  Since <Ref Func="EvaluateBySCSCP" /> combines <Ref Func="NewProcess" /> 
##  and <Ref Func="CompleteProcess" />, it accepts all options which may be
##  used by that functions ( <C>output</C>, <C>cd</C> and 
##  <C>debuglevel</C>  ) with the same meanings.
##  <Example>
##  <![CDATA[
##  gap> EvaluateBySCSCP( "WS_Factorial",[10],"localhost",26133);
##  rec( attributes := [ [ "call_id", "localhost:26133:2442:6hMEN40d" ] ], 
##    object := 3628800 )
##  gap> SetInfoLevel(InfoSCSCP,0);
##  gap> EvaluateBySCSCP( "WS_Factorial",[10],"localhost",26133 : output:="cookie" ); 
##  rec( attributes := [ [ "call_id", "localhost:26133:2442:jNQG6rml" ] ], 
##    object := < remote object scscp://localhost:26133/TEMPVarSCSCP5KZIeiKD > )
##  gap> EvaluateBySCSCP( "WS_Factorial",[10],"localhost",26133 : output:="nothing" );
##  rec( attributes := [ [ "call_id", "localhost:26133:2442:9QHQrCjv" ] ], 
##    object := "procedure completed" )
##  ]]>
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "EvaluateBySCSCP" );


###########################################################################
##
#F  ParQuickWithSCSCP
##
##  <#GAPDoc Label="ParQuickWithSCSCP">
##  
##  <ManSection>
##  <Func Name="ParQuickWithSCSCP" Arg="commands listargs"/>
##  <Returns>
##    record with components <C>object</C> and <C>attributes</C> 
##  </Returns>	 
##  <Description>
##  This function is constructed using the <Ref Func="FirstProcess"/>.
##  It is useful when it is not known which particular method is
##  more efficient, because it allows to call in parallel several procedures
##  (given by the list of their names <A>commands</A>) 
##  with the same list of arguments <A>listargs</A> (having
##  the same meaning as in <Ref Func="EvaluateBySCSCP"/>)
##  and obtain the result of that procedure call which will be computed faster.
##  <P/>  
##  In the example below we call two factorisation methods from the &GAP;
##  package <Package>FactInt</Package> to factorise <M>2^{150}+1</M>. The
##  example is selected in such a way that the runtime of these two methods is
##  approximately the same, so you should expect results from both methods in
##  some random order from repeated calls.
##  <Example>
##  <![CDATA[
##  gap> ParQuickWithSCSCP( [ "WS_FactorsECM", "WS_FactorsMPQS" ], [ 2^150+1 ] );
##  rec( attributes := [ [ "call_id", "localhost:26133:53877:GQX8MhC8" ] ],
##    object := [ [ 5, 5, 5, 13, 41, 61, 101, 1201, 1321, 63901 ],
##        [ 2175126601, 15767865236223301 ] ] )
##  ]]>
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ParQuickWithSCSCP" );


###########################################################################
##
#F  ParListWithSCSCP
##
##  <#GAPDoc Label="ParListWithSCSCP">
##  
##  <ManSection>
##  <Func Name="ParListWithSCSCP" Arg="listargs procname"/>
##  <Returns>
##    list
##  </Returns>         
##  <Description>
##  <Ref Func="ParListWithSCSCP" /> implements the well-known master-worker
##  skeleton: we have a master (&SCSCP; client) and a number of workers
##  (&SCSCP; servers) which obtain pieces of work from the client, perform the
##  required job and report back with the result, waiting for the next job.
##  <P/>
##  It returns the list of the same length as <A>listargs</A>, <M>i</M>-th
##  element of which is the result of calling the procedure <A>procname</A>
##  with the argument <A>listargs[i]</A>.
##  <P/>
##  It accepts two options which should be given as non-negative integers:
##  <C>timeout</C> which specifies in minutes how long the client must wait for
##  the result (if not given, the default value is one hour) and
##  <C>recallfrequency</C> which specifies the number of iterations after which
##  the search for new services will be performed (if not given the default
##  value is zero meaning no such search at all). There is also a boolean
##  option <C>noretry</C> which, if set to <K>true</K>, means that no retrying
##  calls will be performed if the timeout is exceeded and an incomplete resut
##  may be returned.
##  <Example>
##  <![CDATA[
##  gap> ParListWithSCSCP( List( [2..6], n -> SymmetricGroup(n)), "WS_IdGroup" );
##  #I  master -> [ "localhost", 26133 ] : SymmetricGroup( [ 1 .. 2 ] )
##  #I  master -> [ "localhost", 26134 ] : SymmetricGroup( [ 1 .. 3 ] )
##  #I  [ "localhost", 26133 ] --> master : [ 2, 1 ]
##  #I  master -> [ "localhost", 26133 ] : SymmetricGroup( [ 1 .. 4 ] )
##  #I  [ "localhost", 26134 ] --> master : [ 6, 1 ]
##  #I  master -> [ "localhost", 26134 ] : SymmetricGroup( [ 1 .. 5 ] )
##  #I  [ "localhost", 26133 ] --> master : [ 24, 12 ]
##  #I  master -> [ "localhost", 26133 ] : SymmetricGroup( [ 1 .. 6 ] )
##  #I  [ "localhost", 26133 ] --> master : [ 720, 763 ]
##  #I  [ "localhost", 26134 ] --> master : [ 120, 34 ]
##  [ [ 2, 1 ], [ 6, 1 ], [ 24, 12 ], [ 120, 34 ], [ 720, 763 ] ]
##  ]]>
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ParListWithSCSCP" );


###########################################################################
#
# Special procedures
#

###########################################################################
##
#F  GetAllowedHeads
##
##  <#GAPDoc Label="GetAllowedHeads">
##  
##  <ManSection>
##  <Func Name="GetAllowedHeads" Arg="server port" />
##  <Returns>
##    record
##  </Returns>	 
##  <Description>
##  Returns the record with components corresponding to content dictionaries.
##  The name of each component is the name of the content dictionary, and its
##  the value is either a boolean or a list of strings. In case it's value is
##  a list, it contains names of symbols from the corresponding content
##  dictionary which are allowed to appear as a <Q>head</Q> symbol (i.e. the
##  first child of the outermost <C>&lt;OMA></C>) in an &SCSCP; procedure call
##  to the &SCSCP; server running at <A>server</A><C>:</C><A>port</A>. If it's
##  value is <K>true</K>, it means the server allows all symbols from the
##  corresponding content dictionary.
##  <P/>
##  Note that it is acceptable (although not quite desirable) 
##  for a server to <Q>overstate</Q> the set of symbols it accepts 
##  and use standard &OpenMath; errors to reject requests later.   
##  <Example>
##  <![CDATA[
##  gap> GetAllowedHeads("localhost",26133);
##  rec( scscp_transient_1 := [ "AClosestVectorCombinationsMatFFEVecFFE", 
##        "Determinant", "GroupIdentificationService", 
##        "IO_UnpickleStringAndPickleItBack", "IdGroup512ByCode", "Identity", 
##        "IsPrimeInt", "Length", "MathieuGroup", "MatrixGroup", 
##        "NormalizedUnitCFcommutator", "NormalizedUnitCFpower", 
##        "NrConjugacyClasses", "NrSmallGroups", "NumberCFGroups", 
##        "NumberCFSolvableGroups", "PointImages", "QuillenSeriesByIdGroup", 
##        "ResetMinimumDistanceService", "SCSCPStartTracing", "SCSCPStopTracing", 
##        "Size", "SylowSubgroup", "WS_AlternatingGroup", "WS_AutomorphismGroup", 
##        "WS_ConwayPolynomial", "WS_Factorial", "WS_FactorsCFRAC", 
##        "WS_FactorsECM", "WS_FactorsMPQS", "WS_FactorsPminus1", 
##        "WS_FactorsPplus1", "WS_FactorsTD", "WS_IdGroup", "WS_LatticeSubgroups",
##        "WS_Mult", "WS_MultMatrix", "WS_Phi", "WS_PrimitiveGroup", 
##        "WS_SmallGroup", "WS_SymmetricGroup", "WS_TransitiveGroup", "addition" 
##       ] )
##  ]]>
##  </Example>    
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "GetAllowedHeads" );

###########################################################################
##
#F  GetServiceDescription
##
##  <#GAPDoc Label="GetServiceDescription">
##  
##  <ManSection>
##  <Func Name="GetServiceDescription" Arg="server port"/>
##  <Returns>
##    record 
##  </Returns>	 
##  <Description>
##  Returns the record with three components containing strings with the
##  name, version and description of the service as specified by the 
##  service provider in the <File>scscp/config.g</File> (for details
##  about configuration files, see <Ref Label="Config" />).
##  <Example>
##  <![CDATA[
##  gap> GetServiceDescription( "localhost", 26133 );
##  rec( 
##    description := "Started with the configuration file scscp/example/myserver.g\
##    on Thu 16 Feb 2017 16:03:56 GMT", service_name := "GAP SCSCP service", 
##    version := "GAP 4.8.6 + SCSCP 2.2.1" )
##  ]]>
##  </Example>    
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "GetServiceDescription" );


###########################################################################
##
#F  GetSignature
##
##  <#GAPDoc Label="GetSignature">
##  
##  <ManSection>
##  <Func Name="GetSignature" Arg="transientcd symbol server port" />
##  <Returns>
##    record
##  </Returns>	 
##  <Description>
##  Returns a record with the signature of the &OpenMath; symbol
##  <A>transientcd</A><C>.</C><A>symbol</A> from a transient &OpenMath;
##  content dictionary. This record contains components corresponding to
##  the &OpenMath; symbol whose signature is described, the minimal and
##  maximal number of its children (that is, of its arguments), and symbols
##  which may be used in the &OpenMath; encoding of its children. Note that
##  it is acceptable for a symbol from a transient content dictionary to
##  overstate the set of symbols which may occur in its children using the
##  <C>scscp2.symbol_set_all</C> symbol, and use standard &OpenMath; errors
##  to reject requests later, like in the example below: using such
##  approach, the procedure <C>WS_Factorial</C> is defined to accept not
##  only immediate <C>&lt;OMI></C> objects but anything which could be
##  evaluated to an integer.
##  <Example>
##  <![CDATA[
##  gap> GetSignature("scscp_transient_1","WS_Factorial","localhost",26133);
##  rec( maxarg := 1, minarg := 1,
##    symbol := rec( cd := "scscp_transient_1", name := "WS_Factorial" ),
##    symbolargs := rec( cd := "scscp2", name := "symbol_set_all" ) )
##  ]]>
##  </Example>    
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "GetSignature" );


###########################################################################
##
#F  GetTransientCD
##
##  <#GAPDoc Label="GetTransientCD">
##  
##  <ManSection>
##  <Func Name="GetTransientCD" Arg="transient_cd server port" />
##  <Returns>
##    record
##  </Returns>	 
##  <Description>
##  Returns a record with the transient content dictionary
##  <A>transient_cd</A> from the &SCSCP; server running at
##  <A>server</A><C>:</C><A>port</A>. Names of components of this record
##  correspond to symbols from the <C>meta</C> content dictionary.
##  <P/>
##  By default, the name of the transient content dictionary 
##  for the &GAP; &SCSCP; server is <C>scscp_transient_1</C>.
##  Other systems may use transient content dictionaries with
##  another names, which, however, must always begin with
##  <C>scscp_transient_</C> and may be guessed from the output
##  of <Ref Func="GetAllowedHeads"/>.
##  <Example>
##  <![CDATA[
##  gap> GetTransientCD( "scscp_transient_1", "localhost", 26133 );
##  rec( CDDate := "2017-02-08", 
##    CDDefinitions := 
##      [ rec( Description := "Size is currently undocumented.", Name := "Size" ),
##        rec( Description := "Length is currently undocumented.", 
##            Name := "Length" ), 
##        rec( Description := "NrConjugacyClasses is currently undocumented.", 
##            Name := "NrConjugacyClasses" ), 
##  ...
##        rec( Description := "MatrixGroup is currently undocumented.", 
##            Name := "MatrixGroup" ) ], CDName := "scscp_transient_1", 
##    CDReviewDate := "2017-02-08", CDRevision := "0", CDStatus := "private", 
##    CDVersion := "0", 
##    Description := "This is a transient CD for the GAP SCSCP service" )
##  ]]>
##  </Example>    
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "GetTransientCD" );


###########################################################################
##
#F  IsAllowedHead
##
##  <#GAPDoc Label="IsAllowedHead">
##  
##  <ManSection>
##  <Func Name="IsAllowedHead" Arg="cd symbol server port"/>
##  <Returns>
##    <K>true</K> or <K>false</K>
##  </Returns>	 
##  <Description>
##  Checks whether the &OpenMath; symbol <A>cd</A><C>.</C><A>symbol</A>,
##  which may be a symbol from a standard or transient &OpenMath; content
##  dictionary, is allowed to appear as <Q>head</Q> symbol (i.e. the first 
##  child of the outermost <C>&lt;OMA></C> in an &SCSCP; procedure call to
##  the &SCSCP; server running at  <A>server</A><C>:</C><A>port</A>. 
##  This enables the client to check whether a particular 
##  symbol is allowed without requesting the full list of symbols.
##  <P/>
##  Also, it is acceptable (although not necessarily desirable) for a 
##  server to <Q>overstate</Q> the set of symbols it accepts and use standard 
##  &OpenMath; errors to reject requests later.
##  <Example>
##  <![CDATA[
##  gap> IsAllowedHead( "permgp1", "group", "localhost", 26133 );
##  true
##  gap> IsAllowedHead( "setname1", "Q", "localhost", 26133 );
##  true
##  gap> IsAllowedHead( "setname1", "R", "localhost", 26133 );
##  false
##  ]]>
##  </Example>  
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IsAllowedHead" );


###########################################################################
##
#E 
##
