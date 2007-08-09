#############################################################################
##
#W server.g                 The SCSCP package             Alexander Konovalov
#W                                                               Steve Linton
##
#H $Id: $
##
#############################################################################

RunSCSCPserver:= function( server, port )
#
# the argument is the name of the server, e.g. 
# "localhost" or "http://someserver.somewhere"
#
local sock, lookup, res, terminate, disconnect, socket_descriptor, 
     stream, objrec, call_ID_pos, call_ID_value, atp, attrlist,
     omtext, localstream, callresult, errormessage, str, session_id;

session_id:=0;
sock := IO_socket( IO.PF_INET, IO.SOCK_STREAM, "tcp" );
IO_setsockopt( sock,IO.SOL_SOCKET,IO.SO_REUSEADDR,"xxxx" );

lookup := IO_gethostbyname( server );
if lookup = fail then
    return rec( sock := fail,
            errormsg := "RunSCSCPserver: cannot find hostname" );
fi;

res := IO_bind( sock, IO_make_sockaddr_in( lookup.addr[1], port ) );
if res = fail then 
    Print( "Error: ", LastSystemError(), "\n" );
    IO_close( sock );
    # Trick to select next available port automatically
    Print("Trying next port ", port+1, "\n" );
    RunSCSCPserver( server, port+1 );
    return;
else
    Print("Ready to accept TCP/IP connections at ", server, ":", port, " ...\n");
    IO_listen( sock, 5 ); # Allow a backlog of 5 connections
    terminate := false;
    repeat # until terminate
    disconnect := false;  
    repeat # until disconnect
        # We accept connections from everywhere
        Print("Waiting for new client connection at ", server, ":", port, " ...\n");
        socket_descriptor := IO_accept( sock, IO_MakeIPAddressPort("0.0.0.0",0) );
        Print("Got connection ... ");
        stream := InputOutputTCPStream( socket_descriptor );
        Print("Stream created ... \n");
        Print("Sending connection information message \c ");
        # Since we do not have CAS_IP (IO_getpid was promised soon),
        # we numerate sessions for easier browsing the output 
        session_id := session_id + 1;
        Print("SCSCP_VERSION 0 CAS_PID ", session_id, "\n");
        WriteLine( stream, Concatenation("SCSCP_VERSION 0 CAS_PID ", String(session_id) ) );
        repeat
            Print("Waiting for an OpenMath object ... \n");
            IO_Select( [ stream![1] ], [ ], [ ], [ ], 60*60, 0 ); 
            # IO_select( [ IO_GetFD(stream![1]) ], [ ], [ ], 60*60, 0 );
            callresult:=CALL_WITH_CATCH( OMGetObjectWithAttributes, [ stream ] );
            if callresult[1] then
              objrec := callresult[2];
            else
              errormessage := callresult[2]{[6..Length(callresult[2])]};
              Print("\Sending error message : \n");
              for str in errormessage do
                Print( str, " ");
              od;
              Print("\n");

              if InfoLevel( InfoSCSCP ) > 2 then
                Print("#I  Composing procedure_terminated message: \n");
                omtext:="";
                localstream := OutputTextString( omtext, true );
                OMPutProcedureTerminated( localstream, rec( object:=errormessage ), "error_system_specific" );
                Print(omtext);
              fi;          

              OMPutProcedureTerminated( stream, rec( object := errormessage ), "error_system_specific" );
                
              Print("Closing connection...\n");
              disconnect:=true;
              break;            
            fi;  
            if objrec = fail then
              Print("\nConnection was closed by the client\n");
              disconnect:=true;
              break;
            fi;
            Print("done.\n");
            
            # TO-DO: Rewrite analising options ???
            
            if IsBound( objrec.attributes ) then
                Print("objrec.attributes := ", objrec.attributes, "\n");
                call_ID_pos := PositionProperty( objrec.attributes, atp -> atp[1]="call_ID" );
                if call_ID_pos<>fail then 
                    call_ID_value := objrec.attributes[call_ID_pos][2];
                else
                    call_ID_value := fail;
                fi;
            else
                call_ID_value := fail;
            fi;
            if call_ID_value = fail then
               attrlist:= [ ];
            else
               attrlist:= [ [ "call_ID", call_ID_value ] ];
            fi;
            
            Print("Sending to client : ", objrec.object, 
                  " in response to call_ID ", call_ID_value, "\n");  
                  
            if InfoLevel( InfoSCSCP ) > 2 then
              Print("#I  Composing procedure_completed message: \n");
              omtext:="";
              localstream := OutputTextString( omtext, true );
              OMPutProcedureCompleted( localstream, rec( object:=objrec.object ) );
              Print(omtext);
            fi;          

            OMPutProcedureCompleted( stream, 
              rec( object := objrec.object, 
                attributes:= attrlist ) );
            # IO_Flush( stream![1] );
            if objrec.object="Terminated" then
                disconnect:=true;
                terminate:=true;
                break;  
            fi;  
        until false;
        Print("Closing stream ... \c");
        # socket descriptor will be closed here
        CloseStream( stream );
        Print("done \n");
    until disconnect;
    until terminate;
    Print("Server terminated, closing socket ... \c");   
    IO_close(sock);
    Print("done \n");
fi;
end;