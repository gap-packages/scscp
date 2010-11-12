#############################################################################
##
#W buildman.g               The SCSCP package             Alexander Konovalov
#W                                                               Steve Linton
##
#H $Id$
##
#############################################################################

#############################################################################
##
##  SCSCPBuildManual()
##
BindGlobal( "SCSCPBuildManual", function()
local path, main, files, bookname;
path:=Concatenation(
               GAPInfo.PackagesInfo.("scscp")[1].InstallationPath,"/doc/");
main:="manual.xml";
files:=[];
bookname:="scscp";
MakeGAPDocDoc( path, main, files, bookname );  
end);


#############################################################################
##
##  SCSCPBuildManualHTML()
##
BindGlobal( "SCSCPBuildManualHTML", function()
local path, main, files, str, r, h;
path:=Concatenation(
               GAPInfo.PackagesInfo.("scscp")[1].InstallationPath,"/doc/");
main:="manual.xml";
files:=[];
str:=ComposedXMLString( path, main, files );
r:=ParseTreeXMLString( str );
CheckAndCleanGapDocTree( r );
h:=GAPDoc2HTML( r, path );
GAPDoc2HTMLPrintHTMLFiles( h, path );
end);


#############################################################################
##
#E
##