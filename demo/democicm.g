LoadPackage("scscp");
#
# Connect to GAP SCSCP server 
#
SetInfoLevel( InfoSCSCP, 0 );
port:=26133;
server:="localhost";
PingSCSCPservice( server, 26133 );
EvaluateBySCSCP( "WS_Factorial", [ 10 ], server, 26133 );
EvaluateBySCSCP( "WS_IdGroup", [ SymmetricGroup(3) ], server, 26133 );
IdGroup(SymmetricGroup(3));
EvaluateBySCSCP( "GroupIdentificationService", 
                 [ [ (1,2,3), (2,3) ] ], server, 26133 ); 
IdGroup( Group( (1,2,3), (2,3) ) );
#
# Now increase InfoLevel to look at details
#
SetInfoLevel( InfoSCSCP, 4 );
PingSCSCPservice( server, 26133 );
EvaluateBySCSCP( "WS_Factorial", [ 10 ], server, 26133 );
EvaluateBySCSCP( "WS_IdGroup", [ SymmetricGroup(3) ], server, 26133 );
IdGroup(SymmetricGroup(3));
EvaluateBySCSCP( "GroupIdentificationService", 
                 [ [ (1,2,3), (2,3) ] ], server, 26133 ); 
IdGroup( Group( (1,2,3), (2,3) ) );
ReadPackage("scscp", "example/id512.g");
G := DihedralGroup( IsPermGroup, 512 );
IdGroup512( G );
SetInfoLevel( InfoSCSCP, 0 );
IdGroup512( G );
#
# Working with remote objects
#
EvaluateBySCSCP( "MathieuGroup", [ 24 ], 
                 server, 26133 : output:="cookie" );
M24 := last.object;    
EvaluateBySCSCP( "NrConjugacyClasses", [ M24 ], server, 26133 );      
EvaluateBySCSCP( "SylowSubgroup", [ M24, 2 ], 
                 server, 26133 : output:="cookie", debuglevel:=3 );    
P2 := last.object;
EvaluateBySCSCP( "Size", [ P2 ], server, 26133 );      
RetrieveRemoteObject( P2 );
UnbindRemoteObject( M24 );
#
# Private data formats
#
OMString(SL(2,5));
x:=SL(2,5);
s:=IO_PickleToString(x);
r:=EvaluateBySCSCP("IO_UnpickleStringAndPickleItBack",[s],"localhost",26133);
y:=IO_UnpickleFromString(r.object);
x=y;
