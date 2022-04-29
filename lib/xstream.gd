###########################################################################
##
#W xstream.gd               The SCSCP package            Olexandr Konovalov
#W                                                             Steve Linton
##
###########################################################################


###########################################################################
##
#C  IsInputOutputTCPStream ........... category of input/output TCP streams
##
##  <#GAPDoc Label="IsInputOutputTCPStream">
##  <ManSection>
##  <Filt Name="IsInputOutputTCPStream" />   
##  <Description>
##  <Ref Filt="IsInputOutputTCPStream"/> is a subcategory of
##  <Ref BookName="ref" Filt="IsInputOutputStream"/>. 
##  Streams in the category <Ref Filt="IsInputOutputTCPStream"/> 
##  are created with the help of the function
##  <Ref Func="InputOutputTCPStream" Label="for client" /> with
##  one or two arguments dependently on whether they will be
##  used in the client or server mode. Examples of their creation
##  and usage will be given in subsequent sections.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsInputOutputTCPStream", IsInputOutputStream );


###########################################################################
##
#R  IsInputOutputTCPStreamRep .. representation of input/output TCP streams
##
##  <#GAPDoc Label="IsInputOutputTCPStreamRep">
##  
##  <ManSection>
##  <Filt Name="IsInputOutputTCPStreamRep" />
##  <Description>
##  This is the representation used for streams in the  
##  category <Ref Filt="IsInputOutputTCPStream"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareRepresentation( "IsInputOutputTCPStreamRep", 
                       IsPositionalObjectRep, [ ] );

InputOutputTCPStreamDefaultType :=
  NewType( StreamsFamily, 
           IsInputOutputTCPStreamRep and IsInputOutputTCPStream);

           
###########################################################################
##
#F  InputOutputTCPStream ............... returns an input/output TCP stream
##
##  <#GAPDoc Label="InputOutputTCPStream">
##  
##  <ManSection>
##  <Func Name="InputOutputTCPStream" Label="for server" Arg="desc" />      
##  <Func Name="InputOutputTCPStream" Label="for client" Arg="host port" />          
##  <Returns>
##     stream   
##  </Returns>	 
##  <Description>
##  The one-argument version must be called from the &SCSCP; server.
##  Its argument <A>desc</A> must be a socket descriptor obtained using
##  <Ref BookName="IO" Func="IO_accept"/> function from the &IO; package
##  (see the example below). It returns a stream in the category 
##  <Ref Filt="IsInputOutputTCPStream"/> which will use this socket to 
##  accept incoming connections. 
##  In most cases, the one-argument version is called automatically 
##  from <Ref Func="RunSCSCPserver"/> rather then manually.    
##  <P/>   
##  The version with two arguments, a string <A>host</A> and an integer
##  <A>port</A>, must be called from the &SCSCP; client. It returns a stream 
##  in the category <Ref Filt="IsInputOutputTCPStream"/> which will be used 
##  by the client for communication with the &SCSCP; server running at 
##  hostname <A>host</A> on port <A>port</A>. 
##  In most cases, the two-argument version is called automatically from
##  the higher level functions, for example, <Ref Func="EvaluateBySCSCP"/>.
##  </Description>
##  </ManSection>           
##  <#/GAPDoc>
##
DeclareGlobalFunction ( "InputOutputTCPStream" );


###########################################################################
##
#F  SCSCPwait
##
##  <#GAPDoc Label="SCSCPwait">
##  
##  <ManSection>
##  <Func Name="SCSCPwait" Arg="stream [timeout]"/>
##  <Returns>
##    nothing
##  </Returns>	 
##  <Description>
##  This function may be used by the &SCSCP; client to wait
##  (using <Ref BookName="IO" Func="IO_select" />)
##  until the result of the procedure call will be 
##  available from <A>stream</A>. By default the timeout is
##  one hour, to specify another value give it as the optional
##  second argument in seconds. See the end of this chapter 
##  for the example.
##  </Description>
##  </ManSection>           
##  <#/GAPDoc>
##
DeclareGlobalFunction ( "SCSCPwait" );


###########################################################################
##
#E 
##
