#############################################################################
##
#W remote.gd                The SCSCP package             Alexander Konovalov
#W                                                               Steve Linton
##
#H $Id$
##
#############################################################################

DeclareCategory( "IsRemoteObject", IsObject );

RemoteObjectsFamily := NewFamily( "RemoteObjectsFamily" );

DeclareGlobalFunction ( "RemoteObject" );