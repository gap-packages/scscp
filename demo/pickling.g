# HOW TO GET THE BEST PERFORMANCE WITH SCSCP ?
# Source for the demo of binary OpenMath encoding, private data formats
# and SCSCP connections. For timing, remember to switch off info messages.
#
LoadPackage("scscp");
SetInfoLevel(InfoSCSCP,0);
SetInfoLevel(InfoMasterWorker,0);
#
# IO package provides a function IO_gettimeofday which returns a record 
# with components tv_sec and tv_usec corresponding to the time elapsed 
# since 1.1.1970, 0:00 GMT. The component tv_sec contains the number of 
# full seconds and the number tv_usec the additional microseconds.
#
# Walltime uses two such records to return the duration of time interval
# between them in microseconds
# 
Walltime:=function(t1,t2) return 1000000*(t2.tv_sec-t1.tv_sec)+t2.tv_usec-t1.tv_usec; end;

# TimeRoundtrip returns the walltime used to send the object to the SCSCP
# server and get it back.

TimeRoundtrip:=function( x )
local curtime1, curtime2, res;
curtime1:=IO_gettimeofday();
res:=EvaluateBySCSCP( "Identity", [x],"localhost",26133).object;
curtime2:=IO_gettimeofday();
if res <> x then
  Error("Object corrupted after roundtrip!");
fi;
return Walltime(curtime1,curtime2);
end;

# List of 10^5 small integers
x := List([1..100000],i->Random(Integers));;
IN_SCSCP_BINARY_MODE:=false;; t1:=TimeRoundtrip( x );
IN_SCSCP_BINARY_MODE:=true;; t2:=TimeRoundtrip( x );
Float(t1/t2);

# String with 10^6 characters
y:=ListWithIdenticalEntries(1000000,'a');;
IN_SCSCP_BINARY_MODE:=false;; t1:=TimeRoundtrip( y );
IN_SCSCP_BINARY_MODE:=true;; t2:=TimeRoundtrip( y );
Float(t1/t2);

# List of 10^4 elements of GF(3)
z := ListWithIdenticalEntries(10000,Z(3)^0);;
IN_SCSCP_BINARY_MODE:=false;; t1:=TimeRoundtrip( z );
IN_SCSCP_BINARY_MODE:=true;; t2:=TimeRoundtrip( z );
Float(t1/t2);

# Compressed vector of 10^4 elements of GF(3)
LoadPackage("cvec");
w:=CVec(ListWithIdenticalEntries(10000,Z(3)^0),GF(3));
IN_SCSCP_BINARY_MODE:=false;; t1:=TimeRoundtrip( z );
IN_SCSCP_BINARY_MODE:=true;; t2:=TimeRoundtrip( z );
Float(t1/t2);

TimeRoundtripWithPickling:=function( x )
local curtime1, curtime2, res;
curtime1:=IO_gettimeofday();
res:=IO_UnpickleFromString( EvaluateBySCSCP( "Identity", 
    [IO_PickleToString(x)],"localhost",26133).object) ;
curtime2:=IO_gettimeofday();
if res <> x then
  Error("Object corrupted after roundtrip!");
fi;
return Walltime(curtime1,curtime2);
end;

# List of 10^5 small integers
IN_SCSCP_BINARY_MODE:=false;; t1:=TimeRoundtripWithPickling( x );
IN_SCSCP_BINARY_MODE:=true;; t2:=TimeRoundtripWithPickling( x );
Float(t1/t2);

# String with 10^6 characters
IN_SCSCP_BINARY_MODE:=false;; t1:=TimeRoundtripWithPickling( y );
IN_SCSCP_BINARY_MODE:=true;; t2:=TimeRoundtripWithPickling( y );
Float(t1/t2);

# List of 10^4 elements of GF(3)
IN_SCSCP_BINARY_MODE:=false;; t1:=TimeRoundtripWithPickling( z );
IN_SCSCP_BINARY_MODE:=true;; t2:=TimeRoundtripWithPickling( z );
Float(t1/t2);

# Compressed vector of 10^4 elements of GF(3)
IN_SCSCP_BINARY_MODE:=false;; t1:=TimeRoundtripWithPickling( w );
IN_SCSCP_BINARY_MODE:=true;; t2:=TimeRoundtripWithPickling( w );
Float(t1/t2);

# Finally, we compare the difference between repetitive establishing
# new connections keeping connections alive across multiple calls.
# This tests should be tried on networks with various latency.

Walltime:=function(t1,t2) return 1000000*(t2.tv_sec-t1.tv_sec)+t2.tv_usec-t1.tv_usec; end;
server:="chrystal.mcs.st-and.ac.uk";
# server := "localhost";
PingSCSCPservice(server,26133);

curtime1:=IO_gettimeofday();
for i in [1..100] do 
  EvaluateBySCSCP("Identity",[1], server, 26133 );
od;
curtime2:=IO_gettimeofday();; Walltime(curtime1,curtime2);

curtime1:=IO_gettimeofday();
connection:=NewSCSCPconnection( server, 26133 );
for i in [1..100] do 
  EvaluateBySCSCP("Identity",[1], connection);
od;
CloseSCSCPconnection(connection);
curtime2:=IO_gettimeofday();; Walltime(curtime1,curtime2);

