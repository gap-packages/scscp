###########################################################################
##
#W xstream.gi               The SCSCP package              Olexandr Konovalov
#W                                                               Steve Linton
##
###########################################################################

           
###########################################################################
##
##  InputOutputTCPStream( <hostname>, <port> )
##  InputOutputTCPStream( <socket_descriptor> )
##
##  The first usage is to be used by client and specifies hostname and port.
##  The second usage is to be used by server and specifies socket descriptor
##  which will be used to accept incoming connections.
##        
InstallGlobalFunction( InputOutputTCPStream,
function( arg )
# InputOutputLocalProcess has 3 arguments: cdir, exec, argts
# at least for now, we want to preserve four components of the internal 
# representation of input/output streams, with the following correspondence
# 1) ptynum --> object in the category IsFile
# 2) basename --> hostname
# 3) argts --> ??? arguments to be communicated to the hostname?
# 4) false --> false # what'is the meaning of this?
local hostname, port, lookup, sock, res, fio, socket_descriptor, i;
if Length( arg ) = 2 then # client case
  hostname := arg[1];
  port := arg[2];
  if not IsString( hostname ) then
    Error( "InputOutputTCPStream: <hostname> must be a string! \n");  
  fi;
  if not ( IsInt(port) and port >= 0 ) then
    Error( "InputOutputTCPStream: <port> must be a non-negative integer! \n");  
  fi;
  # try to lookup the host for up to ten times
  for i in [1..10] do
    lookup := IO_gethostbyname( hostname );
    if lookup <> fail then
      break;
    fi;
  od;
  if lookup = fail then
    Print( "InputOutputTCPStream: cannot find hostname ", hostname, "\n");
    return fail;
  fi; 
  Info( InfoSCSCP, 1, "Creating a socket ..." );
  sock := IO_socket( IO.PF_INET, IO.SOCK_STREAM, "tcp" );
  Info( InfoSCSCP, 1, "Connecting to a remote socket via TCP/IP ..." );
  res := IO_connect( sock, IO_make_sockaddr_in( lookup.addr[1], port ) );  
  if res = fail then
    Print( "Error: ", LastSystemError(), "\n" );
    IO_close( sock );
    return fail;
  else
    fio := IO_WrapFD( sock, IO.DefaultBufSize, IO.DefaultBufSize );
    return Objectify( InputOutputTCPStreamDefaultType,
                      [ fio, hostname, [ port ], false ] );
  fi;
elif Length( arg ) = 1 then # server case
  socket_descriptor := arg[1];
  if not ( IsInt(socket_descriptor) and socket_descriptor >= 0 ) then
    Error( "InputOutputTCPStream: <socket_descriptor> must be a non-negative integer! \n");  
  fi;
  fio := IO_WrapFD( socket_descriptor, IO.DefaultBufSize, IO.DefaultBufSize );
  return Objectify( InputOutputTCPStreamDefaultType,
                    [ fio, "socket descriptor", [ socket_descriptor ], false ] );  
else
  Error( "InputOutputTCPStream: usage \n",
         "InputOutputTCPStream(<hostname>, <port>) for client, \n", 
         "InputOutputTCPStream(<socket_descriptor>) for server! \n"); 
fi;
end);


###########################################################################
##
#M  ViewObj( <ioTCPstream> )
##
InstallMethod( ViewObj, "for ioTCPstream",
[ IsInputOutputTCPStreamRep and IsInputOutputStream ],
function(stream)
    Print("< ");
    if IsClosedStream(stream) then
        Print("closed ");
    fi;
    Print("input/output TCP stream to ",stream![2],":", stream![3][1], " >");
end);


###########################################################################
##
#M  PrintObj( <ioTCPstream> )
##
InstallMethod( PrintObj, "for ioTCPstream",
[ IsInputOutputTCPStreamRep and IsInputOutputStream ],
function(stream)
    local i;
    Print("< ");
    if IsClosedStream(stream) then
        Print("closed ");
    fi;
    Print("input/output TCP stream to ",stream![2],":", stream![3][1], " >");
end);


###########################################################################
##
#M  ReadByte( <ioTCPstream> )
##
InstallMethod( ReadByte, "for ioTCPstream", 
[ IsInputOutputTCPStreamRep and IsInputOutputStream ],
function(stream)
local buf;
    buf := IO_Read( stream![1], 1 );
    if buf = fail or Length(buf) = 0 then
        stream![4] := true;
        return fail;
    else
        stream![4] := true;
        return INT_CHAR(buf[1]);
    fi;
end);


