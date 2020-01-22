###########################################################################
##
#W PackageInfo.g            The SCSCP package           Alexander Konovalov
#W                                                             Steve Linton
##
###########################################################################

SetPackageInfo( rec(

PackageName := "SCSCP",
Subtitle := "Symbolic Computation Software Composability Protocol in GAP",
Version := "2.3.1",
Date := "22/01/2020", # dd/mm/yyyy format
License := "GPL-2.0-or-later",
##  <#GAPDoc Label="PKGVERSIONDATA">
##  <!ENTITY VERSION "2.3.1">
##  <!ENTITY RELEASEDATE "22 January 2020">
##  <!ENTITY RELEASEYEAR "2020">
##  <#/GAPDoc>

SourceRepository := rec(
    Type := "git",
    URL := Concatenation( "https://github.com/gap-packages/", LowercaseString(~.PackageName) ),
),
IssueTrackerURL := Concatenation( ~.SourceRepository.URL, "/issues" ),
PackageWWWHome  := Concatenation( "https://gap-packages.github.io/", LowercaseString(~.PackageName) ),
README_URL      := Concatenation( ~.PackageWWWHome, "/README.md" ),
PackageInfoURL  := Concatenation( ~.PackageWWWHome, "/PackageInfo.g" ),
ArchiveURL      := Concatenation( ~.SourceRepository.URL,
                                 "/releases/download/v", ~.Version,
                                 "/", ~.PackageName, "-", ~.Version ),
ArchiveFormats := ".tar.gz",

#TextFiles := ["init.g", ......],
BinaryFiles := ["demo/maple2gap.mw"],

Persons := [
  rec(
    LastName      := "Konovalov",
    FirstNames    := "Alexander",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "alexander.konovalov@st-andrews.ac.uk",
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
    Email         := "sal@cs.st-and.ac.uk",
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
 
AbstractHTML := "This package implements the <a href=\"https://www.openmath.org/standard/scscp/\">Symbolic Computation Software Composability Protocol</a> for the GAP system.",

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
  GAP := ">=4.9",
  NeededOtherPackages := [ ["GAPDoc", ">= 1.5"], 
                           ["openmath", ">= 11.4.1"],
                           ["IO", ">= 4.4"] ],
  SuggestedOtherPackages := [],
  ExternalConditions := []
),

AvailabilityTest := ReturnTrue,
Autoload := false,
TestFile := "tst/offline.tst",

Keywords := [ "SCSCP", "software composability", "interface", 
              "parallel computing", "OpenMath" ]
));
