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
# "servername.somewhere.domain", the 2nd is the port number as an integer
#
# TODO: the server name may be determined automatically running 'hostname'
# then the boolean argument may specify whether to use localhost or hostname
# TODO: portname may be required strictly or not: "run at this port or fail"
# or "probe this port, if fails, find next suitable". 
# TODO: get easier portnumber at which server is running (for Jost)
#
if VERSION <> "4.dev" then
	CALL_WITH_CATCH := CallFuncList;
fi;

InstallGlobalFunction( RunSCSCPserver,
function( server, port )

local socket, lookup, res, disconnect, socket_descriptor, 
     stream, objrec, pos, call_ID_value, atp, callinfo, output, 
     return_cookie, cookie, omtext, localstream, callresult, responseresult,
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
    Info(InfoSCSCP, 1, "Ready to accept TCP/IP connections at ", server, ":", port, " ..." );
    IO_listen( socket, 5 ); # Allow a backlog of 5 connections
    repeat # until false
    disconnect := false;  
    repeat # until disconnect
        # We accept connections from everywhere
        Info(InfoSCSCP, 1, "Waiting for new client connection at ", server, ":", port, " ..." );
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
        Info(InfoSCSCP, 1, "Client's version is ", client_message );
        WriteLine( stream, Concatenation( "<?scscp version=\"", SCSCP_VERSION, "\" ?>" ) );
        repeat
            Info(InfoSCSCP, 1, "Waiting for OpenMath object ...");
            # currently the timeout is 3600 seconds = 1 hour
            callresult:=CALL_WITH_CATCH( IO_Select, [  [ stream![1] ], [ ], [ ], [ ], 60*60, 0 ] );
            if not callresult[1] then
              disconnect:=true;
              break;         
            fi;
            Info(InfoSCSCP, 1, "Retrieved, starting evaluation ...");
            callresult:=CALL_WITH_CATCH( OMGetObjectWithAttributes, [ stream ] );
            Info(InfoSCSCP, 1, "Evaluation completed");

            objrec := callresult[2]; # can be record, fail or list of strings

            if objrec = fail then
              Info(InfoSCSCP, 1, "Connection was closed by the client");
              disconnect:=true;
              break;
            fi;

			# We detect the case when objrec is not fail and not record 
			# to convert it to the standard objrec format. This happens
			# when error message is returned.
            if not IsRecord(objrec) then
            	objrec := rec( object := objrec, attributes := OMParseXmlObj(OMTempVars.OMATTR) );
			fi;
			
            # TODO: Rewrite analysing attributes (i.e. options)
            
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
                        
            if callresult[1] then
              pos := PositionProperty( objrec.attributes, atp -> atp[1]="option_return_nothing" );
              if pos<>fail then 
                Info(InfoSCSCP, 1, "option_return_nothing, closing connection ...");
                disconnect:=true;
                break;               
              fi;
            else
              if InfoLevel( InfoSCSCP ) > 0 then
                Print( "#I  Sending error message: ", objrec.object, "\n" );
              fi; 
              if objrec.object[1] = "OpenMathError: " then
                errormessage := [ 
                  OMPlainString( Concatenation( "<OMS cd=\"", objrec.object[4], "\" name=\"", objrec.object[6], "\"/>" ) ), 
                  "error", objrec.object[2] ];
              else
                # glue together error messages - specification says 
            	# there must be a string, so the list of strings is incorrect
              	errormessage := [ Concatenation( objrec.object ), "scscp1", "error_system_specific" ];
 			  fi;
 			  
              if InfoLevel( InfoSCSCP ) > 2 then
                Print("#I  Composing procedure_terminated message: \n");
                omtext:="";
                localstream := OutputTextString( omtext, true );
                OMPutProcedureTerminated( localstream, rec( object:=errormessage[1], attributes:=callinfo ), errormessage[2], errormessage[3] );
                Print(omtext);
              fi;          
            
              responseresult := CALL_WITH_CATCH( OMPutProcedureTerminated, 
              							[ stream, 
              							  rec( object:=errormessage[1], 
              							   attributes:=callinfo ), 
              							  errormessage[2], 
              							  errormessage[3] ] );
              if responseresult[1] then
              	Info(InfoSCSCP, 1, "procedure_terminated message sent, closing connection ...");
              else
              	Info(InfoSCSCP, 1, "client already disconnected, closing connection on server side ...");				
              fi;	
              disconnect:=true;
              break;            
            fi;  
                       
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
                rec( object := output, attributes:= callinfo ) );
              Print(omtext);
            fi;       
 
            # TODO: if the client already disconnected at this moment,
            # the server will crash :(
 
            responseresult := CALL_WITH_CATCH( OMPutProcedureCompleted,
            						[ stream, 
            						  rec( object := output, 
            						    attributes:= callinfo ) ] );
            if not responseresult[1] then
              Info(InfoSCSCP, 1, "client already disconnected, closing connection on server side ...");				
              disconnect:=true;
              break;   
            fi;						    
        until false;
        Info(InfoSCSCP, 1, "Closing stream ...");
        # socket descriptor will be closed here
        CloseStream( stream );
    until disconnect;
    until false;
    Print("Server terminated, closing socket ... \c");   
    IO_close(socket);
    Print("done \n");
fi;
end);