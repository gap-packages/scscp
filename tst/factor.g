# $Id$

TestFactorial:=function( server, port, username, nrsessions, sessionlength )
# This is a test to experiment with various patterns of clients requests,
# you can call it e.g. like TestFactorial( "localhost", 26133, "user1_", 20, 20 );
local call_nr, n, stream, initmessage, k, res, obj;
res:=[];
call_nr:=0;
for n in [ 1 .. nrsessions ] do
  # This is single request
  Print( "EvaluateBySCSCP returns ", 
         EvaluateBySCSCP( "WS_Factorial", [ n ], server, port ), "\n");
  # this is the beginning of a single session with a sequence of requests
  stream:=InputOutputTCPStream( server, port );
  initmessage := ReadLine( stream );
  WriteLine( stream, "<?scscp version=\"1.2\" ?>" );
  ReadLine( stream );
  
  for k in [ 1 .. sessionlength ] do
    call_nr:=call_nr+1;
    Print( call_nr, " \c");
    OMPutProcedureCall( stream, "WS_Factorial", rec( object:= [k], 
                         attributes:=[ ["call_id", Concatenation(username, String(call_nr)) ] ] ) );
    IO_select( [ IO_GetFD(stream![1]) ], [ ], [ ], 60*60, 0 );
    obj:=OMGetObjectWithAttributes( stream );
    Add( res, obj );
  od;
  Print("\n");
  CloseStream(stream); # now the sequence of requests is closed
od; 
return res;
end;