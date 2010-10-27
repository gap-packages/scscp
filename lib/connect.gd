#############################################################################
##
#W process.gd               The SCSCP package             Alexander Konovalov
#W                                                               Steve Linton
##
#H $Id: process.gd 3326 2009-09-30 12:49:52Z alexk $
##
#############################################################################

DeclareCategory( "IsSCSCPconnection", IsObject );
DeclareCategoryCollections( "IsSCSCPconnection" );

DeclareGlobalFunction ( "NewSCSCPconnection" );

DeclareGlobalFunction ( "CloseSCSCPconnection" );