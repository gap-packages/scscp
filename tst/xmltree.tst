#
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

#
gap> InstallSCSCPprocedure("WS_Factorial",Factorial : force);
gap> tt := ParseTreeXMLString(t);;
gap> node := tt.content[3];;
gap> node.content := Filtered( node.content, OMIsNotDummyLeaf );;
gap> attrs := List( Filtered( node.content[1].content, t -> t.name = "OMATP" ), OMParseXmlObj );
[ [ [ "call_id", "user007" ], [ "option_runtime", 1000 ], 
      [ "option_min_memory", 1024 ], [ "option_max_memory", 2048 ], 
      [ "option_debuglevel", 1 ], [ "option_return_object", "" ] ] ]
gap> OMParseXmlObj( node.content[1] );
120
