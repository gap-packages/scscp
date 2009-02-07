#############################################################################
##
#W utilities.g              The SCSCP package             Alexander Konovalov
#W                                                               Steve Linton
##
#H $Id$
##
#############################################################################

#############################################################################
#
# This function returns current date in ISO-8601 format (YYYY-MM-DD)
#
DateISO8601 := function()
local date, out, str;
date:="";
out:="20";
str := InputOutputLocalProcess( 
         DirectoryTemporary(),
         Filename(DirectoriesSystemPrograms(), "date"), 
         [ "+%y-%m-%d" ]);
date := ReadLine( str );
CloseStream( str );
Append( out, date{[ 1 .. Length(date)-1 ]} );
return out;
end;


Hostname := function()
local hostname, str;
hostname:="";
str := InputOutputLocalProcess( 
         DirectoryTemporary(),
         Filename(DirectoriesSystemPrograms(), "hostname"), 
         [ ]);
hostname := ReadLine( str );
CloseStream( str );
return hostname{[ 1 .. Length(hostname)-1 ]};
end;
