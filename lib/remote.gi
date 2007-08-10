#############################################################################
##
#W remote.gi                The SCSCP package             Alexander Konovalov
#W                                                               Steve Linton
##
#H $Id$
##
#############################################################################


DeclareRepresentation( "IsRemoteObjectRep", 
                       IsPositionalObjectRep,
                       [ ] );


RemoteObjectDefaultType :=
  NewType( RemoteObjectsFamily, 
           IsRemoteObjectRep and IsRemoteObject);

 
#############################################################################
##
##  RemoteObject( <identifier>, <hostname>, <port> )
##
##  RemoteObject should contain all information that is necessary 
##  to retrieve it from the remote system
##        
InstallGlobalFunction( RemoteObject,
function( identifier, hostname, port )
if IsString(identifier) and IsString(hostname) and IsPosInt(port) then
return Objectify( RemoteObjectDefaultType,
                    [ identifier, hostname, port ] ); 
else
  Error( "RemoteObject( <identifier>, <hostname>, <port> ) : \n",
         "1st and 2nd argument must be strings, and 3rd a positive integer \n" );
fi;                    
end);


# TO-DO: 
# equality for remote objects
# StoreRemoteObject
# RetrieveRemoteObject
# Unbind for remote objects


#############################################################################
##
#M  ViewObj( <RemoteObject> )
##
InstallMethod( ViewObj, "for RemoteObject",
[ IsRemoteObjectRep and IsRemoteObject ],
function( obj )
    Print("< remote object ", obj![1], " at ", obj![2], ":", obj![3], " >");
end);


#############################################################################
##
#M  PrintObj( <RemoteObject> )
##
InstallMethod( PrintObj, "for RemoteObject",
[ IsRemoteObjectRep and IsRemoteObject ],
function( obj )
    Print("RemoteObject(\"", obj![1], "\",\"", obj![2], "\",", obj![3], ")" );
end);


#############################################################################
##
#M  OMPut( <RemoteObject> )
##
InstallMethod( OMPut, "for stream and RemoteObject",
[ IsOutputStream, IsRemoteObjectRep and IsRemoteObject ],
function ( stream, x )
    OMWriteLine( stream, [ "<OMR xref=\"", x![1], "\" />" ] );
return;
end);