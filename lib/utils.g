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
local s, date;
s := IO_Popen("date", [ "+%y-%m-%d" ],"r");
date := IO_ReadLine(s);
IO_Close(s);
return Concatenation( "20", date{[ 1 .. Length(date)-1 ]} );
end;


Hostname := function()
local s, hostname;
s := IO_Popen("hostname",[],"r");
hostname := IO_ReadLine(s);
IO_Close(s);
return hostname{[ 1 .. Length(hostname)-1 ]};;
end;


IO_PickleToString:=function( obj )
local rb, wb, s;
rb:="";
wb:="";
s:=IO_WrapFD(-1,rb,wb);
IO_Pickle( s, obj );
IO_Close( s );
return wb;
end;


IO_UnpickleFromString:=function( str )
local rb, wb, s, r;
rb:=str;
wb:="";
s:=IO_WrapFD(-1,rb,wb);
r:=IO_Unpickle( s );
IO_Close( s );
return r;
end;
