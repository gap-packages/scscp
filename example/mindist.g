############################################################################
#
# Demo of  Parallelised method to compute minimal distance for linear codes
#
LoadPackage("scscp");
LoadPackage("guava");
ReadPackage("scscp", "example/mindist.gi");

# The next function is supposed to compute the runtime in microseconds
# after IO_gettimeofday() was called before and after computation
#
runtime:=function(t1,t2) return 1000000*(t2.tv_sec-t1.tv_sec)+t2.tv_usec-t1.tv_usec; end;


############################################################################                           
#
# Code snippets for SCSCPservers (uncomment as needed)
#

# SCSCPservers:=List( [26133..26140], i-> [ "localhost",  i ] );

# SCSCPservers := Concatenation( 
# List( [26133..26140], i-> [ "localhost",  i ] ),
# List( [26133..26140], i-> [ "ladybank02",  i ] ),
# List( [26133..26140], i-> [ "ladybank01",  i ] ) );

SCSCPservers:=List( [26133..26134], i-> [ "localhost",  i ] );

############################################################################ 

# if IN_SCSCP_BINARY_MODE is false, then XML encoding is used
IN_SCSCP_BINARY_MODE:=true;

# Switch off OpenMath display
SetInfoLevel(InfoSCSCP,0);

# Show how the work is distributed and which values are returned
SetInfoLevel(InfoMasterWorker,5);

# Read sample codes
ReadPackage("scscp", "example/code1.g");
ReadPackage("scscp", "example/code2.g");
ReadPackage("scscp", "example/code3.g");

# WHY USE PICKLING?

curtime1:=IO_gettimeofday();
EvaluateBySCSCP("Identity",[linear_code_example_1],"localhost",26133);;
curtime2:=IO_gettimeofday();
runtime(curtime1,curtime2);

curtime1:=IO_gettimeofday();
IO_UnpickleFromString( EvaluateBySCSCP( "IO_UnpickleStringAndPickleItBack", 
    [ IO_PickleToString(linear_code_example_1) ], "localhost", 26133 ).object );;
curtime2:=IO_gettimeofday();
runtime(curtime1,curtime2);

# EXAMPLE 1
C:=GeneratorMatCode(linear_code_example_1,GF(2));;
curtime1:=IO_gettimeofday();
MinimumDistance(C); # answer = 6
curtime2:=IO_gettimeofday();
runtime(curtime1,curtime2);

# EXAMPLE 2

C:=GeneratorMatCode(linear_code_example_2,GF(2));;
curtime1:=IO_gettimeofday();
MinimumDistance(C); # answer = 6
curtime2:=IO_gettimeofday();
runtime(curtime1,curtime2);

# EXAMPLE 3

C:=GeneratorMatCode(linear_code_example_3,GF(2));;
curtime1:=IO_gettimeofday();
MinimumDistance(C); 
curtime2:=IO_gettimeofday();
runtime(curtime1,curtime2);

############################################################################                           
##
#E