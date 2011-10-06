###########################################################################
##
#W buildman.g               The SCSCP package           Alexander Konovalov
#W                                                             Steve Linton
##
###########################################################################

ExtractManualExamples:=function( pkgname, main, files )
local path, tst, i, s, name, output;
path:=Directory( 
        Concatenation(PackageInfo(pkgname)[1].InstallationPath, "/doc") );
Print("===============================================================\n");
Print("Extracting manual examples for ", pkgname, " package\n" );
Print("===============================================================\n");
tst:=ManualExamples( path, main, files, "Chapter" );
for i in [ 1 .. Length(tst) ] do 
  Print( "Processing '", pkgname, 
         "' chapter number ", i, " of ", Length(tst), "\c" );
  if Length( tst[i] ) > 0 then
    s := String(i);
    if Length(s)=1 then 
      # works for <100 chapters
      s:=Concatenation("0",s); 
    fi;
    name := Filename( 
              Directory( 
                Concatenation( PackageInfo(pkgname)[1].InstallationPath, 
                               "/tst" ) ), 
                Concatenation( pkgname, s, ".tst" ) );
    output := OutputTextFile( name, false ); # to empty the file first
    SetPrintFormattingStatus( output, false ); # to avoid line breaks
    PrintTo( output, tst[i] );
    CloseStream(output);
    # one superfluous check
    if tst[i] <> StringFile( name ) then
      Error("Saved file does not match original examples string!!!\n");  
    else
      Print(" - OK! \n" );
    fi;
  else
    Print(" - no examples to save! \n" );    
  fi;  
od;
Print("===============================================================\n");
end;

###########################################################################

SCSCPMANUALFILES:=[ 
"../PackageInfo.g",
"../lib/openmath.gd",
"../lib/process.gd",
"../lib/remote.gd",
"../lib/scscp.gd",
"../lib/utils.g",
"../lib/xstream.gd",
"../par/parlist.g",
"../tracing/tracing.g",
];

###########################################################################
##
##  SCSCPBuildManual()
##
SCSCPBuildManual := function()
local path, main, files, bookname;
path:=Concatenation(
               GAPInfo.PackagesInfo.("scscp")[1].InstallationPath,"/doc/");
main:="manual.xml";
bookname:="scscp";
MakeGAPDocDoc( path, main, SCSCPMANUALFILES, bookname );  
CopyHTMLStyleFiles( path );
GAPDocManualLab( "scscp" );; 
ExtractManualExamples( "scscp", main, SCSCPMANUALFILES);
end;


###########################################################################
##
##  SCSCPBuildManualForGAP44()
##
SCSCPBuildManualForGAP44 := function()
local path, main, files, bookname;
path:=Concatenation(
               GAPInfo.PackagesInfo.("scscp")[1].InstallationPath,"/doc/");
main:="manual.xml";
bookname:="scscp";
MakeGAPDocDoc( path, main, SCSCPMANUALFILES, bookname );  
GAPDocManualLab( "scscp" );; 
ExtractManualExamples( "scscp", main, SCSCPMANUALFILES);
end;


###########################################################################
##
##  SCSCPBuildManualHTML()
##
SCSCPBuildManualHTML := function()
local path, main, files, str, r, h;
path:=Concatenation(
               GAPInfo.PackagesInfo.("scscp")[1].InstallationPath,"/doc/");
main:="manual.xml";
str:=ComposedXMLString( path, main, SCSCPMANUALFILES );
r:=ParseTreeXMLString( str );
CheckAndCleanGapDocTree( r );
h:=GAPDoc2HTML( r, path );
GAPDoc2HTMLPrintHTMLFiles( h, path );
end;


###########################################################################

SCSCPBuildManual();

###########################################################################
##
#E
##