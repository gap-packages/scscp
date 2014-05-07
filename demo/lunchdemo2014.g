# Demo for CIRCA lunch talk on May 8th, 2014

LoadPackage("scscp");
Read("liouville.g");

# Same functions called locally and remotely. Check that the result is the same
LiouvilleFunction(1000);
EvaluateBySCSCP("LiouvilleFunction",[1000],"localhost", 26133);
PartialSummatoryLiouvilleFunction([1..1000]);
EvaluateBySCSCP("PartialSummatoryLiouvilleFunction",[[1..1000]],"localhost", 26133);

# Tell master which workers to use
SCSCPservers:=List([26101..26148], i -> ["localhost",i]);

# Setup for timing in microseconds
Realtime:=function(t1,t2) return 1000000*(t2.tv_sec-t1.tv_sec)+t2.tv_usec-t1.tv_usec; end;

# Sequential version using 'List'
t1:=IO_gettimeofday(); Sum( List( [1..1000], LiouvilleFunction ) ); t2:=IO_gettimeofday();
seqtime:=Realtime(t1,t2);

# Naive parallelisation is several thousand times slower!
t1:=IO_gettimeofday(); Sum( ParListWithSCSCP( [1..1000], "LiouvilleFunction" ) ); t2:=IO_gettimeofday();
partime:=Realtime(t1,t2);
Float(partime/seqtime);

# This may take about two minutes
t1:=IO_gettimeofday(); Sum( List( [1..10000000], LiouvilleFunction ) ); t2:=IO_gettimeofday();
seqtime:=Realtime(t1,t2);

# Parallel version with chunks should demonstrate acceptable speedups
t1:=IO_gettimeofday(); ParSummatoryLiouvilleFunction( 10000000, 100000); t2:=IO_gettimeofday();
partime:=Realtime(t1,t2);
Float(seqtime/partime);

# Now let's check that L(906180359)=+1, this may take about 20 minutes on 48 cores
t1:=IO_gettimeofday(); ParSummatoryLiouvilleFunction( 906180359, 100000); t2:=IO_gettimeofday();
partime:=Realtime(t1,t2);
