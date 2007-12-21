#############################################################################
##
#W server.g                 The SCSCP package             Alexander Konovalov
#W                                                               Steve Linton
##
#H $Id$
##
#############################################################################


#############################################################################
#
# RunSCSCPserver( <server>, <port> )
#
# the 1st argument is the name of the server, e.g. "localhost" or 
# "http://someserver.somewhere", the 2nd is the port number as an integer
#
InstallGlobalFunction( RunSCSCPserver,
function( server, port )

local socket, lookup, res, disconnect, socket_descriptor, 
     stream, objrec, pos, call_ID_value, atp, callinfo, output, 
     return_cookie, cookie, omtext, localstream, callresult, 
     errormessage, str, session_id, welcome_string, client_message;

SCSCPserverMode := true;
SCSCPserverAddress := server;
SCSCPserverPort := port;
session_id:=0;
socket := IO_socket( IO.PF_INET, IO.SOCK_STREAM, "tcp" );
IO_setsockopt( socket,IO.SOL_SOCKET,IO.SO_REUSEADDR,"xxxx" );

lookup := IO_gethostbyname( server );
if lookup = fail then
    return rec( socket := fail,
            errormsg := "RunSCSCPserver: cannot find hostname" );
fi;

res := IO_bind( socket, IO_make_sockaddr_in( lookup.addr[1], port ) );
if res = fail then 
    Print( "Error: ", LastSystemError(), "\n" );
    IO_close( socket );
    # Trick to select next available port automatically
    Print("Trying next port ", port+1, "\n" );
    RunSCSCPserver( server, port+1 );
    return;
else
    Print("Ready to accept TCP/IP connections at ", server, ":", port, " ...\n");
    IO_listen( socket, 5 ); # Allow a backlog of 5 connections
    repeat # until false
    disconnect := false;  
    repeat # until disconnect
        # We accept connections from everywhere
        Info(InfoSCSCP, 1, "Waiting for new client connection at ", server, ":", port, " ...");
        socket_descriptor := IO_accept( socket, IO_MakeIPAddressPort("0.0.0.0",0) );
        Info(InfoSCSCP, 1, "Got connection ...");
        stream := InputOutputTCPStream( socket_descriptor );
        Info(InfoSCSCP, 1, "Stream created ...");
        # Since we do not have CAS_IP (IO_getpid was promised soon),
        # we numerate sessions for easier browsing the output 
        session_id := session_id + 1;
        welcome_string:= Concatenation( 
          "<?scscp service_name=\"GAP\" service_version=\"", VERSION, 
          "\" service_id=\"", server, ":", String(port), ":", String(IO_getpid()), 
          "\" scscp_versions=\"", SCSCP_VERSION, "\" ?>");
        Info(InfoSCSCP, 1, "Sending connection initiation message" );  
        Info(InfoSCSCP, 2, welcome_string );  
        WriteLine( stream, welcome_string );
        client_message := ReadLine( stream );
        Print( "Client's version is ", client_message );
        WriteLine( stream, "<?scscp version=\"1.0\" ?>" );
        repeat
            Info(InfoSCSCP, 1, "Waiting for OpenMath object ...");
            IO_Select( [ stream![1] ], [ ], [ ], [ ], 60*60, 0 ); 
            Info(InfoSCSCP, 1, "Retrieved, starting evaluation ...");
            callresult:=CALL_WITH_CATCH( OMGetObjectWithAttributes, [ stream ] );
            Info(InfoSCSCP, 1, "Evaluation completed");
            if callresult[1] then
              objrec := callresult[2];
            else
              errormessage := callresult[2]{[6..Length(callresult[2])]};
              if InfoLevel( InfoSCSCP ) > 0 then
                Print( "Sending error message : ");
                for str in errormessage do
                  Print( str, " " );
                od;
                Print("\n");
              fi;
              
              if InfoLevel( InfoSCSCP ) > 2 then
                Print("#I  Composing procedure_terminated message: \n");
                omtext:="";
                localstream := OutputTextString( omtext, true );
                OMPutProcedureTerminated( localstream, rec( object:=errormessage ), "error_system_specific" );
                Print(omtext);
              fi;          
            
              OMPutProcedureTerminated( stream, rec( object := errormessage ), "error_system_specific" );
              
              Info(InfoSCSCP, 1, "Closing connection ...");
              disconnect:=true;
              break;            
            fi;  
            if objrec = fail then
              Info(InfoSCSCP, 1, "Connection was closed by the client");
              disconnect:=true;
              break;
            fi;
            
            # TO-DO: Rewrite analising attributes (i.e. options)
            
            pos := PositionProperty( objrec.attributes, atp -> atp[1]="call_ID" );
            if pos<>fail then 
                call_ID_value := objrec.attributes[pos][2];
            else
                call_ID_value := "N/A";
            fi;
            
            pos := PositionProperty( objrec.attributes, atp -> atp[1]="option_return_cookie" );
            if pos<>fail then 
                return_cookie := true;
            else
                return_cookie := false;
            fi;           
            
            # we gather in callinfo additional information about the
            # procedure call: now it is only call_ID, in the future we
            # will add used memory, runtime, etc.
            callinfo:= [ [ "call_ID", call_ID_value ] ];
            
            Info( InfoSCSCP, 2, "call_ID ", call_ID_value, 
                  " : sending to client ", objrec.object ); 
            
            if return_cookie then
                cookie := TemporaryGlobalVarName( "TEMPVarSCSCP" );  
                ASS_GVAR( cookie, objrec.object );
                if ISBOUND_GLOBAL( cookie ) then                                             
                    Info( InfoSCSCP, 2, "Result stored in the global variable ", cookie );  
                else
                    Error( "Failed to store result in the global variable ", cookie, "\n" );                                                  
                fi;
                output := RemoteObject( cookie, server, port );
            else
              output := objrec.object;
            fi;       
                  
            if InfoLevel( InfoSCSCP ) > 2 then
              Print("#I  Composing procedure_completed message: \n");
              omtext:="";
              localstream := OutputTextString( omtext, true );
              OMPutProcedureCompleted( localstream, 
                rec( object := output, 
                  attributes:= callinfo ) );
              Print(omtext);
            fi;       
            
            # This may be already broken pipe if the client 
            # terminated the process, and this causes server crash 

            OMPutProcedureCompleted( stream, 
              rec( object := output, 
                attributes:= callinfo ) );
        until false;
        Print("Closing stream ... \c");
        # socket descriptor will be closed here
        CloseStream( stream );
        Print("done \n");
    until disconnect;
    until false;
    Print("Server terminated, closing socket ... \c");   
    IO_close(socket);
    Print("done \n");
fi;
end);