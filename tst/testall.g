############################################################################
#
# This is an extended test file for the SCSCP package.
# It is not listed in PackageInfo.g because it requires starting two SCSCP 
# servers in advance. Also, some of the test files show technical details 
# like random call identfiers - these discrepancies are safe to ignore.
#

TestMyPackage := function( pkgname )
local pkgdir, testfiles, ff, fn;
LoadPackage( pkgname );
pkgdir := DirectoriesPackageLibrary( pkgname, "tst" );

# Arrange testfiles as required
testfiles := [ "scscp04.tst", "scscp05.tst", "scscp06.tst", "scscp07.tst", 
               "scscp08.tst", "scscp09.tst", "scscp.tst", "offline.tst" ];

for ff in testfiles do
  fn := Filename( pkgdir, ff );
  Print("#I  Testing ", fn, "\n");
  Test( fn, rec(compareFunction := "uptowhitespace") );
od;  
end;

LoadPackage( "scscp" );
ports:=[ 26133 .. 26134 ];
if ForAll( ports, i -> PingSCSCPservice( "localhost", i ) ) then
  TestMyPackage( "scscp" );
else
  Print("Not all required SCSCP servers available - test terminated.\n");
fi;