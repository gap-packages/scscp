#############################################################################
##
#W utilities.g              The SCSCP package             Alexander Konovalov
#W                                                               Steve Linton
##
#H $Id: errors.g 264 2008-02-21 16:50:06Z alexk $
##
#############################################################################

BIND_GLOBAL( "RandomString",
    function( n )
    local symbols, i;
    symbols := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890";
    return List( [1..n], i -> Random(symbols) );
    end);