# from paragraph [ 4, 1, 1, 4 ][ "/Users/alexk/CVSREPS/GAPDEV/pkg/scscp/doc/../lib/scscp.gd", 492 ]


gap> s := InputOutputTCPStream("localhost",26133);
< input/output TCP stream to localhost:26133 >
gap> StartSCSCPsession(s);
"localhost:26133:5541"
gap> CloseStream( s );


# from paragraph [ 4, 1, 2, 4 ][ "/Users/alexk/CVSREPS/GAPDEV/pkg/scscp/doc/../lib/openmath.gd", 112 ]


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
<OMOBJ>
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


# from paragraph [ 4, 1, 4, 6 ][ "/Users/alexk/CVSREPS/GAPDEV/pkg/scscp/doc/../lib/openmath.gd", 44 ]


gap> InstallSCSCPprocedure("WS_Factorial", Factorial );
gap> InstallSCSCPprocedure("GroupIdentificationService", IdGroup );
gap> InstallSCSCPprocedure("GroupByIdNumber", SmallGroup );
gap> InstallSCSCPprocedure( "Length", Length, 1, 1 );
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


# from paragraph [ 4, 2, 1, 4 ][ "/Users/alexk/CVSREPS/GAPDEV/pkg/scscp/doc/../lib/openmath.gd", 176 ]


gap> t:="";; stream:=OutputTextString(t,true);;
gap> OMPutProcedureCompleted( stream, 
>      rec(object:=120, 
>      attributes:=[ [ "call_id", "user007" ] ] ) );
true
gap> Print(t);
<?scscp start ?>
<OMOBJ>
	<OMATTR>
		<OMATP>
			<OMS cd="scscp1" name="call_id"/>
			<OMSTR>user007</OMSTR>
		</OMATP>
		<OMA>
			<OMS cd="scscp1" name="procedure_completed"/>
			<OMI>120</OMI>
		</OMA>
	</OMATTR>
</OMOBJ>
<?scscp end ?>


# from paragraph [ 4, 3, 0, 4 ][ "/Users/alexk/CVSREPS/GAPDEV/pkg/scscp/doc/openmath.xml", 50 ]


gap> stream:=InputOutputTCPStream( "localhost", 26133 );
< input/output TCP stream to localhost:26133 >
gap> sid := StartSCSCPsession( stream );
"localhost:26133:5541"
gap> res:=[];
[  ]
gap> for i in [1..10] do
>     OMPutProcedureCall( stream, "WS_Factorial", 
>       rec( object := [ i ], 
>        attributes := [ [ "call_id", 
>          Concatenation( sid, ":", RandomString(8) ) ] ] ) );
>     SCSCPwait( stream );
>     res[i]:=OMGetObjectWithAttributes( stream ).object;
> od;
gap> CloseStream(stream);
gap> res;
[ 1, 2, 6, 24, 120, 720, 5040, 40320, 362880, 3628800 ]


