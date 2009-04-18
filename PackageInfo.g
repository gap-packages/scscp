#############################################################################
##
#W PackageInfo.g            The SCSCP package             Alexander Konovalov
#W                                                               Steve Linton
##
#H $Id$
##
#############################################################################

SetPackageInfo( rec(

PackageName := "SCSCP",
Subtitle := "Symbolic Computation Software Composability Protocol in GAP",
Version := "1.1",
Date := "18/04/2009",
ArchiveURL := Concatenation( 
	[ "http://www.cs.st-andrews.ac.uk/~alexk/scscp/scscp-" , ~.Version ] ),
ArchiveFormats := ".tar.gz .tar.bz2",

#TextFiles := ["init.g", ......],
#BinaryFiles := ["doc/manual.dvi", ......],

Persons := [
  rec(
    LastName      := "Konovalov",
    FirstNames    := "Alexander",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "konovalov@member.ams.org",
    WWWHome       := "http://www.cs.st-andrews.ac.uk/~alexk/",
    PostalAddress := Concatenation( [
                     "School of Computer Science\n",
                     "University of St Andrews\n",
                     "Jack Cole Building, North Haugh,\n",
                     "St Andrews, Fife, KY16 9SX, Scotland" ] ),
    Place         := "St Andrews",
    Institution   := "University of St Andrews"
     ),
  rec(
    LastName      := "Linton",
    FirstNames    := "Steve",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "sal@dcs.st-and.ac.uk",
    WWWHome       := "http://www.cs.st-and.ac.uk/~sal/",
    PostalAddress := Concatenation( [
                     "School of Computer Science\n",
                     "University of St Andrews\n",
                     "Jack Cole Building, North Haugh,\n",
                     "St Andrews, Fife, KY16 9SX, Scotland" ] ),
    Place         := "St Andrews",
    Institution   := "University of St Andrews"
     )
],

Status := "deposited",
#CommunicatedBy := "",
#AcceptDate := "",

README_URL := "http://www.cs.st-andrews.ac.uk/~alexk/scscp/README.scscp",
PackageInfoURL := "http://www.cs.st-andrews.ac.uk/~alexk/scscp/PackageInfo.g",
AbstractHTML := "The package implements the <a href=\"http://www.symbolic-computation.org/scscp\">Symbolic Computation Software Composability Protocol</a> for the GAP system.",
PackageWWWHome := "http://www.cs.st-andrews.ac.uk/~alexk/scscp.htm",
                  
PackageDoc := rec(
  BookName := "SCSCP",
  ArchiveURLSubset := ["doc"],
  HTMLStart := "doc/chap0.html",
  PDFFile := "doc/manual.pdf",
  SixFile := "doc/manual.six",
  LongTitle := "Symbolic Computation Software Composability Protocol",
  Autoload := false
),

Dependencies := rec(
  GAP := ">=4.4",
  NeededOtherPackages := [ ["GAPDoc", ">= 1.2"], 
                           ["IO", ">= 3.0"],
                           ["openmath", ">= 10.0.0"] ],
  SuggestedOtherPackages := [],
  ExternalConditions := []
),

AvailabilityTest := ReturnTrue,
Autoload := false,
#TestFile := "tst/testall.g",

Keywords := [ "SCSCP", "software composability", "interface", "parallel computing", "OpenMath" ]
));