###########################################################################
##
#M  ReadLine( <ioTCPstream> )
##
InstallMethod( ReadLine, "for ioTCPstream",
[ IsInputOutputTCPStreamRep and IsInputOutputStream ],
function( stream )
    local sofar, chunk;
    sofar := IO_Read( stream![1], 1 );
    if sofar = fail or Length(sofar) = 0 then
        stream![4] := true;
        return fail;
    fi;
    while sofar[ Length(sofar) ] <> '\n' do
        chunk := IO_Read( stream![1], 1);
        if chunk = fail or Length(chunk) = 0 then
            stream![4] := true;
            return sofar;
        fi;
        Append( sofar, chunk );
    od;
    return sofar;
end);


###########################################################################
##
#M  ReadAllIoTCPStream( <ioTCPstream> )
##
BindGlobal( "ReadAllIoTCPStream", function(stream, limit)
    local sofar, chunk, csize;
    if limit = -1 then
        csize := 20000;
    else
        csize := Minimum(20000,limit);
        limit := limit - csize;
    fi;
    sofar := IO_Read(stream![1], csize);
    if sofar = fail or Length(sofar) = 0 then
        stream![4] := true;
        return fail;
    fi;
    while limit <> 0  do
        if limit = -1 then
            csize := 20000;
        else
            csize := Minimum(20000,limit);
            limit := limit - csize;
        fi;
        chunk := IO_Read( stream![1], csize);
        if chunk = fail or Length(chunk) = 0 then
            stream![4] := true;
            return sofar;
        fi;
        Append(sofar,chunk);
    od;
    return sofar;
end);


InstallMethod( ReadAll, "for ioTCPstream", 
    [ IsInputOutputTCPStreamRep and IsInputOutputStream ],
    stream ->  ReadAllIoTCPStream(stream, -1) );


InstallMethod( ReadAll, "for ioTCPstream", 
[ IsInputOutputTCPStreamRep and IsInputOutputStream, IsInt ],
function( stream, limit )
    if limit < 0 then
        Error("ReadAll: negative limit not allowed");
    fi;
    return  ReadAllIoTCPStream(stream, limit);
end);


###########################################################################
##
#M  WriteByte( <ioTCPstream> )
##
InstallMethod( WriteByte, "for ioTCPstream", 
[ IsInputOutputTCPStreamRep and IsInputOutputStream, IsInt ],
function(stream, byte)
    local ret,s;
    if byte < 0 or 255 < byte  then
        Error( "<byte> must an integer between 0 and 255" );
    fi;
    s := [CHAR_INT(byte)];
    ConvertToStringRep( s );
    ret := IO_Write( stream![1], s );
    if ret <> 1 then
        return fail;
    else
        return true;
    fi;
end);


###########################################################################
##
#M  WriteLine( <ioTCPstream>, <string> ) . . . write plus newline and flush
##
InstallMethod( WriteLine, "for ioTCPstream",
[ IsInputOutputTCPStreamRep and IsInputOutputStream, IsString ],
function( stream, string )
#    local res;
#    res := WriteAll( stream, string );
#    if res <> true  then 
#      return res;  
#    fi;
#    WriteByte( stream, INT_CHAR('\n') );
#    return IO_Flush( stream![1] );
return IO_WriteLine( stream![1], string );
end );


###########################################################################
##
#M  WriteAll( <ioTCPstream>, <string> )  . . . . . . . . .  write all bytes
##
InstallMethod( WriteAll, "for ioTCPstream",
[ IsInputOutputTCPStreamRep and IsInputOutputStream, IsString ],
function( stream, string )
    local   byte;
    for byte in string  do
        if WriteByte( stream, INT_CHAR(byte) ) <> true  then
            return fail;
        fi;
    od;
    return true;
end );


###########################################################################
##
#M IsEndOfStream( <ioTCPstream> )
##
InstallMethod( IsEndOfStream, "iostream",
    [ IsInputOutputTCPStreamRep and IsInputOutputStream ],
    stream -> not IO_HasData( stream![1] ) );
    # or IS_BLOCKED_IOSTREAM(stream![1]) );
        

###########################################################################
##
#M  CloseStream( <ioTCPstream> )
##
InstallMethod( CloseStream, "for ioTCPstream",
[ IsInputOutputTCPStreamRep and IsInputOutputStream ],
function(stream)
    IO_Close( stream![1] );
    SetFilterObj( stream, IsClosedStream );
end);


###########################################################################
##
#M  FileDescriptorOfStream( <ioTCPstream> )
##
InstallMethod( FileDescriptorOfStream, "for ioTCPstream",
[ IsInputOutputTCPStreamRep and IsInputOutputStream ],
stream -> IO_GetFD( stream![1] ) );


###########################################################################
##
#F  SCSCPwait( <ioTCPstream>, [ <timeout>] )
##
InstallGlobalFunction( SCSCPwait,
function( arg )
if Length(arg) = 2 then
    IO_Select( [ arg[1]![1] ], [ ], [ ], [ ], arg[2], 0 );
elif Length(arg) = 1 then
    IO_Select( [ arg[1]![1] ], [ ], [ ], [ ], 3600, 0 );
fi;
end);    

###########################################################################
##
#E 
##
        