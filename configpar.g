# This file contains global variable SCSCPservers which
# specifies hosts and ports to search for SCSCP services.
#
# 1) To avoid errors, all services must have the called
#    SCSCP procedure installed and available under the
#    same name.
#
# 2) SCSCPservers is a proper GAP list, so you can use GAP
#    language constructions to generate it for a range
#    of port numbers, for example, for the beowulf cluster
#    with hostnames from bwlf01 to bwlf32 you may use: 
# 
#    List([1..32],i->[ Concatenation("bwlf",
#      Concatenation( List([1..2-Length(String(i))], i->"0") ),
#                     String(i)),26133]);
#
# 3) It is better to arrange services in this list in a way
#    that faster services and services with shorter latency
#    will be located in the beginning of the list, this will
#    optimise the initial placement of tasks and will speed
#    up computation when the number of tasks is smaller than
#    the number of services.
#
SCSCPservers:= 
# Concatenation( 
[ 
[ "localhost", 26133 ],
[ "localhost", 26134 ] 
]
# List( [26133..26140], i-> [ "ardbeg", i ] ),
# List( [26133..26140], i-> [ "ladybank02", i ] ),
# [ "chrystal.mcs.st-andrews.ac.uk", 26133 ],
# )
;
