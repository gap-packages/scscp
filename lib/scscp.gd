#############################################################################
##
#W scscp.gd                 The SCSCP package             Alexander Konovalov
#W                                                               Steve Linton
##
#H $Id$
##
#############################################################################

#############################################################################
#
# Functions to support symbols from scscp2 CD
#
DeclareGlobalFunction( "SCSCP_RETRIEVE" );
DeclareGlobalFunction( "SCSCP_STORE" );
DeclareGlobalFunction( "SCSCP_UNBIND" );
DeclareGlobalFunction( "SCSCP_GET_ALLOWED_HEADS" );

#############################################################################
#
# Other global functions
#
DeclareGlobalFunction( "InstallSCSCPprocedure" );
DeclareGlobalFunction( "RunSCSCPserver" );
DeclareGlobalFunction( "PingWebService" );
DeclareGlobalFunction( "PingStatistic" );
DeclareGlobalFunction( "EvaluateBySCSCP" );
DeclareGlobalFunction( "ParEvaluateBySCSCP" );