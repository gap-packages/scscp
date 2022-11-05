#############################################################################
##
#W openmath.gd              The SCSCP package              Olexandr Konovalov
#W                                                               Steve Linton
##
#############################################################################


###########################################################################
##
##  OMGetObjectWithAttributes
##
##  <#GAPDoc Label="OMGetObjectWithAttributes">
##  
##  <ManSection>
##  <Func Name="OMGetObjectWithAttributes" Arg="stream" />
##  <Returns>
##  record with components <C>object</C> and <C>attributes</C>, or <K>fail</K>
##  </Returns>	 
##  <Description>
##  <!-- TODO: Document option return_tree -->
##  This function is similar to the function <C>OMGetObject</C> from the
##  &OpenMath; package, and the main difference is that it is able to
##  understand &OpenMath; attribution pairs. It retrieves exactly one
##  &OpenMath; object from the stream <A>stream</A>, and stores it in the
##  <C>object</C> component of the returned record. If the &OpenMath; object
##  has no attributes, the <C>attributes</C> component of the returned record
##  will be an empty list, otherwise it will contain pairs
##  <C>[attribute&uscore;name,attribute&uscore;value]</C>, where
##  <C>attribute&uscore;name</C> is a string, and <C>attribute&uscore;value</C>
##  is a &GAP; object, whose type is determined by the kind of an attribute.
##  Only attributes, defined by the SCSCP are allowed, otherwise an error
##  message will be displayed. <P/> If the procedure was not successful, the
##  function returns <K>fail</K> instead of an error message like the function
##  <Ref BookName="OpenMath" Func="OMGetObject" /> does. Returning <K>fail</K>
##  is useful when <C>OMGetObjectWithAttributes</C> is used inside
##  accept-evaluate-return loop.
##  <P/>
##  As an example, the file <File>scscp/tst/omdemo.om</File> contains some 
##  &OpenMath; objects, including those from the SCSCP Specification 
##  <Cite Key="SCSCP"/>. We can retrieve them from this file,
##  preliminary installing some SCSCP procedures
##  using the function <Ref Func="InstallSCSCPprocedure"/>:
##  <Example>
##  <![CDATA[
##  gap> InstallSCSCPprocedure("WS_Factorial", Factorial );
##  gap> InstallSCSCPprocedure("GroupIdentificationService", IdGroup );
##  gap> InstallSCSCPprocedure("GroupByIdNumber", SmallGroup );
##  gap> InstallSCSCPprocedure( "Length", Length, 1, 1 );
##  gap> test:=Filename( Directory( Concatenation(
##  >         GAPInfo.PackagesInfo.("scscp")[1].InstallationPath,"/tst/" ) ), 
##  >         "omdemo.om" );;
##  gap> stream:=InputTextFile(test);;
##  gap> OMGetObjectWithAttributes(stream); 
##  rec( 
##    attributes := [ [ "option_return_object", "" ], [ "call_id", "5rc6rtG62" ] ]
##      , object := 6 )
##  gap> OMGetObjectWithAttributes(stream);
##  rec( attributes := [  ], object := 1 )
##  gap> OMGetObjectWithAttributes(stream);
##  rec( attributes := [  ], object := 120 )
##  gap> OMGetObjectWithAttributes(stream);
##  rec( 
##    attributes := [ [ "call_id", "alexk_9053" ], [ "option_runtime", 300000 ], 
##        [ "option_min_memory", 40964 ], [ "option_max_memory", 134217728 ], 
##        [ "option_debuglevel", 2 ], [ "option_return_object", "" ] ], 
##    object := [ 24, 12 ] )
##  gap> OMGetObjectWithAttributes(stream);
##  rec( 
##    attributes := [ [ "call_id", "alexk_9053" ], [ "option_return_cookie", "" ] 
##       ], object := <pc group of size 24 with 4 generators> )
##  gap> OMGetObjectWithAttributes(stream);
##  rec( attributes := [ [ "call_id", "alexk_9053" ], [ "info_runtime", 1234 ], 
##        [ "info_memory", 134217728 ] ], object := [ 24, 12 ] )
##  gap> CloseStream( stream );
##  ]]>
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "OMGetObjectWithAttributes" );

DeclareGlobalFunction( "OMgetObjectXMLTreeWithAttributes" );


