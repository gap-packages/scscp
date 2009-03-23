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
     stream, objrec, pos, call_id_value, atp, callinfo, output, 
     return_cookie, return_nothing, cookie, omtext, localstream, callresult, responseresult,
     errormessage, str, session_id, welcome_string, client_message;

SCSCPserverMode := true;
SCSCPserverAddress := server;
SCSCPserverPort := port;
socket := IO_socket( IO.PF_INET, IO.SOCK_STREAM, "tcp" );
IO_setsockopt( socket, IO.SOL_SOCKET,IO.SO_REUSEADDR, "xxxx" );

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
    # Print("Trying next port ", port+1, "\n" );
    # RunSCSCPserver( server, port+1 );
    # Printing to *errout* we are able to see this even if the output was redirected
    PrintTo( "*errout*", 
      "\n******************************************\n",
      "failed to start SCSCP server at port ", port, 
      "\n******************************************\n\n" );
    # Hack to be able to quit GAP from gapscscp.sh script
    BindGlobal( "SCSCPserverStatus" , fail );
    return;
else
	welcome_string:= Concatenation( 
          "<?scscp service_name=\"GAP\" service_version=\"", VERSION, 
          "\" service_id=\"", server, ":", String(port), ":", String(IO_getpid()), 
          "\" scscp_versions=\"", SCSCP_VERSION, "\" ?>");
    Print( "#I  Ready to accept TCP/IP connections at ", server, ":", port, " ... \n" );
    IO_listen( socket, 5 ); # Allow a backlog of 5 connections
    repeat # until false
    disconnect := false;  
    repeat # until disconnect
        # We accept connections from everywhere
        Info(InfoSCSCP, 1, "Waiting for new client connection at ", server, ":", port, " ..." );
        if IN_SCSCP_TRACING_MODE then SCSCPTraceSuspendThread(); fi;
        socket_descriptor := IO_accept( socket, IO_MakeIPAddressPort("0.0.0.0",0) );
        if IN_SCSCP_TRACING_MODE then SCSCPTraceRunThread(); fi;
        Info(InfoSCSCP, 1, "Got connection ...");
        stream := InputOutputTCPStream( socket_descriptor );
        Info(InfoSCSCP, 1, "Stream created ...");
        Info(InfoSCSCP, 1, "Sending connection initiation message" );  
        Info(InfoSCSCP, 2, welcome_string );  
        WriteLine( stream, welcome_string );
        client_message := ReadLine( stream );
        Info(InfoSCSCP, 1, "Client's version is ", client_message );
        WriteLine( stream, Concatenation( "<?scscp version=\"", SCSCP_VERSION, "\" ?>" ) );
        repeat
            Info(InfoSCSCP, 1, "Waiting for OpenMath object ...");
            # currently the timeout is 3600 seconds = 1 hour
            if IN_SCSCP_TRACING_MODE then SCSCPTraceSuspendThread(); fi;
            callresult:=CALL_WITH_CATCH( IO_Select, [  [ stream![1] ], [ ], [ ], [ ], 60*60, 0 ] );
            if IN_SCSCP_TRACING_MODE then SCSCPTraceRunThread(); fi;
            if VERSION = "4.dev" then
              if not callresult[1] then
                disconnect:=true;
                break;         
              fi;
            fi;

            Info(InfoSCSCP, 1, "Retrieved, starting evaluation ...");
            callresult:=CALL_WITH_CATCH( OMGetObjectWithAttributes, [ stream ] );
            Info(InfoSCSCP, 1, "Evaluation completed");
            
            # FOR COMPATIBILITY WITH 4.4.12 WITH REDUCED FUNCTIONALITY
            if VERSION <> "4.dev" then callresult := [ true, callresult ]; fi;

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
            
            pos := PositionProperty( objrec.attributes, atp -> atp[1]="call_id" );
            if pos<>fail then 
                call_id_value := objrec.attributes[pos][2];
            else
                call_id_value := "N/A";
            fi;
            
            if ForAny( objrec.attributes, atp -> atp[1]="option_return_cookie" ) then 
                return_cookie := true;
            else
                return_cookie := false;
                if ForAny( objrec.attributes, atp -> atp[1]="option_return_nothing" ) then 
                  return_nothing := true;
                else
                  return_nothing := false;
                fi;
            fi;   
            
            # we gather in callinfo additional information about the
            # procedure call: now it is only call_id, in the future we
            # will add used memory, runtime, etc.
            callinfo:= [ [ "call_id", call_id_value ] ];
                        
            if not callresult[1] then
              if InfoLevel( InfoSCSCP ) > 0 then
                Print( "#I  Sending error message: ", objrec.object, "\n" );
              fi; 
              if objrec.object[1] = "OpenMathError: " then
                errormessage := [ 
                  OMPlainString( Concatenation( "<OMS cd=\"", objrec.object[4], "\" name=\"", objrec.object[6], "\"/>" ) ), 
                  "error", objrec.object[2] ];
              else
                # glue together error messages into a single string
              	errormessage := [ Concatenation( server, ":", String(port), 
              	                  " reports : ", Concatenation( objrec.object ) ), 
              	                  "scscp1", "error_system_specific" ];
 			  fi;
 			  
              if InfoLevel( InfoSCSCP ) > 2 then
                Print("#I  Composing procedure_terminated message: \n");
                omtext:="";
                localstream := OutputTextString( omtext, true );
                OMPutProcedureTerminated( localstream, rec( object:=errormessage[1], attributes:=callinfo ), errormessage[2], errormessage[3] );
                Print(omtext);
              fi;          
              
              if IN_SCSCP_TRACING_MODE then SCSCPTraceSendMessage(0); fi;
              responseresult := CALL_WITH_CATCH( OMPutProcedureTerminated, 
              							[ stream, 
              							  rec( object:=errormessage[1], 
              							   attributes:=callinfo ), 
              							  errormessage[2], 
              							  errormessage[3] ] );
              							  
              # FOR COMPATIBILITY WITH 4.4.12 WITH REDUCED FUNCTIONALITY
              if VERSION <> "4.dev" then responseresult := [ true, responseresult ]; fi;
              							  
              if responseresult[1] then
              	Info(InfoSCSCP, 1, "procedure_terminated message sent, closing connection ...");
              else
              	Info(InfoSCSCP, 1, "client already disconnected, closing connection on server side ...");				
              fi;	
              disconnect:=true;
              break;            
            fi;  
                       
            Info( InfoSCSCP, 2, "call_id ", call_id_value, 
                  " : sending to client ", objrec.object ); 
            
            if return_cookie then
                cookie := TemporaryGlobalVarName( "TEMPVarSCSCP" );  
                ASS_GVAR( cookie, objrec.object );
                if ISBOUND_GLOBAL( cookie ) then                                             
                    Info( InfoSCSCP, 2, "Result stored in the global variable ", cookie );  
                else
                    Error( "Failed to store result in the global variable ", cookie, "\n" );                                                  
                fi;
                output := rec( object     := RemoteObject( cookie, server, port ),
                               attributes := callinfo );
            elif return_nothing then
			  output := rec( attributes:= callinfo );
            else
              output := rec( object := objrec.object, attributes:= callinfo );
            fi;       
                  
            if InfoLevel( InfoSCSCP ) > 2 then
              Print("#I  Composing procedure_completed message: \n");
              omtext:="";
              localstream := OutputTextString( omtext, true );
              OMPutProcedureCompleted( localstream, output );
              Print(omtext);
            fi;       
 
            # TODO: if the client already disconnected at this moment, the server will crash :(
  	        if IN_SCSCP_TRACING_MODE then SCSCPTraceSendMessage(0); fi;
            responseresult := CALL_WITH_CATCH( OMPutProcedureCompleted, [ stream, output ] );

            # FOR COMPATIBILITY WITH 4.4.12 WITH REDUCED FUNCTIONALITY
            if VERSION <> "4.dev" then responseresult := [ true, responseresult ]; fi;
            						    
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