# from paragraph [ 6, 1, 2, 4 ][ "/Users/alexk/gap4r5/pkg/scscp/doc/../lib/connect.gd", 47 ]


gap> SetInfoLevel( InfoSCSCP, 2 );
gap> s:=NewSCSCPconnection("localhost",26133);
#I  Creating a socket ...
#I  Connecting to a remote socket via TCP/IP ...
#I  Got connection initiation message
#I  <?scscp service_name="GAP" service_version="4.dev" service_id="localhost:2\
6133:52918" scscp_versions="1.0 1.1 1.2 1.3" ?>
#I  Requesting version 1.3 from the server ...
#I  Server confirmed version 1.3 to the client ...
< connection to localhost:26133 session_id=localhost:26133:52918 >
gap> CloseSCSCPconnection(s);


# from paragraph [ 6, 1, 3, 4 ][ "/Users/alexk/gap4r5/pkg/scscp/doc/../lib/connect.gd", 85 ]


gap> SetInfoLevel( InfoSCSCP, 0 );
gap> s:=NewSCSCPconnection("localhost",26133);
< connection to localhost:26133 session_id=localhost:26133:52918 >
gap> CloseSCSCPconnection(s);


# from paragraph [ 6, 2, 3, 11 ][ "/Users/alexk/gap4r5/pkg/scscp/doc/../lib/process.gd", 142 ]


gap> s := NewProcess( "WS_Factorial", [10], "localhost", 26133 );                  
< process at localhost:26133 pid=52918 >
gap> x := CompleteProcess(s);
rec( attributes := [ [ "call_id", "localhost:26133:52918:TPNiMjCT" ] ],
  object := 3628800 )


# from paragraph [ 6, 3, 1, 9 ][ "/Users/alexk/gap4r5/pkg/scscp/doc/../lib/scscp.gd", 541 ]


gap> EvaluateBySCSCP( "WS_Factorial",[10],"localhost",26133);
#I  Creating a socket ...
#I  Connecting to a remote socket via TCP/IP ...
#I  Got connection initiation message
#I  Requesting version 1.3 from the server ...
#I  Server confirmed version 1.3 to the client ...
#I  Request sent ...
#I  Waiting for reply ...
rec( attributes := [ [ "call_id", "localhost:26133:2442:6hMEN40d" ] ], 
  object := 3628800 )
