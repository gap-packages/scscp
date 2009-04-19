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
Print("quillen16 done\n");

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
Print("quillen100 done\n");

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
Print("euler done\n");

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
Print("vkg64 done\n");

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
Print("vkg81 done\n");