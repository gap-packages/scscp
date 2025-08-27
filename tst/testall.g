############################################################################
#
# This is a test file for the SCSCP package.
#
LoadPackage( "scscp" );
LoadPackage( "smallgrp" );

# First check that SCSCP servers are available
if PingSCSCPservice( "localhost", 26133 ) = fail then
  Print("No SCSCP server at port 26133 - test terminated.\n");
  FORCE_QUIT_GAP(1);
fi;

if PingSCSCPservice( "localhost", 26134 ) = fail then
  Print("No SCSCP server at port 26134 - test terminated.\n");
  FORCE_QUIT_GAP(1);
fi;

# Run tests which include technical details like random call
# identifiers and need manual inspection
TestDirectory(DirectoriesPackageLibrary( "scscp", "tst" ),
  rec(exitGAP     := false,
      exclude     := [ "scscp.tst", "offline.tst", "xmltree.tst" ],
      testOptions := rec(compareFunction := "uptowhitespace") ) );

# Run test files which should have no diffs
TestDirectory(DirectoriesPackageLibrary( "scscp", "tst" ),
  rec(exitGAP     := true,
      exclude     := [ "scscp04.tst", "scscp05.tst", "scscp06.tst", "scscp07.tst", "scscp08.tst", "scscp09.tst" ],
      testOptions := rec(compareFunction := "uptowhitespace") ) );

FORCE_QUIT_GAP(1); # if we ever get here, there was an error
