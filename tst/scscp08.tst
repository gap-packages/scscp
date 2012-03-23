# from paragraph [ 8, 1, 1, 6 ][ "../lib/process.gd", 203 ]


gap> a:=NewProcess( "WS_Factorial", [10], "localhost", 26133 );
< process at localhost:26133 pid=2064 >
gap> b:=NewProcess( "WS_Factorial", [20], "localhost", 26134 );
< process at localhost:26134 pid=1975 >
gap> SynchronizeProcesses(a,b);
[ rec( attributes := [ [ "call_id", "localhost:26133:2064:yCWBGYFO" ] ], 
      object := 3628800 ), 
  rec( attributes := [ [ "call_id", "localhost:26134:1975:yAAWvGTL" ] ], 
      object := 2432902008176640000 ) ]


# from paragraph [ 8, 1, 2, 6 ][ "../lib/process.gd", 240 ]


gap> a:=NewProcess( "WS_Factorial", [10], "localhost", 26133 );
< process at localhost:26133 pid=2064 >
gap> b:=NewProcess( "WS_Factorial", [20], "localhost", 26134 );
< process at localhost:26134 pid=1975 >
gap>  FirstProcess(a,b); 
rec( attributes := [ [ "call_id", "localhost:26133:2064:mdb8RaO2" ] ], 
  object := 3628800 )


# from paragraph [ 8, 1, 4, 5 ][ "../lib/scscp.gd", 594 ]


gap> ParQuickWithSCSCP( [ "WS_FactorsECM", "WS_FactorsMPQS" ], [ 2^150+1 ] );
rec( attributes := [ [ "call_id", "localhost:26133:53877:GQX8MhC8" ] ],
  object := [ [ 5, 5, 5, 13, 41, 61, 101, 1201, 1321, 63901 ],
      [ 2175126601, 15767865236223301 ] ] )


# from paragraph [ 8, 1, 5, 8 ][ "../lib/process.gd", 282 ]


gap> a:=NewProcess( "IsPrimeInt", [2^15013-1], "localhost", 26134 );
< process at localhost:26134 pid=42554 >
gap> b:=NewProcess( "IsPrimeInt", [2^521-1], "localhost", 26133 );
< process at localhost:26133 pid=42448 >
gap> FirstTrueProcess(a,b); 
[ , rec( attributes := [ [ "call_id", "localhost:26133:42448:Lz1DL0ON" ] ], 
      object := true ) ]


# from paragraph [ 8, 1, 5, 10 ][ "../lib/process.gd", 294 ]


gap> a:=NewProcess( "IsPrimeInt", [2^520-1], "localhost", 26133 );
< process at localhost:26133 pid=42448 >
gap> b:=NewProcess( "IsPrimeInt", [2^15013-1], "localhost", 26134 );
< process at localhost:26134 pid=42554 >
gap> FirstTrueProcess(a,b); 
[ rec( attributes := [ [ "call_id", "localhost:26133:42448:nvsk8PQp" ] ], 
      object := false ), 
  rec( attributes := [ [ "call_id", "localhost:26134:42554:JnEYuXL8" ] ], 
      object := false ) ]


# from paragraph [ 8, 2, 1, 6 ][ "../lib/scscp.gd", 639 ]


gap> ParListWithSCSCP( List( [2..6], n -> SymmetricGroup(n)), "WS_IdGroup" );
#I  master -> [ "localhost", 26133 ] : SymmetricGroup( [ 1 .. 2 ] )
#I  master -> [ "localhost", 26134 ] : SymmetricGroup( [ 1 .. 3 ] )
#I  [ "localhost", 26133 ] --> master : [ 2, 1 ]
#I  master -> [ "localhost", 26133 ] : SymmetricGroup( [ 1 .. 4 ] )
#I  [ "localhost", 26134 ] --> master : [ 6, 1 ]
#I  master -> [ "localhost", 26134 ] : SymmetricGroup( [ 1 .. 5 ] )
#I  [ "localhost", 26133 ] --> master : [ 24, 12 ]
#I  master -> [ "localhost", 26133 ] : SymmetricGroup( [ 1 .. 6 ] )
#I  [ "localhost", 26133 ] --> master : [ 720, 763 ]
#I  [ "localhost", 26134 ] --> master : [ 120, 34 ]
[ [ 2, 1 ], [ 6, 1 ], [ 24, 12 ], [ 120, 34 ], [ 720, 763 ] ]


# from paragraph [ 8, 3, 0, 13 ][ "parallel.xml", 176 ]


gap> ReadPackage("scscp/example/karatsuba.g");
gap> fam:=FamilyObj(1);;
gap> f:=LaurentPolynomialByCoefficients( fam, 
>         List([1..32000],i->Random(Integers)), 0, 1 );;
gap> g:=LaurentPolynomialByCoefficients( fam, 
>         List([1..32000],i->Random(Integers)), 0, 1 );;
gap> t2:=KaratsubaPolynomialMultiplication(f,g);;time;
5892
gap> t3:=KaratsubaPolynomialMultiplicationWS(f,g);;time;
2974


