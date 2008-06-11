#############################################################################
##
#W utilities.g              The SCSCP package             Alexander Konovalov
#W                                                               Steve Linton
##
#H $Id:$
##
#############################################################################

#############################################################################
#
# This function generates a random string of the length n
#
BIND_GLOBAL( "RandomString",
    function( n )
    local symbols, i;
    symbols := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890";
    return List( [1..n], i -> Random(rs1,symbols) );
    end);