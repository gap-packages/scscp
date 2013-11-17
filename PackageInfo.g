###########################################################################
##
#W PackageInfo.g            The SCSCP package           Alexander Konovalov
#W                                                             Steve Linton
##
###########################################################################

SetPackageInfo( rec(

PackageName := "SCSCP",
Subtitle := "Symbolic Computation Software Composability Protocol in GAP",
Version := "2.1.4",
Date := "17/11/2013",
##  <#GAPDoc Label="PKGVERSIONDATA">
##  <!ENTITY VERSION "2.1.4">
##  <!ENTITY RELEASEDATE "17 November 2013">
##  <!ENTITY RELEASEYEAR "2013">
##  <#/GAPDoc>

PackageWWWHome := "http://www.cs.st-andrews.ac.uk/~alexk/scscp/",

ArchiveURL := Concatenation( ~.PackageWWWHome, "scscp-", ~.Version ),
ArchiveFormats := ".tar.gz",

#TextFiles := ["init.g", ......],
BinaryFiles := ["demo/maple2gap.mw"],

Persons := [
  rec(
    LastName      := "Konovalov",
    FirstNames    := "Alexander",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "alexk@mcs.st-andrews.ac.uk",
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

Status := "accepted",
CommunicatedBy := "David Joyner (Annapolis)",
AcceptDate := "08/2010",
 
AbstractHTML := "This package implements the <a href=\"http://www.symbolic-computing.org/scscp\">Symbolic Computation Software Composability Protocol</a> for the GAP system.",

README_URL := 
  Concatenation( ~.PackageWWWHome, "README" ),
PackageInfoURL := 
  Concatenation( ~.PackageWWWHome, "PackageInfo.g" ),

PackageDoc := rec(
  BookName := "SCSCP",
  ArchiveURLSubset := ["doc"],
  HTMLStart := "doc/chap0.html",
  PDFFile := "doc/manual.pdf",
  SixFile := "doc/manual.six",
  LongTitle := "Symbolic Computation Software Composability Protocol",
  Autoload := true
),

Dependencies := rec(
  GAP := ">=4.7",
  NeededOtherPackages := [ ["GAPDoc", ">= 1.3"], 
                           ["openmath", ">= 11.0.0"],
                           ["IO", ">= 3.0"] ],
  SuggestedOtherPackages := [],
  ExternalConditions := []
),

AvailabilityTest := ReturnTrue,
Autoload := false,
TestFile := "tst/offline.tst",

Keywords := [ "SCSCP", "software composability", "interface", 
              "parallel computing", "OpenMath" ]
));
