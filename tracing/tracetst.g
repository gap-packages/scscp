ReadPackage("scscp/par/parlist.g");
SetInfoLevel(InfoSCSCP,0);

testname:="quillen10";
EvaluateBySCSCP("SCSCPStartTracing",[ testname ],"localhost",26133);
EvaluateBySCSCP("SCSCPStartTracing",[ testname ],"localhost",26134);
SCSCPLogTracesTo( testname );
ParListWithSCSCP(List([1..10], i->[512,i]),"QuillenSeriesByIdGroup");
SCSCPLogTracesTo();
EvaluateBySCSCP("SCSCPStopTracing",[],"localhost",26133);
EvaluateBySCSCP("SCSCPStopTracing",[],"localhost",26134);

testname:="quillen100";
EvaluateBySCSCP("SCSCPStartTracing",[ testname ],"localhost",26133);
EvaluateBySCSCP("SCSCPStartTracing",[ testname ],"localhost",26134);
SCSCPLogTracesTo( testname );
ParListWithSCSCP(List([1..100], i->[512,i]),"QuillenSeriesByIdGroup");
SCSCPLogTracesTo();
EvaluateBySCSCP("SCSCPStopTracing",[],"localhost",26133);
EvaluateBySCSCP("SCSCPStopTracing",[],"localhost",26134);

testname:="euler";
EvaluateBySCSCP("SCSCPStartTracing",[ testname ],"localhost",26133);
EvaluateBySCSCP("SCSCPStartTracing",[ testname ],"localhost",26134);
SCSCPLogTracesTo( testname );
ParListWithSCSCP( [1..1000], "WS_Phi");
SCSCPLogTracesTo();
EvaluateBySCSCP("SCSCPStopTracing",[],"localhost",26133);
EvaluateBySCSCP("SCSCPStopTracing",[],"localhost",26134);

testname:="vkg64";
ReadPackage("laguna/lib/parunits.g");
EvaluateBySCSCP("SCSCPStartTracing",[ testname ],"localhost",26133);
EvaluateBySCSCP("SCSCPStartTracing",[ testname ],"localhost",26134);
SCSCPLogTracesTo( testname );
n:=64;G:=DihedralGroup(n);id:=IdGroup(G);
ParPcNormalizedUnitGroup(GroupRing(GF(2),SmallGroup(id)));
SCSCPLogTracesTo(); 
EvaluateBySCSCP("SCSCPStopTracing",[],"localhost",26133);
EvaluateBySCSCP("SCSCPStopTracing",[],"localhost",26134);

testname:="vkg81";
ReadPackage("laguna/lib/parunits.g");
EvaluateBySCSCP("SCSCPStartTracing",[ testname ],"localhost",26133);
EvaluateBySCSCP("SCSCPStartTracing",[ testname ],"localhost",26134);
SCSCPLogTracesTo( testname );
ParPcNormalizedUnitGroup(GroupRing(GF(3),SmallGroup(81,7)));
SCSCPLogTracesTo(); 
EvaluateBySCSCP("SCSCPStopTracing",[],"localhost",26133);
EvaluateBySCSCP("SCSCPStopTracing",[],"localhost",26134);