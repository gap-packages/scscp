gap> START_TEST( "offline.tst" );
gap> LoadPackage("scscp");
true
gap> SetInfoLevel( InfoSCSCP, 0 );
gap> t:="";; stream:=OutputTextString(t,true);;
gap> OMPutProcedureCall( stream, "WS_Factorial", rec( object:= [ 5 ], 
>      attributes:=[ [ "call_id", "user007" ], 
>                    ["option_runtime",1000],
>                    ["option_min_memory",1024], 
>                    ["option_max_memory",2048],
>                    ["option_debuglevel",1], 
>                    ["option_return_object"] ] ) );;
gap> Print(t);
<?scscp start ?>
<OMOBJ xmlns="http://www.openmath.org/OpenMath" version="2.0">
	<OMATTR>
		<OMATP>
			<OMS cd="scscp1" name="call_id"/>
			<OMSTR>user007</OMSTR>
			<OMS cd="scscp1" name="option_runtime"/>
			<OMI>1000</OMI>
			<OMS cd="scscp1" name="option_min_memory"/>
			<OMI>1024</OMI>
			<OMS cd="scscp1" name="option_max_memory"/>
			<OMI>2048</OMI>
			<OMS cd="scscp1" name="option_debuglevel"/>
			<OMI>1</OMI>
			<OMS cd="scscp1" name="option_return_object"/>
			<OMSTR></OMSTR>
		</OMATP>
		<OMA>
			<OMS cd="scscp1" name="procedure_call"/>
			<OMA>
				<OMS cd="scscp_transient_1" name="WS_Factorial"/>
				<OMI>5</OMI>
			</OMA>
		</OMA>
	</OMATTR>
</OMOBJ>
<?scscp end ?>
gap> InstallSCSCPprocedure("WS_Factorial", Factorial : force );
gap> InstallSCSCPprocedure("GroupIdentificationService", IdGroup : force );
gap> InstallSCSCPprocedure("GroupByIdNumber", SmallGroup : force );
gap> InstallSCSCPprocedure( "Length", Length, 1, 1 : force );
gap> test:=Filename( Directory( Concatenation(
>         GAPInfo.PackagesInfo.("scscp")[1].InstallationPath,"/tst/" ) ), 
>         "omdemo.om" );;
gap> stream:=InputTextFile(test);;
gap> OMGetObjectWithAttributes(stream); 
rec( 
  attributes := [ [ "option_return_object", "" ], [ "call_id", "5rc6rtG62" ] ]
    , object := 6 )
gap> OMGetObjectWithAttributes(stream);
rec( attributes := [  ], object := 1 )
gap> OMGetObjectWithAttributes(stream);
rec( attributes := [  ], object := 120 )
gap> OMGetObjectWithAttributes(stream);
rec( 
  attributes := [ [ "call_id", "alexk_9053" ], [ "option_runtime", 300000 ], 
      [ "option_min_memory", 40964 ], [ "option_max_memory", 134217728 ], 
      [ "option_debuglevel", 2 ], [ "option_return_object", "" ] ], 
  object := [ 24, 12 ] )
gap> OMGetObjectWithAttributes(stream);
rec( 
  attributes := [ [ "call_id", "alexk_9053" ], [ "option_return_cookie", "" ] 
     ], object := <pc group of size 24 with 4 generators> )
gap> OMGetObjectWithAttributes(stream);
rec( attributes := [ [ "call_id", "alexk_9053" ], [ "info_runtime", 1234 ], 
      [ "info_memory", 134217728 ] ], object := [ 24, 12 ] )
gap> CloseStream( stream );
gap> STOP_TEST( "offline.tst", 10000000 );
