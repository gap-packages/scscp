LoadPackage("scscp");
server:="scscp-docker.cloudapp.net";
port := 26133;

# VARIATIONS OF GROUP IDENTICATION

SetInfoLevel( InfoSCSCP, 0 );
G := Group( (1,2,3), (2,3) );
IdGroup( G );
EvaluateBySCSCP( "IdGroup", [ G ], server, port ).object;
EvaluateBySCSCP( "GroupIdentificationService", [ [ (1,2,3), (2,3) ] ], 
                 server, port ).object;

SetInfoLevel( InfoSCSCP, 3 );
EvaluateBySCSCP( "GroupIdentificationService", [ [ (1,2,3), (2,3) ] ], 
                 server, port ).object;

# ID FOR GROUPS OF ORDER 512
                 
IdGroup512 :=function ( G, server )
    local  code, result;
    if Size( G ) <> 512  then
        Error( "G must be a group of order 512 !!!\n" );
    fi;
    code := CodePcGroup( G );
    result := EvaluateBySCSCP( "IdGroup512ByCode", [ code ], server, 26133 );
    return result.object;
end;

G := DihedralGroup( IsPermGroup, 512 );
IdGroup512( G, server );
SetInfoLevel( InfoSCSCP, 0 );
IdGroup512( G, server );

# REMOTE OBJECTS

M24 := EvaluateBySCSCP( "MathieuGroup", [ 24 ], 
                 server, port : output:="cookie" ).object;
EvaluateBySCSCP( "NrConjugacyClasses", [ M24 ], server, port );  
SetInfoLevel( InfoSCSCP, 3 );    
P2 := EvaluateBySCSCP( "SylowSubgroup", [ M24, 2 ], 
                 server, port : output:="cookie" ).object; 
SetInfoLevel( InfoSCSCP, 0 );   
# RetrieveRemoteObject( P2 );
# UnbindRemoteObject( M24 );

# BINARY OPENMATH

x:=SL(2,2);
l:=OMString(x);
Length(l);
SetInfoLevel( InfoSCSCP, 4 ); 
IN_SCSCP_BINARY_MODE:=true;
x = EvaluateBySCSCP("Identity",[x],server,port).object;

# FINALLY, USING PICKLING FROM IO PACKAGE

IN_SCSCP_BINARY_MODE:=false;

SetInfoLevel( InfoSCSCP, 0 ); 
s:=IO_PickleToString(x);
x = IO_UnpickleFromString( EvaluateBySCSCP( 
  "IO_UnpickleStringAndPickleItBack", [ s ], server, port ).object );
x := [ Z(3)^0, Z(3), 0*Z(3) ];
OMString(x);
for i in [ 4 .. 5000 ] do x[i] := i*Z(3)^0; od;  
Length(x);

IN_SCSCP_BINARY_MODE:=false;
x = EvaluateBySCSCP("Identity",[x],server,port).object;
time;

IN_SCSCP_BINARY_MODE:=true;
x = EvaluateBySCSCP("Identity",[x],server,port).object;
time;

IN_SCSCP_BINARY_MODE:=false;
x = IO_UnpickleFromString( EvaluateBySCSCP( "IO_UnpickleStringAndPickleItBack",
    [ IO_PickleToString(x) ], server, port ).object );
time;

IN_SCSCP_BINARY_MODE:=true;
x = IO_UnpickleFromString( EvaluateBySCSCP( "IO_UnpickleStringAndPickleItBack", 
    [ IO_PickleToString(x) ], server, port ).object );
time;    

IN_SCSCP_BINARY_MODE:=false;
