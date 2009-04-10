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
local pos;
if IsString(identifier) and IsString(hostname) and IsPosInt(port) then
pos := Position( identifier, '@');
if pos <> fail then
  identifier := identifier{[1..pos-1]};
fi;  
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
    Print("< remote object ", obj![1], "@", obj![2], ":", obj![3], " >");
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
    OMWriteLine( stream, [ "<OMR xref=\"", x![1], "@", x![2], ":", x![3], "\" />" ] );
return;
end);


#############################################################################
##
## StoreAsRemoteObjectPerSession( <Object>, <server>, <port> )
##
InstallMethod( StoreAsRemoteObjectPerSession, "for an object",
[ IsObject, IsString, IsPosInt ],
function( obj, server, port )
# TODO: store must return automatically remote object even if called without return_cookie
# In general, conflicts between procedures and options should be checked and eliminated
return EvaluateBySCSCP( "store_session", [ obj ], server, port : return_cookie).object;
end);


#############################################################################
##
## StoreAsRemoteObjectPersistently( <Object>, <server>, <port> )
##
InstallMethod( StoreAsRemoteObjectPersistently, "for an object",
[ IsObject, IsString, IsPosInt ],
function( obj, server, port )
return EvaluateBySCSCP( "store_persistent", [ obj ], server, port : return_cookie).object;
end);


#############################################################################
##
## RetrieveRemoteObject( <RemoteObject> )
##
InstallMethod( RetrieveRemoteObject, "for remote object",
[ IsRemoteObject ],
function( obj )
return EvaluateBySCSCP( "retrieve", [ obj![1] ], obj![2], obj![3]).object;
end);


#############################################################################
##
## UnbindRemoteObject( <RemoteObject> )
##
InstallMethod( UnbindRemoteObject, "for remote object",
[ IsRemoteObject ],
function( obj )
return EvaluateBySCSCP( "unbind", [ obj![1] ], obj![2], obj![3]).object;
end);