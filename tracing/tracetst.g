ReadPackage("scscp/par/parlist.g");

testname:="quillen16";
for server in SCSCPservers do
	EvaluateBySCSCP("SCSCPStartTracing",[ testname ], server[1], server[2] );
od;
SCSCPLogTracesTo( testname );
ParListWithSCSCP(List([1..16], i->[512,i]),"QuillenSeriesByIdGroup");
SCSCPLogTracesTo();
for server in SCSCPservers do
	EvaluateBySCSCP("SCSCPStopTracing",[ ], server[1], server[2] );
od;

testname:="quillen100";
for server in SCSCPservers do
	EvaluateBySCSCP("SCSCPStartTracing",[ testname ], server[1], server[2] );
od;
SCSCPLogTracesTo( testname );
ParListWithSCSCP(List([1..100], i->[512,i]),"QuillenSeriesByIdGroup");
SCSCPLogTracesTo();
for server in SCSCPservers do
	EvaluateBySCSCP("SCSCPStopTracing",[ ], server[1], server[2] );
od;

testname:="euler";
for server in SCSCPservers do
	EvaluateBySCSCP("SCSCPStartTracing",[ testname ], server[1], server[2] );
od;
SCSCPLogTracesTo( testname );
ParListWithSCSCP( [1..1000], "WS_Phi");
SCSCPLogTracesTo();
for server in SCSCPservers do
	EvaluateBySCSCP("SCSCPStopTracing",[ ], server[1], server[2] );
od;

testname:="vkg64";
ReadPackage("laguna/lib/parunits.g");
for server in SCSCPservers do
	EvaluateBySCSCP("SCSCPStartTracing",[ testname ], server[1], server[2] );
od;
SCSCPLogTracesTo( testname );
n:=16;G:=DihedralGroup(n);id:=IdGroup(G);
ParPcNormalizedUnitGroup(GroupRing(GF(2),SmallGroup(id)));
SCSCPLogTracesTo(); 
for server in SCSCPservers do
	EvaluateBySCSCP("SCSCPStopTracing",[ ], server[1], server[2] );
od;

testname:="vkg81";
ReadPackage("laguna/lib/parunits.g");
for server in SCSCPservers do
	EvaluateBySCSCP("SCSCPStartTracing",[ testname ], server[1], server[2] );
od;
SCSCPLogTracesTo( testname );
ParPcNormalizedUnitGroup(GroupRing(GF(3),SmallGroup(81,7)));
SCSCPLogTracesTo(); 
for server in SCSCPservers do
	EvaluateBySCSCP("SCSCPStopTracing",[ ], server[1], server[2] );
od;