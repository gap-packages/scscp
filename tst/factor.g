TestFactorial:=function( server, port, username, nrsessions, sessionlength )
# This is a test to experiment with various patterns of clients requests.
# Usage example: TestFactorial( "localhost", 26133, "user1_", 10, 20 );
local call_nr, n, stream, k, res, obj;
res:=[];
call_nr:=0;
for n in [ 1 .. nrsessions ] do
  # This is single request
  Print( "EvaluateBySCSCP returns ", 
         EvaluateBySCSCP( "WS_Factorial", [ n ], server, port ), "\n");

  # this is the beginning of a single session with a sequence of requests
  stream:=InputOutputTCPStream( server, port );
  StartSCSCPsession( stream );

  for k in [ 1 .. sessionlength ] do
    call_nr:=call_nr+1;
    Print( call_nr, " \c");
    OMPutProcedureCall( stream, "WS_Factorial", rec( object:= [k], 
                         attributes:=[ ["call_id", Concatenation(username, String(call_nr)) ] ] ) );
    SCSCPwait( stream );
    obj:=OMGetObjectWithAttributes( stream );
    Add( res, obj );
  od;
  Print("\n");
  CloseStream(stream); # now the sequence of requests is closed
od; 
return res;
end;