gap> SetInfoLevel(InfoSCSCP,0);
gap> EvaluateBySCSCP( "WS_Factorial",[10],"localhost",26133 : output:="cookie" ); 
rec( attributes := [ [ "call_id", "localhost:26133:2442:jNQG6rml" ] ], 
  object := < remote object scscp://localhost:26133/TEMPVarSCSCP5KZIeiKD > )
gap> EvaluateBySCSCP( "WS_Factorial",[10],"localhost",26133 : output:="nothing" );
rec( attributes := [ [ "call_id", "localhost:26133:2442:9QHQrCjv" ] ], 
  object := "procedure completed" )


# from paragraph [ 6, 3, 1, 11 ][ "/Users/alexk/gap4r5/pkg/scscp/doc/client.xml", 60 ]


gap> G:=SymmetricGroup(4);
Sym( [ 1 .. 4 ] )
gap> gens:=GeneratorsOfGroup(G);
[ (1,2,3,4), (1,2) ]
gap> EvaluateBySCSCP( "GroupIdentificationService", [ gens ],
>                     "localhost", 26133 : debuglevel:=3 ); 
rec( attributes := [ [ "call_id", "localhost:26133:2442:xOilXtnw" ], 
      [ "info_runtime", 4 ], [ "info_memory", 2596114432 ], 
      [ "info_message", "Memory usage for the result is 48 bytes" ] ], 
  object := [ 24, 12 ] )


# from paragraph [ 6, 3, 1, 13 ][ "/Users/alexk/gap4r5/pkg/scscp/doc/client.xml", 77 ]


gap> IdGroupWS := function( G )
>    local H, result;
>    if not IsPermGroup(G) then
>      H:= Image( IsomorphismPermGroup( G ) );
>    else
>      H := G;
>    fi;  
>    result := EvaluateBySCSCP ( "GroupIdentificationService", 
>                [ GeneratorsOfGroup(H) ], "localhost", 26133 );
>    return result.object;
> end;;


# from paragraph [ 6, 3, 1, 15 ][ "/Users/alexk/gap4r5/pkg/scscp/doc/client.xml", 95 ]


gap> G:=DihedralGroup(64);
<pc group of size 64 with 6 generators>
gap> IdGroupWS(G);
[ 64, 52 ]


# from paragraph [ 6, 4, 0, 5 ][ "/Users/alexk/gap4r5/pkg/scscp/doc/client.xml", 119 ]


gap> x := [ Z(3)^0, Z(3), 0*Z(3) ];
[ Z(3)^0, Z(3), 0*Z(3) ]


# from paragraph [ 6, 4, 0, 7 ][ "/Users/alexk/gap4r5/pkg/scscp/doc/client.xml", 126 ]


gap> OMString( x );
"<OMOBJ> <OMA> <OMS cd=\"list1\" name=\"list\"/> <OMA> <OMS cd=\"arith1\" name\
=\"power\"/> <OMA> <OMS cd=\"finfield1\" name=\"primitive_element\"/> <OMI>3</\
OMI> </OMA> <OMI>0</OMI> </OMA> <OMA> <OMS cd=\"arith1\" name=\"power\"/> <OMA\
> <OMS cd=\"finfield1\" name=\"primitive_element\"/> <OMI>3</OMI> </OMA> <OMI>\
1</OMI> </OMA> <OMA> <OMS cd=\"arith1\" name=\"times\"/> <OMA> <OMS cd=\"finfi\
eld1\" name=\"primitive_element\"/> <OMI>3</OMI> </OMA> <OMI>0</OMI> </OMA> </\
OMA> </OMOBJ>"
gap> Length( OMString(x) );
452


# from paragraph [ 6, 5, 0, 11 ][ "/Users/alexk/gap4r5/pkg/scscp/doc/client.xml", 278 ]


gap> stream:=InputOutputTCPStream( "localhost", 26133 );
< input/output TCP stream to localhost:26133 >
gap> StartSCSCPsession(stream);
"localhost:26133:6184"
gap> OMPutProcedureCall( stream, "store_session", 
>       rec( object := [ SymmetricGroup(3) ], 
>        attributes := [ [ "call_id", "1" ], 
>                        ["option_return_cookie"] ] ) );
true
gap> SCSCPwait( stream );
gap> G:=OMGetObjectWithAttributes( stream ).object;
< remote object scscp://localhost:26133/TEMPVarSCSCPo3Bc8J75 >
gap> OMPutProcedureCall( stream, "PointImages", 
>       rec( object := [ G, 1 ], 
>        attributes := [ [ "call_id", "2" ] ] ) );
true
gap> SCSCPwait( stream );
gap> OMGetObjectWithAttributes( stream );
rec( attributes := [ [ "call_id", "2" ] ], object := [ 2 ] )
gap> OMPutProcedureCall( stream, "PointImages", 
>       rec( object := [ G, 2 ], 
>        attributes := [ [ "call_id", "3" ] ] ) );
true
gap> SCSCPwait( stream );
gap> OMGetObjectWithAttributes( stream );
rec( attributes := [ [ "call_id", "3" ] ], object := [ 1, 3 ] )
gap> OMPutProcedureCall( stream, "retrieve", 
>       rec( object := [ G ], 
>        attributes := [ [ "call_id", "4" ] ] ) );
true
gap> SCSCPwait( stream );
gap> OMGetObjectWithAttributes( stream );
rec( attributes := [ [ "call_id", "4" ] ], 
  object := Group([ (1,2,3), (1,2) ]) )
gap> CloseStream(stream);


# from paragraph [ 6, 5, 1, 6 ][ "/Users/alexk/gap4r5/pkg/scscp/doc/../lib/remote.gd", 74 ]


gap> s:=StoreAsRemoteObject( SymmetricGroup(3), "localhost", 26133 );
< remote object scscp://localhost:26133/TEMPVarSCSCPLvIUUtL3 >


# from paragraph [ 6, 5, 1, 8 ][ "/Users/alexk/gap4r5/pkg/scscp/doc/client.xml", 342 ]


gap> s![1]; 
"TEMPVarSCSCPLvIUUtL3"
gap> s![2];
"localhost"
gap> s![3];
26133


# from paragraph [ 6, 5, 1, 10 ][ "/Users/alexk/gap4r5/pkg/scscp/doc/client.xml", 357 ]


gap> OMPrint(s);
<OMOBJ>
      <OMR href="scscp://localhost:26133/TEMPVarSCSCPLvIUUtL3" />
</OMOBJ>


# from paragraph [ 6, 5, 1, 12 ][ "/Users/alexk/gap4r5/pkg/scscp/doc/client.xml", 369 ]


gap> EvaluateBySCSCP("WS_IdGroup",[s],"localhost",26133);  
rec( attributes := [ [ "call_id", "localhost:26133:52918:Viq6EWBP" ] ],
Line 183 : 
  object := [ 6, 1 ] )


# from paragraph [ 6, 5, 4, 4 ][ "/Users/alexk/gap4r5/pkg/scscp/doc/../lib/remote.gd", 105 ]


gap> RetrieveRemoteObject(s);
Group([ (1,2,3), (1,2) ])


# from paragraph [ 6, 5, 5, 4 ][ "/Users/alexk/gap4r5/pkg/scscp/doc/../lib/remote.gd", 134 ]


gap> UnbindRemoteObject(s);
true


# from paragraph [ 6, 5, 5, 6 ][ "/Users/alexk/gap4r5/pkg/scscp/doc/client.xml", 386 ]


gap> s:=StoreAsRemoteObject( SymmetricGroup(3), "localhost", 26133 );
< remote object scscp://localhost:26133/TEMPVarSCSCPNqc8Bkan >
gap> EvaluateBySCSCP( "WS_IdGroup", [ s ], "localhost", 26134 );
rec( object := [ 6, 1 ], attributes := [ [ "call_id", "localhost:26134:7414" ] ] )


# from paragraph [ 6, 5, 5, 8 ][ "/Users/alexk/gap4r5/pkg/scscp/doc/client.xml", 397 ]


gap> EvaluateBySCSCP("WS_IdGroup",[s],"localhost",26133 : output:="cookie" );
rec( attributes := [ [ "call_id", "localhost:26133:52918:mRU6w471" ] ], 
  object := < remote object scscp://localhost:26133/TEMPVarSCSCPS9SVe9PZ > )


