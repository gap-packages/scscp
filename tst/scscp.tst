gap> START_TEST( "scscp.tst" );
gap> SetInfoLevel(InfoSCSCP,0);
gap> server := "localhost";;
gap> PingSCSCPservice( server, 26133 );
true
gap> EvaluateBySCSCP( "WS_Factorial", [10], server, 26133).object;
3628800
gap> EvaluateBySCSCP( "WS_IdGroup", [ SymmetricGroup(3) ], server, 26133 ).object;
[ 6, 1 ]
gap> EvaluateBySCSCP( "GroupIdentificationService", [ [ (1,2,3), (2,3) ] ], server, 26133 ).object;
[ 6, 1 ]
gap> ReadPackage("scscp", "example/id512.g");
true
gap> IdGroup512( DihedralGroup( 512 ) );
[ 512, 2042 ]
gap> S1 := StoreAsRemoteObject( SymmetricGroup( 3 ), server, 26133 );;
gap> EvaluateBySCSCP( "WS_IdGroup", [ S1 ], server, 26133 ).object;
[ 6, 1 ]
gap> RetrieveRemoteObject( S1 );
Group([ (1,2,3), (1,2) ])
gap> UnbindRemoteObject( S1 );
true
gap> STOP_TEST( "scscp.tst", 10000000 );
