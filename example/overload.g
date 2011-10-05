#############################################################################
#
# This file demonstrates how remote objects may be treated 
# in a uniform way with local objects
#
#############################################################################
 

#############################################################################
##
#M  \*( <x>, <y> )  . . . .  remote multiplication for two remote objects
##                           located on the same server 
## Example:
## gap> a:=StoreAsRemoteObject(6,"localhost",26133);
## < remote object scscp://localhost:26133/TEMPVarSCSCPRzYq748N >
## gap> b:=StoreAsRemoteObject(7,"localhost",26133);
## < remote object scscp://localhost:26133/TEMPVarSCSCPyYLzK5vW >
## gap> a*b;
## < remote object scscp://localhost:26133/TEMPVarSCSCPDalMjf4H >
## gap> RetrieveRemoteObject(last);
## 42
##
InstallOtherMethod( \*,
    "for two remote objects",
    IsIdenticalObj,
    [ IsRemoteObject, IsRemoteObject ],
    function( x, y )
    if x![2]<>y![2] or x![3]<>y![3] then
      Error("Remote objects located in different places\n");
    fi;
    return EvaluateBySCSCP("WS_Mult",[x,y],x![2],x![3]:output:="cookie").object;
    end); 