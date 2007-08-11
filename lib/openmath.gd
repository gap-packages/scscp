#############################################################################
##
#W openmath.gd              The SCSCP package             Alexander Konovalov
#W                                                               Steve Linton
##
#H $Id$
##
#############################################################################


#############################################################################
##
##  InfoSCSCP
##  
##  We declare new Info class for our package. The default level is equal to
##  one and mean that only some basic information messages will be printed.
##  To change the Infolevel to k, use the command SetInfoLevel(InfoSCSCP,k)
##
DeclareInfoClass("InfoSCSCP");

DeclareGlobalFunction( "SCSCPprocLookup" );

DeclareGlobalFunction( "OMgapRPC" );

DeclareGlobalFunction( "OMGetObjectWithAttributes" );

DeclareGlobalFunction( "OMgetObjectXMLTreeWithAttributes" );

DeclareGlobalFunction( "OMPutProcedureCall" );

DeclareGlobalFunction( "OMPutProcedureCompleted" );

DeclareGlobalFunction( "OMPutError" );

DeclareGlobalFunction( "OMPutProcedureTerminated" );