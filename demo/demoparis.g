# Calling SCSCP services
LoadPackage("scscp");
PingSCSCPservice( "localhost", 26133 );
EvaluateBySCSCP( "WS_Factorial", [ 10 ], "localhost", 26133 );
EvaluateBySCSCP( "WS_IdGroup", [ SymmetricGroup(3) ], "localhost", 26133 );
IdGroup(SymmetricGroup(3));
EvaluateBySCSCP( "GroupIdentificationService", [ [ (1,2,3), (2,3) ] ], "localhost", 26133 ); 
IdGroup( Group( (1,2,3), (2,3) ) );
ReadPackage("scscp/example/id512.g");
G := DihedralGroup( IsPermGroup, 512 );
IdGroup512( G );
SetInfoLevel( InfoSCSCP, 0 );
IdGroup512( G );
# Working with remote objects
S := SymmetricGroup( 3 );
S1 := StoreAsRemoteObject( S, "localhost", 26133 );
EvaluateBySCSCP( "WS_IdGroup", [ S1 ], "localhost", 26133 );         
GeneratorsOfGroup( S );
List( [1..4], i -> EvaluateBySCSCP( "PointImages", [ S1, i ], "localhost", 26133 ).object );
RetrieveRemoteObject( S1 );
UnbindRemoteObject( S1 );