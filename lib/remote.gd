#############################################################################
##
#W remote.gd                The SCSCP package              Olexandr Konovalov
#W                                                               Steve Linton
##
#############################################################################


#############################################################################
##
#C  IsRemoteObject
##
##  <#GAPDoc Label="IsRemoteObject">
##  
##  <ManSection>
##  <Filt Name="IsRemoteObject" />
##  <Description>
##  This is the category of remote objects.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsRemoteObject", IsObject );


#############################################################################
##
##  RemoteObjectsFamily
##
##  <#GAPDoc Label="RemoteObjectsFamily">
##  
##  <ManSection>
##  <Fam Name="RemoteObjectsFamily" />
##  <Description>
##  This is the family of remote objects.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
RemoteObjectsFamily := NewFamily( "RemoteObjectsFamily" );


#############################################################################
##
#F RemoteObject( <identifier>, <hostname>, <port> )
##
DeclareGlobalFunction ( "RemoteObject" );


#############################################################################
##
#O StoreAsRemoteObjectPerSession( <Object> )
##
DeclareOperation( "StoreAsRemoteObjectPerSession", [ IsObject, IsString, IsPosInt ] );


#############################################################################
##
#O  StoreAsRemoteObjectPersistently( <Object> )
#O  StoreAsRemoteObject( <Object> )
##
##  <#GAPDoc Label="StoreAsRemoteObject">
##  
##  <ManSection>
##  <Func Name="StoreAsRemoteObjectPersistently" Arg="obj server port"/>
##  <Func Name="StoreAsRemoteObject" Arg="obj server port"/>
##  <Returns>
##    remote object
##  </Returns>	 
##  <Description>
##  Returns the remote object corresponding to the object created at
##  <A>server</A><C>:</C><A>port</A> from the &OpenMath; representation
##  of the first argument <A>obj</A>. The second form is just a synonym.
##  <Example>
##  <![CDATA[
##  gap> s:=StoreAsRemoteObject( SymmetricGroup(3), "localhost", 26133 );
##  < remote object scscp://localhost:26133/TEMPVarSCSCPLvIUUtL3 >
##  ]]>
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "StoreAsRemoteObjectPersistently", [ IsObject, IsString, IsPosInt ] );
DeclareSynonym( "StoreAsRemoteObject", StoreAsRemoteObjectPersistently );


#############################################################################
##
#O  RetrieveRemoteObject( <RemoteObject> )
##
##  <#GAPDoc Label="RetrieveRemoteObject">
##  
##  <ManSection>
##  <Func Name="RetrieveRemoteObject" Arg="remoteobject"/>
##  <Returns>
##    object
##  </Returns>	 
##  <Description>
##  This function retrieves the remote object from the remote service
##  in the &OpenMath; format and constructs it locally. Note, however,
##  that for a complex mathematical object its default &OpenMath; 
##  representation may not contain all information about it which was 
##  accumulated during its lifetime on the &SCSCP; server.
##  <Example>
##  <![CDATA[
##  gap> RetrieveRemoteObject(s);
##  Group([ (1,2,3), (1,2) ])
##  ]]>
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "RetrieveRemoteObject", [ IsRemoteObject ] );


#############################################################################
##
#O  UnbindRemoteObject( <RemoteObject> )
##
##  <#GAPDoc Label="UnbindRemoteObject">
##  
##  <ManSection>
##  <Func Name="UnbindRemoteObject" Arg="remoteobject"/>
##  <Returns>
##    <K>true</K> or <K>false</K>
##  </Returns>	 
##  <Description>
##  Removes any value currently bound to the global variable 
##  determined by <A>remoteobject</A> at the &SCSCP; server, 
##  and returns <K>true</K> or <K>false</K> dependently on 
##  whether this action was successful or not. 
##  <Example>
##  <![CDATA[
##  gap> UnbindRemoteObject(s);
##  true
##  ]]>
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "UnbindRemoteObject", [ IsRemoteObject ] );


###########################################################################
##
#E 
##