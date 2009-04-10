#############################################################################
##
#W remote.gd                The SCSCP package             Alexander Konovalov
#W                                                               Steve Linton
##
#H $Id$
##
#############################################################################


#############################################################################
##
#C IsRemoteObject
##
DeclareCategory( "IsRemoteObject", IsObject );


#############################################################################
##
## RemoteObjectsFamily
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
#O StoreAsRemoteObject( <Object> )
##
DeclareOperation( "StoreAsRemoteObjectPerSession", [ IsObject, IsString, IsPosInt ] );
DeclareSynonym( "StoreAsRemoteObject", StoreAsRemoteObjectPerSession );


#############################################################################
##
#O StoreAsRemoteObjectPersistently( <Object> )
##
DeclareOperation( "StoreAsRemoteObjectPersistently", [ IsObject, IsString, IsPosInt ] );


#############################################################################
##
#O RetrieveRemoteObject( <RemoteObject> )
##
DeclareOperation( "RetrieveRemoteObject", [ IsRemoteObject ] );


#############################################################################
##
#O UnbindRemoteObject( <RemoteObject> )
##
DeclareOperation( "UnbindRemoteObject", [ IsRemoteObject ] );