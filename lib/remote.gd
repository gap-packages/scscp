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
#O StoreAsRemoteObject( <Object> )
##
DeclareOperation( "StoreAsRemoteObject", [ IsObject, IsString, IsPosInt ] );


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