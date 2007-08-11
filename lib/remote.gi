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


#############################################################################
##
#M  \=( <x>, <y> )  . .  . . . . . . . . . . . . . . . for two remote objects
##
## We decide that two remote objects are equal if they have the same
## internal representation (variable name, server and port).
##
InstallMethod( \=,
    "for two remote objects",
    IsIdenticalObj,
    [ IsRemoteObjectRep and IsRemoteObject, IsRemoteObjectRep and IsRemoteObject ],
    function( a, b )
    return a![1] = b![1] and a![2] = b![2] and a![3] = b![3];
    end );


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


#############################################################################
##
## StoreAsRemoteObject( <Object>, <server>, <port> )
##
InstallMethod( StoreAsRemoteObject, "for an object",
[ IsObject, IsString, IsPosInt ],
function( obj, server, port )
return EvaluateBySCSCP( "SCSCP_STORE", [ obj ], server, port : return_cookie).object;
end);


#############################################################################
##
## RetrieveRemoteObject( <RemoteObject> )
##
InstallMethod( RetrieveRemoteObject, "for remote object",
[ IsRemoteObject ],
function( obj )
return EvaluateBySCSCP( "SCSCP_RETRIEVE", [ obj![1] ], obj![2], obj![3]).object;
end);


#############################################################################
##
## UnbindRemoteObject( <RemoteObject> )
##
InstallMethod( UnbindRemoteObject, "for remote object",
[ IsRemoteObject ],
function( obj )
return EvaluateBySCSCP( "SCSCP_UNBIND", [ obj![1] ], obj![2], obj![3]).object;
end);