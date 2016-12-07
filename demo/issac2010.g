LoadPackage("scscp");
laptop   := "localhost";
steve    := "10.0.2.4";
peter    := "airbook.local";
scotland := "chrystal.mcs.st-andrews.ac.uk";
port     := 26133;
SetInfoLevel( InfoSCSCP, 0 );
EvaluateBySCSCP( "WS_IdGroup", [ Group( (1,2,3), (2,3) ) ], 
                 laptop, port ).object;
EvaluateBySCSCP( "GroupIdentificationService", [ [ (1,2,3), (2,3) ] ], 
                 steve, port ).object;
SetInfoLevel( InfoSCSCP, 3 );
EvaluateBySCSCP( "GroupIdentificationService", [ [ (1,2,3), (2,3) ] ], 
                 steve, port ).object;
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
OMString(x);
s:=IO_PickleToString(x);
x = IO_UnpickleFromString( 
      EvaluateBySCSCP( "IO_UnpickleStringAndPickleItBack", [ s ], 
                 laptop, port ).object );
EvaluateBySCSCP("sin", [0], scotland, port : cd:="transc1").object;
EvaluateBySCSCP("cos", 
  [ OMPlainString("<OMS cd=\"nums1\" name=\"pi\" />") ], 
                 scotland, port : cd:="transc1").object;
EvaluateBySCSCP( "ISS", [ "6*7" ], peter, 26133 ).object;
EvaluateBySCSCP( "ISS", [ "6*7" ], peter, 26133 : clever:=true ).object;
EvaluateBySCSCP( "InteractiveSCSCPserver", [ "6*7" ], peter, 26133 ).object;

