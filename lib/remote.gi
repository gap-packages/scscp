#############################################################################
##
#W remote.gi                The SCSCP package              Olexandr Konovalov
#W                                                               Steve Linton
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
InstallGlobalFunction( RemoteObject, function( identifier, hostname, port )
local pos;
if IsString(identifier) and IsString(hostname) and IsPosInt(port) then
pos := PositionNthOccurrence( identifier, '/', 3);
if pos <> fail then
  identifier := identifier{[pos+1..Length(identifier)]};
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
    Print("< remote object scscp://", obj![2], ":", obj![3], "/", obj![1], " >");
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
InstallMethod( OMPut, "for OpenMath XML writer and RemoteObject",
[ IsOpenMathXMLWriter, IsRemoteObjectRep and IsRemoteObject ],
function ( writer, x )
       OMWriteLine( writer![1], [ "<OMR href=\"scscp://", x![2], ":", x![3], "/", x![1], "\" />" ] );
# Writing references in the form   <OMR href= "scscp://   server  :   port    /   name     " />
return;
end);


#############################################################################
##
#M  OMPut( <RemoteObject> )
##
InstallMethod( OMPut, "for OpenMath binary writer and RemoteObject",
[ IsOpenMathBinaryWriter, IsRemoteObjectRep and IsRemoteObject ],
function ( writer, x )
local refStri, refLength, lengthList;
# Error("IN!!!\n");
#      OMWriteLine( writer![1], [ "<OMR href=\"scscp://", x![2], ":", x![3], "/", x![1], "\" />" ] );
# Writing references in the form   <OMR href= "scscp://   server  :   port    /   name     " />
   refStri := Concatenation( "scscp://", x![2], ":", String(x![3]), "/", x![1] );
   refLength := Length(refStri); 
   if refLength > 255 then
   	WriteByte (writer![1], 159); #31+128
   	lengthList := BigIntToListofInts(refLength);
	WriteIntasBytes(writer![1], lengthList);
   else 
   	WriteByte (writer![1], 31);
   	WriteByte (writer![1], refLength);
   fi;
   WriteAll(writer![1], refStri);
return;
end);


#############################################################################
##
## StoreAsRemoteObjectPerSession( <Object>, <server>, <port> )
##
InstallMethod( StoreAsRemoteObjectPerSession, "for an object",
[ IsObject, IsString, IsPosInt ],
function( obj, server, port )
return EvaluateBySCSCP( "store_session", [ obj ], server, port : output := "cookie" ).object;
end);


#############################################################################
##
## StoreAsRemoteObjectPersistently( <Object>, <server>, <port> )
##
InstallMethod( StoreAsRemoteObjectPersistently, "for an object",
[ IsObject, IsString, IsPosInt ],
function( obj, server, port )
return EvaluateBySCSCP( "store_persistent", [ obj ], server, port : output:="cookie").object;
end);


#############################################################################
##
## RetrieveRemoteObject( <RemoteObject> )
##
InstallMethod( RetrieveRemoteObject, "for remote object",
[ IsRemoteObject ],
function( obj )
return EvaluateBySCSCP( "retrieve", [ obj ], obj![2], obj![3] : output:="object" ).object;
end);


#############################################################################
##
## UnbindRemoteObject( <RemoteObject> )
##
InstallMethod( UnbindRemoteObject, "for remote object",
[ IsRemoteObject ],
function( obj )
local r;
if IsBound( obj![4]) and obj![4]=false then
	Error("Remote object is already unbound");
else
	r := EvaluateBySCSCP( "unbind", [ obj ], obj![2], obj![3] : output:="object"  ).object;
	if r=true then
		obj![4]:=false;
	fi;
	return true;
fi;	
end);


###########################################################################
##
#E 
##