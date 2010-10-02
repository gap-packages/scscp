#############################################################################
#
# This file demonstrates how remote objects may be treated 
# in a uniform way with local objects
#
# $Id$
#
#############################################################################
 

#############################################################################
##
#M  \*( <x>, <y> )  . . . .  remote multiplication for two remote objects
##                           located on the same server 
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