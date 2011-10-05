#############################################################################
##
#W scscp.gd                 The SCSCP package             Alexander Konovalov
#W                                                               Steve Linton
##
#############################################################################


#############################################################################
##
##  InfoSCSCP
##  InfoMasterWorker
##  
##  We declare two new Info classes for our packages, one for the SCSCP 
##  communication and another for the MasterWorker skeleton, since the
##  user may want to use them in different combinations. To change the 
##  InfoLevel to k, use the command in the format SetInfoLevel(Info...,k)
##
DeclareInfoClass("InfoSCSCP");
DeclareInfoClass("InfoMasterWorker");


#############################################################################
#
# Functions to support symbols from scscp2 CD
#
DeclareGlobalFunction( "SCSCP_RETRIEVE" );
DeclareGlobalFunction( "SCSCP_STORE_SESSION" );
DeclareGlobalFunction( "SCSCP_STORE_PERSISTENT" );
DeclareGlobalFunction( "SCSCP_UNBIND" );
DeclareGlobalFunction( "SCSCP_GET_ALLOWED_HEADS" );
DeclareGlobalFunction( "SCSCP_IS_ALLOWED_HEAD" );
DeclareGlobalFunction( "SCSCP_GET_SERVICE_DESCRIPTION" );
DeclareGlobalFunction( "SCSCP_GET_TRANSIENT_CD" );
DeclareGlobalFunction( "SCSCP_GET_SIGNATURE" );


#############################################################################
#
# Other global functions
#
DeclareGlobalFunction( "InstallSCSCPprocedure" );
DeclareGlobalFunction( "RunSCSCPserver" );
DeclareGlobalFunction( "PingSCSCPservice" );
DeclareGlobalFunction( "PingStatistic" );
DeclareGlobalFunction( "StartSCSCPsession" );
DeclareGlobalFunction( "EvaluateBySCSCP" );
DeclareGlobalFunction( "ParQuickWithSCSCP" );
DeclareGlobalFunction( "ParListWithSCSCP" );


#############################################################################
#
# Special procedures
#
DeclareGlobalFunction( "GetAllowedHeads" );
DeclareGlobalFunction( "GetServiceDescription" );
DeclareGlobalFunction( "GetSignature" );
DeclareGlobalFunction( "GetTransientCD" );
DeclareGlobalFunction( "IsAllowedHead" );