############################################################################
#
# This is an extended test file for the SCSCP package.
# It is not listed in PackageInfo.g because it requires starting two SCSCP 
# servers in advance. Also, some of the test files show technical details 
# like random call identfiers - these discrepancies are safe to ignore.
#
LoadPackage( "scscp" );
scscpdir := DirectoriesPackageLibrary( "scscp", "tst" );
ports:=[ 26133 .. 26134 ];

if ForAll( ports, i -> PingSCSCPservice( "localhost", i ) ) then

Print("*****************************************************\n" );        
Print("*** TESTING ", Filename( scscpdir, "scscp04.tst" ), "\n" );
ReadTest( Filename( scscpdir, "scscp04.tst" ) );
Print("*****************************************************\n" );        
Print("*** TESTING ", Filename( scscpdir, "scscp05.tst" ), "\n" );
ReadTest( Filename( scscpdir, "scscp05.tst" ) );
Print("*****************************************************\n" );        
Print("*** TESTING ", Filename( scscpdir, "scscp06.tst" ), "\n" );
ReadTest( Filename( scscpdir, "scscp06.tst" ) );
Print("*****************************************************\n" );        
Print("*** TESTING ", Filename( scscpdir, "scscp07.tst" ), "\n" );
ReadTest( Filename( scscpdir, "scscp07.tst" ) );
Print("*****************************************************\n" );        
Print("*** TESTING ", Filename( scscpdir, "scscp08.tst" ), "\n" );
ReadTest( Filename( scscpdir, "scscp08.tst" ) );
Print("*****************************************************\n" );        
Print("*** TESTING ", Filename( scscpdir, "scscp09.tst" ), "\n" );
ReadTest( Filename( scscpdir, "scscp09.tst" ) );
Print("*****************************************************\n" );        
Print("*** TESTING ", Filename( scscpdir, "scscp.tst" ), "\n" );
ReadTest( Filename( scscpdir, "scscp.tst" ) );
Print("*****************************************************\n" );        
Print("*** TESTING ", Filename( scscpdir, "offline.tst" ), "\n" );
ReadTest( Filename( scscpdir, "offline.tst" ) );
Print("*** TESTING FINISHED\n");
Print("*****************************************************\n" );        

else

Print("Not all required SCSCP servers available - test terminated.\n");

fi;