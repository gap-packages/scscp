# Calling SCSCP services
#
# Connect to remote GAP SCSCP server at St Andrews
#
LoadPackage("scscp");
SetInfoLevel( InfoSCSCP, 0 );
port:=26133;
server:="chrystal.mcs.st-andrews.ac.uk";
PingSCSCPservice( server, 26133 );
EvaluateBySCSCP( "WS_Factorial", [ 10 ], server, 26133 );
EvaluateBySCSCP( "WS_IdGroup", [ SymmetricGroup(3) ], server, 26133 );
IdGroup(SymmetricGroup(3));
EvaluateBySCSCP( "GroupIdentificationService", [ [ (1,2,3), (2,3) ] ], server, 26133 ); 
IdGroup( Group( (1,2,3), (2,3) ) );
#
# Now start GAP SCSCP server locally and increase InfoLevel to look at details
#
SetInfoLevel( InfoSCSCP, 4 );
port:=26133;
server:="localhost";
PingSCSCPservice( server, 26133 );
EvaluateBySCSCP( "WS_Factorial", [ 10 ], server, 26133 );
EvaluateBySCSCP( "WS_IdGroup", [ SymmetricGroup(3) ], server, 26133 );
IdGroup(SymmetricGroup(3));
EvaluateBySCSCP( "GroupIdentificationService", [ [ (1,2,3), (2,3) ] ], server, 26133 ); 
IdGroup( Group( (1,2,3), (2,3) ) );
ReadPackage("scscp", "example/id512.g");
G := DihedralGroup( IsPermGroup, 512 );
IdGroup512( G );
SetInfoLevel( InfoSCSCP, 0 );
IdGroup512( G );
# Working with remote objects
S := SymmetricGroup( 3 );
S1 := StoreAsRemoteObject( S, server, 26133 );
EvaluateBySCSCP( "WS_IdGroup", [ S1 ], server, 26133 );         
GeneratorsOfGroup( S );
List( [1..4], i -> EvaluateBySCSCP( "PointImages", [ S1, i ], server, 26133 ).object );
RetrieveRemoteObject( S1 );
UnbindRemoteObject( S1 );