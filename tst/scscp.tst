gap> START_TEST("$Id$");
gap> SetInfoLevel(InfoSCSCP,0);
gap> PingSCSCPservice( "localhost", 26133 );
true
gap> server := "localhost";;
gap> stream:=InputOutputTCPStream( server, 26133 );
< input/output TCP stream to localhost:26133>
gap> WriteLine( stream, "<?scscp version=\"1.2\" ?>" );
true
gap> CloseStream(stream);
gap> EvaluateBySCSCP( "WS_Factorial", [10], server, 26133).object;
"3628800"
gap> EvaluateBySCSCP( "WS_IdGroup", [ SymmetricGroup(3) ], server, 26133 ).object;
[ 6, 1 ]
gap> EvaluateBySCSCP( "GroupIdentificationService", [ [ (1,2,3), (2,3) ] ], server, 26133 ).object;
[ 6, 1 ]
gap> ReadPackage("scscp/example/id512.g");
true
gap> G := DihedralGroup( IsPermGroup, 512 );;
gap> IdGroup512( G );
[ 512, 2042 ]
gap> S := SymmetricGroup( 3 );;
gap> S1 := StoreAsRemoteObject( S, server, 26133 );;
gap> EvaluateBySCSCP( "WS_IdGroup", [ S1 ], server, 26133 ).object;
[ 6, 1 ]
gap> RetrieveRemoteObject( S1 );
Group([ (1,2,3), (1,2) ])
gap> UnbindRemoteObject( S1 );
true
gap> STOP_TEST( "scscp.tst", 0 );