###########################################################################
##
##  OMPutProcedureCall( <stream>, <proc_name>, <objrec> )
##
##  <#GAPDoc Label="OMPutProcedureCall">
##  
##  <ManSection>
##  <Func Name="OMPutProcedureCall" Arg="stream proc_name objrec" />
##  <Returns>
##    nothing
##  </Returns>	 
##  <Description>
##  Takes a stream <A>stream</A>, the string <A>proc&uscore;name</A> and a
##  record <A>objrec</A>, and writes to <A>stream</A> an &OpenMath; object
##  <C>procedure&uscore;call</C> for the procedure <A>proc&uscore;name</A> with
##  arguments given by the list <C>objrec.object</C> and procedure call options
##  (which should be encoded as &OpenMath; attributes) given in the list
##  <C>objrec.attributes</C>. 
##  <P/>
##  This function accepts options <C>cd</C> and <C>debuglevel</C>.
##  <P/>
##  <C>cd:="cdname"</C> may be used to specify the name of the content 
##  dictionary if the procedure is actually a standard &OpenMath; symbol.
##  Note that the server may reject such a call if it accepts only calls 
##  of procedures from the transient content dictionary, see 
##  <Ref Func="InstallSCSCPprocedure"/> for explanation). If the <C>cdname</C> 
##  is not specified, <C>scscp_transient_1</C> content dictionary will be 
##  assumed by default.
##  The value of the <C>debuglevel</C> option is an integer. If it is non-zero,
##  the <C>procedure&uscore;completed</C> message will carry on also some
##  additional information about the call, for example, runtime and memory 
##  used.
##  <!-- TODO: document debuglevel option in more details -->
##  <Example>
##  <![CDATA[
##  gap> t:="";; stream:=OutputTextString(t,true);;
##  gap> OMPutProcedureCall( stream, "WS_Factorial", rec( object:= [ 5 ], 
##  >      attributes:=[ [ "call_id", "user007" ], 
##  >                    ["option_runtime",1000],
##  >                    ["option_min_memory",1024], 
##  >                    ["option_max_memory",2048],
##  >                    ["option_debuglevel",1], 
##  >                    ["option_return_object"] ] ) );;
##  gap> Print(t);
##  <?scscp start ?>
##  <OMOBJ xmlns="http://www.openmath.org/OpenMath" version="2.0">
##  	<OMATTR>
##  		<OMATP>
##  			<OMS cd="scscp1" name="call_id"/>
##  			<OMSTR>user007</OMSTR>
##  			<OMS cd="scscp1" name="option_runtime"/>
##  			<OMI>1000</OMI>
##  			<OMS cd="scscp1" name="option_min_memory"/>
##  			<OMI>1024</OMI>
##  			<OMS cd="scscp1" name="option_max_memory"/>
##  			<OMI>2048</OMI>
##  			<OMS cd="scscp1" name="option_debuglevel"/>
##  			<OMI>1</OMI>
##  			<OMS cd="scscp1" name="option_return_object"/>
##  			<OMSTR></OMSTR>
##  		</OMATP>
##  		<OMA>
##  			<OMS cd="scscp1" name="procedure_call"/>
##  			<OMA>
##  				<OMS cd="scscp_transient_1" name="WS_Factorial"/>
##  				<OMI>5</OMI>
##  			</OMA>
##  		</OMA>
##  	</OMATTR>
##  </OMOBJ>
##  <?scscp end ?>
##  ]]>
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "OMPutProcedureCall" );


###########################################################################
##
##  OMPutProcedureCompleted
##
##  <#GAPDoc Label="OMPutProcedureCompleted">
##  
##  <ManSection>
##  <Func Name="OMPutProcedureCompleted" Arg="stream objrec"/>
##  <Returns>
##    <K>true</K>
##  </Returns>	 
##  <Description>
##  Takes a stream <A>stream</A>, and a record 
##  <A>objrec</A>, and writes to <A>stream</A> an &OpenMath; object 
##  <C>procedure&uscore;completed</C> 
##  with the result being <C>objrec.object</C> and information messages
##  (as &OpenMath; attributes) given in the list <C>objrec.attributes</C>.
##  <Example>
##  <![CDATA[
##  gap> t:="";; stream:=OutputTextString(t,true);;
##  gap> OMPutProcedureCompleted( stream, 
##  >      rec(object:=120, 
##  >      attributes:=[ [ "call_id", "user007" ] ] ) );
##  true
##  gap> Print(t);
##  <?scscp start ?>
##  <OMOBJ xmlns="http://www.openmath.org/OpenMath" version="2.0">
##  	<OMATTR>
##  		<OMATP>
##  			<OMS cd="scscp1" name="call_id"/>
##  			<OMSTR>user007</OMSTR>
##  		</OMATP>
##  		<OMA>
##  			<OMS cd="scscp1" name="procedure_completed"/>
##  			<OMI>120</OMI>
##  		</OMA>
##  	</OMATTR>
##  </OMOBJ>
##  <?scscp end ?>
##  ]]>
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "OMPutProcedureCompleted" );


###########################################################################
##
##  OMPutProcedureTerminated
##
##  <#GAPDoc Label="OMPutProcedureTerminated">
##  
##  <ManSection>
##  <Func Name="OMPutProcedureTerminated" Arg="stream objrec error_cd error_type"/>
##  <Returns>
##    nothing
##  </Returns>	 
##  <Description>
##  Takes a stream <A>stream</A>, and a record with an error message
##  <A>objrec</A> (for example <C>rec( attributes := [ [ "call_id",
##  "localhost:26133:87643:gcX33cCf" ] ],</C> <C>object := "localhost:26133
##  reports : Rational operations: &lt;divisor> must not be zero")</C> and
##  writes to the <A>stream</A> an &OpenMath; object
##  <C>procedure&uscore;terminated</C> containing an error determined by the
##  symbol <A>error_type</A> from the content dictionary <A>error_cd</A> (for
##  example, <C>error_memory</C>, <C>error_runtime</C> or
##  <C>error_system_specific</C> from the &scscp1; content dictionary (<Cite
##  Key="scscp1cd"/>). <P/> This is the internal function of the package which
##  is used only in the code for the &SCSCP; server to return the error message
##  to the client.   
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "OMPutProcedureTerminated" );


###########################################################################
##
#E 
##