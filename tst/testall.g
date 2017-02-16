############################################################################
#
# This is an extended test file for the SCSCP package.
# It is not listed in PackageInfo.g because it requires starting two SCSCP 
# servers at ports 26133 and 26134 in advance. Also, some of the test files 
# show technical details like random call identfiers - these discrepancies
# are safe to ignore.
#

LoadPackage( "scscp" );

TestMyPackage := function( pkgname, testfiles )
local pkgdir, ff, fn;
LoadPackage( pkgname );
pkgdir := DirectoriesPackageLibrary( pkgname, "tst" );

for ff in testfiles do
  fn := Filename( pkgdir, ff );
  Print("#I  Testing ", fn, "\n");
  Test( fn, rec(compareFunction := "uptowhitespace") );
od;  
end;

# Arrange testfiles in the order in which they should run

if PingSCSCPservice( "localhost", 26133 ) = true then
    TestMyPackage( "scscp", [ "scscp04.tst", "scscp05.tst", "scscp06.tst", "scscp07.tst", 
                   "scscp09.tst", "scscp.tst", "offline.tst" ] );
else
  Print("No SCSCP server at port 26133 - test terminated.\n");
fi;

if PingSCSCPservice( "localhost", 26134 ) = true then
  TestMyPackage( "scscp", [ "scscp08.tst" ] );
else
  Print("No SCSCP server at ports 26134 - test terminated.\n");
fi;

                   

