#############################################################################
##
#W process.gd               The SCSCP package             Alexander Konovalov
#W                                                               Steve Linton
##
#H $Id$
##
#############################################################################

DeclareCategory( "IsProcess", IsObject );
DeclareCategoryCollections( "IsProcess" );

DeclareGlobalFunction ( "NewProcess" );

DeclareGlobalFunction ( "CompleteProcess" );

DeclareGlobalFunction ( "TerminateProcess" );

DeclareGlobalFunction ( "SynchronizeProcesses" );

DeclareGlobalFunction ( "FirstProcess" );

DeclareGlobalFunction ( "FirstTrueProcess" );