LoadPackage("scscp");
laptop   := "localhost";
scotland := "chrystal.mcs.st-andrews.ac.uk";
port     := 26133;
SetInfoLevel( InfoSCSCP, 0 );
EvaluateBySCSCP( "ChangeInfoLevel", [4], laptop, port );

G := Group( (1,2,3), (2,3) );
IdGroup( G );
EvaluateBySCSCP( "WS_IdGroup", [ G ], scotland, port ).object;
EvaluateBySCSCP( "GroupIdentificationService", [ [ (1,2,3), (2,3) ] ], 
                 scotland, port ).object;
SetInfoLevel( InfoSCSCP, 3 );
EvaluateBySCSCP( "GroupIdentificationService", [ [ (1,2,3), (2,3) ] ], 
                 scotland, port ).object;
ReadPackage("scscp", "example/id512.g");
G := DihedralGroup( IsPermGroup, 512 );
IdGroup512( G );
SetInfoLevel( InfoSCSCP, 0 );
IdGroup512( G );
M24 := EvaluateBySCSCP( "MathieuGroup", [ 24 ], 
                 laptop, port : output:="cookie" ).object;
EvaluateBySCSCP( "NrConjugacyClasses", [ M24 ], laptop, port );  
SetInfoLevel( InfoSCSCP, 3 );    
P2 := EvaluateBySCSCP( "SylowSubgroup", [ M24, 2 ], 
                 laptop, port : output:="cookie" ).object; 
SetInfoLevel( InfoSCSCP, 0 );       
RetrieveRemoteObject( P2 );
UnbindRemoteObject( M24 );

x:=SL(2,2);
StoreAsRemoteObject( x, laptop, port );
l:=OMString(x);
Length(l);
SetInfoLevel( InfoSCSCP, 4 ); 
IN_SCSCP_BINARY_MODE:=true;
x = EvaluateBySCSCP("Identity",[x],"localhost",port).object;
IN_SCSCP_BINARY_MODE:=false;
SetInfoLevel( InfoSCSCP, 0 ); 
EvaluateBySCSCP( "ChangeInfoLevel", [0], laptop, port );
s:=IO_PickleToString(x);
x = IO_UnpickleFromString( 
      EvaluateBySCSCP( "IO_UnpickleStringAndPickleItBack", [ s ], 
                 laptop, port ).object );

x := [ Z(3)^0, Z(3), 0*Z(3) ];
OMString(x);
for i in [ 4 .. 10000 ] do
  x[i] := i*Z(3)^0;
od;  
Length(x);

IN_SCSCP_BINARY_MODE:=false;
x = EvaluateBySCSCP("Identity",[x],"localhost",port).object;

IN_SCSCP_BINARY_MODE:=true;
x = EvaluateBySCSCP("Identity",[x],"localhost",port).object;

IN_SCSCP_BINARY_MODE:=false;
x = IO_UnpickleFromString( EvaluateBySCSCP( "IO_UnpickleStringAndPickleItBack",
    [ IO_PickleToString(x) ], "localhost", port ).object );

IN_SCSCP_BINARY_MODE:=true;
x = IO_UnpickleFromString( EvaluateBySCSCP( "IO_UnpickleStringAndPickleItBack", 
    [ IO_PickleToString(x) ], "localhost", port ).object );

LoadPackage("cvec");
x:=CVec( x, GF(3) );

IN_SCSCP_BINARY_MODE:=false;
x = IO_UnpickleFromString( EvaluateBySCSCP( "IO_UnpickleStringAndPickleItBack",
    [ IO_PickleToString(x) ], "localhost", port ).object );

IN_SCSCP_BINARY_MODE:=true;
x = IO_UnpickleFromString( EvaluateBySCSCP( "IO_UnpickleStringAndPickleItBack", 
    [ IO_PickleToString(x) ], "localhost", port ).object );

IN_SCSCP_BINARY_MODE:=false;
ReadPackage("scscp", "example/overload.g");
a := StoreAsRemoteObject( 6, laptop, port );
b := StoreAsRemoteObject( 7, laptop, port );
c := a*b;
RetrieveRemoteObject( c );
                
EvaluateBySCSCP( "ChangeInfoLevel", [4], laptop, port );