# from paragraph [ 5, 3, 1, 4 ][ "/Users/alexk/CVSREPS/GAPDEV/pkg/scscp/doc/../lib/scscp.gd", 721 ]


gap> GetServiceDescription( "localhost", 26133 );
rec(
  description := "Started with the demo file scscp/example/myserver.g \
  on Sat  8 Oct 2011 17:24:13 BST", service_name := "GAP SCSCP service",
  version := "GAP 4.4.12 + SCSCP 2.0.0" )


# from paragraph [ 5, 3, 2, 5 ][ "/Users/alexk/CVSREPS/GAPDEV/pkg/scscp/doc/../lib/scscp.gd", 688 ]


gap> GetAllowedHeads("localhost",26133);
rec( scscp_transient_1 := [ "GroupIdentificationService", 
      "IO_UnpickleStringAndPickleItBack", "IdGroup512ByCode", "PointImages", 
      "QuillenSeriesByIdGroup", "SCSCPStartTracing", "SCSCPStopTracing", 
      "WS_ConwayPolynomial", "WS_Factorial", "WS_FactorsCFRAC", "WS_FactorsECM", 
      "WS_FactorsMPQS", "WS_FactorsPminus1", "WS_FactorsPplus1", "WS_FactorsTD", 
      "WS_IdGroup", "WS_Karatsuba", "WS_Phi" ] )


# from paragraph [ 5, 3, 3, 5 ][ "/Users/alexk/CVSREPS/GAPDEV/pkg/scscp/doc/../lib/scscp.gd", 848 ]


gap> IsAllowedHead( "permgp1", "group", "localhost", 26133 );
true
gap> IsAllowedHead( "nums1", "pi", "localhost", 26133 );
false


# from paragraph [ 5, 3, 4, 5 ][ "/Users/alexk/CVSREPS/GAPDEV/pkg/scscp/doc/../lib/scscp.gd", 800 ]


gap> GetTransientCD( "scscp_transient_1", "localhost", 26133 );
rec( CDDate := "2011-10-08", 
  CDDefinitions := 
    [ rec( Description := "Size is currently undocumented.", Name := "Size" ),
      rec( Description := "Length is currently undocumented.", 
          Name := "Length" ), 
      rec( Description := "NrConjugacyClasses is currently undocumented.", 
          Name := "NrConjugacyClasses" ), 
...
      rec( Description := "MatrixGroup is currently undocumented.", 
          Name := "MatrixGroup" ) ], CDName := "scscp_transient_1", 
  CDReviewDate := "2011-10-08", CDRevision := "0", CDStatus := "private", 
  CDVersion := "0", 
  Description := "This is a transient CD for the GAP SCSCP service" )


# from paragraph [ 5, 3, 5, 4 ][ "/Users/alexk/CVSREPS/GAPDEV/pkg/scscp/doc/../lib/scscp.gd", 762 ]


gap> GetSignature("scscp_transient_1","WS_Factorial","localhost",26133);
rec( maxarg := 1, minarg := 1,
  symbol := rec( cd := "scscp_transient_1", name := "WS_Factorial" ),
  symbolargs := rec( cd := "scscp2", name := "symbol_set_all" ) )


