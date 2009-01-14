gap> START_TEST("$Id$");
gap> SetInfoLevel(InfoSCSCP,0);
gap> PingWebService( "localhost", 26133 );
true
gap> EvaluateBySCSCP( "WS_Factorial", [10], "localhost", 26133).object;
"3628800"
gap> STOP_TEST( "scscp.tst", 0 );