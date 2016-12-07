ReadPackage("laguna", "lib/parunits.g");

SCSCPLogTracesToGlobal("quillen16");
ParListWithSCSCP(List([1..16], i->[512,i]),"QuillenSeriesByIdGroup");
SCSCPLogTracesToGlobal();
Print("quillen16 done\n");

SCSCPLogTracesToGlobal("quillen100");
ParListWithSCSCP(List([1..100], i->[512,i]),"QuillenSeriesByIdGroup");
SCSCPLogTracesToGlobal();
Print("quillen100 done\n");

SCSCPLogTracesToGlobal("euler");
ParListWithSCSCP( [1..1000], "WS_Phi");
SCSCPLogTracesToGlobal();
Print("Euler done\n");

n:=16;G:=DihedralGroup(n);id:=IdGroup(G);
SCSCPLogTracesToGlobal("vkg64");
ParPcNormalizedUnitGroup(GroupRing(GF(2),SmallGroup(id)));
SCSCPLogTracesToGlobal();
Print("vkg64 done\n");

SCSCPLogTracesToGlobal("vkg81");
ParPcNormalizedUnitGroup(GroupRing(GF(3),SmallGroup(81,7)));
SCSCPLogTracesToGlobal();
Print("vkg81 done\n");