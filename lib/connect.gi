###########################################################################
##
#W process.gi              The SCSCP package             Olexandr Konovalov
#W                                                             Steve Linton
##
###########################################################################

DeclareRepresentation( "IsSCSCPconnectionRep", 
                       IsPositionalObjectRep,
                       [ 1, 2 ] );
                       
SCSCPconnectionsFamily := NewFamily( "SCSCPconnectionsFamily(...)", 
                            IsSCSCPconnection );
                       
SCSCPconnectionDefaultType := NewType( SCSCPconnectionsFamily, 
                               IsSCSCPconnectionRep and IsSCSCPconnection);


###########################################################################
##
#M  ViewObj( <SCSCPconnection> )
##
InstallMethod( ViewObj, "for SCSCP connection",
[ IsSCSCPconnectionRep and IsSCSCPconnection ],
function( connection )
    local stream, pid;
    stream := connection![1];
    pid := connection![2];
    Print("< ");
    if IsClosedStream(stream) then
        Print("closed ");
    fi;
    Print("connection to ",stream![2],":",stream![3][1], " session_id=", pid, " >");
end);


###########################################################################
##
#M  PrintObj( <process> )
##
InstallMethod( PrintObj, "for SCSCP connection",
[ IsSCSCPconnectionRep and IsSCSCPconnection ],
function( connection )
    local stream, pid;
    stream := connection![1];
    pid := connection![2];
    Print("< ");
    if IsClosedStream(stream) then
        Print("closed ");
    fi;
    Print("connection to ",stream![2],":",stream![3][1], " session_id=", pid, " >");
end);


###########################################################################
##
##  NewSCSCPconnection
##
InstallGlobalFunction( NewSCSCPconnection, function( hostname, port )
local tcpstream, session_id, pos1, pid;
tcpstream:=InputOutputTCPStream( hostname, port );
session_id := StartSCSCPsession( tcpstream );
return Objectify( SCSCPconnectionDefaultType, [ tcpstream, session_id ] );
end);


###########################################################################
##
##  CloseSCSCPconnection
##
InstallGlobalFunction( CloseSCSCPconnection, function( connection )
CloseStream( connection![1]);
end);


###########################################################################
##
#E 
##
