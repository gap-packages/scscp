# This file contains global variable SCSCPservers which
# specifies hosts and ports to search for SCSCP services.
#
# 1) To avoid errors, all services must have the called
#    SCSCP procedure installed and available under the
#    same name.
#
# 2) SCSCPservers is a proper GAP list, so you can use GAP
#    language constructions to generate it for a range
#    of port numbers, for example, for specify SCSCP servers
#    at the the beowulf cluster with hostnames from bwlf01 to 
#    bwlf16 and 4 cores per node you may use: 
# 
#    nrnodes:=16;
#    nrcores:=4;
#    SCSCPservers := Cartesian ( 
#      List( [1..nrnodes], i-> 
#        Concatenation(
#          "bwlf", 
#          Concatenation( List([1..2-Length(String(i))], i->"0") ),
#          String(i) ) ), 
#      [26133 .. 26133+nrcores-1] );
#
# 3) It is better to arrange services in this list in a way
#    that faster services and services with shorter latency
#    will be located in the beginning of the list, this will
#    optimise the initial placement of tasks and will speed
#    up computation when the number of tasks is smaller than
#    the number of services.
#
SCSCPservers:= List( [26133..26134], i-> [ "localhost",  i ] );

###########################################################################
##
#E
##
