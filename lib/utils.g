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
BindGlobal( "DateISO8601", function()
local s, date;
s := IO_Popen("date", [ "+%y-%m-%d" ],"r");
date := IO_ReadLine(s);
IO_Close(s);
return Concatenation( "20", date{[ 1 .. Length(date)-1 ]} );
end);

BindGlobal( "CurrentTimestamp", function() 
local s, date;
s := IO_Popen("date", [ ], "r");
date := IO_ReadLine(s);
IO_Close(s);
return date{[ 1 .. Length(date)-1 ]};
end);

BindGlobal( "Hostname", function()
local s, hostname;
s := IO_Popen("hostname",[],"r");
hostname := IO_ReadLine(s);
IO_Close(s);
return hostname{[ 1 .. Length(hostname)-1 ]};;
end);

BindGlobal( "MemoryUsageByGAPinKbytes", function()
local s, mem;
s := IO_Popen( "ps", [ "-p", String( IO_getpid() ), "-o", "vsz" ], "r");
IO_ReadLine(s);
mem := IO_ReadLine(s);
IO_Close(s);
RemoveCharacters( mem, " \n" );
return Int(mem);
end);


BindGlobal( "LastReceivedCallID", function()
return OMTempVars.OMATTR.content[2].content[1].content; 
end);


BindGlobal( "IO_PickleToString", function( obj )
local rb, wb, s;
rb:="";
wb:="";
s:=IO_WrapFD(-1,rb,wb);
IO_Pickle( s, obj );
IO_Close( s );
return wb;
end);


BindGlobal( "IO_UnpickleFromString", function( str )
local rb, wb, s, r;
rb:=str;
wb:="";
s:=IO_WrapFD(-1,rb,wb);
r:=IO_Unpickle( s );
IO_Close( s );
return r;
end);
