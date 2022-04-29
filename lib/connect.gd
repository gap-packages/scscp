#############################################################################
##
#W process.gd               The SCSCP package              Olexandr Konovalov
#W                                                               Steve Linton
##
#############################################################################


###########################################################################
##
#C  IsSCSCPconnection
##
##  <#GAPDoc Label="IsSCSCPconnection">
##  
##  <ManSection>
##  <Filt Name="IsSCSCPconnection" />
##  <Description>
##  This is the category of &SCSCP; connections.
##  Objects in this category are created 
##  using the function <Ref Func="NewSCSCPconnection" />.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsSCSCPconnection", IsObject );
DeclareCategoryCollections( "IsSCSCPconnection" );


###########################################################################
##
#F  NewSCSCPconnection
##
##  <#GAPDoc Label="NewSCSCPconnection">
##  
##  <ManSection>
##  <Func Name="NewSCSCPconnection" Arg="hostname port"/>
##  <Description>
##  For a string <A>hostname</A> and an integer <A>port</A>,
##  creates an object in the category <Ref Filt="IsSCSCPconnection"/>.
##  This object will encapsulate two objects: <C>tcpstream</C>, 
##  which is the input/output TCP stream to
##  <C><A>hostname</A>:<A>port</A></C>, and <C>session_id</C>, which
##  is the result of calling <Ref Func="StartSCSCPsession"/> on
##  <C>tcpstream</C>. The connection will be kept alive across 
##  multiple remote procedure calls until it will be closed with
##  <Ref Func="CloseSCSCPconnection"/>.
##  <Example>
##  <![CDATA[
##  gap> SetInfoLevel( InfoSCSCP, 2 );
##  gap> s:=NewSCSCPconnection("localhost",26133);
##  #I  Creating a socket ...
##  #I  Connecting to a remote socket via TCP/IP ...
##  #I  Got connection initiation message
##  #I  <?scscp service_name="GAP" service_version="4.dev" service_id="localhost:2\
##  6133:52918" scscp_versions="1.0 1.1 1.2 1.3" ?>
##  #I  Requesting version 1.3 from the server ...
##  #I  Server confirmed version 1.3 to the client ...
##  < connection to localhost:26133 session_id=localhost:26133:52918 >
##  gap> CloseSCSCPconnection(s);
##  ]]>
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction ( "NewSCSCPconnection" );


###########################################################################
##
#F  CloseSCSCPconnection
##
##  <#GAPDoc Label="CloseSCSCPconnection">
##  
##  <ManSection>
##  <Func Name="CloseSCSCPconnection" Arg="s"/>
##  <Returns>
##    nothing
##  </Returns>
##  <Description>
##  Closes &SCSCP; connection <A>s</A>, which must be an object in the
##  category <Ref Filt="IsSCSCPconnection"/>. Internally, it just calls
##  <Ref BookName="ref" Oper="CloseStream"/> on the underlying 
##  input/output TCP stream of <A>s</A>.
##  <Example>
##  <![CDATA[
##  gap> SetInfoLevel( InfoSCSCP, 0 );
##  gap> s:=NewSCSCPconnection("localhost",26133);
##  < connection to localhost:26133 session_id=localhost:26133:52918 >
##  gap> CloseSCSCPconnection(s);
##  ]]>
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction ( "CloseSCSCPconnection" );


###########################################################################
##
#E 
##