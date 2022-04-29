###########################################################################
##
#W utils.g                  The SCSCP package            Olexandr Konovalov
#W                                                             Steve Linton
##
###########################################################################

###########################################################################
##
##  DateISO8601
##
##  <#GAPDoc Label="DateISO8601">
##  <ManSection>
##  <Func Name="DateISO8601" Arg=""/>
##  <Returns>
##    string
##  </Returns>	 
##  <Description>
##  Returns the current date in the ISO-8601 YYYY-MM-DD format. 
##  This is an internal function of the package which is used 
##  by the &SCSCP; server to generate the transient content 
##  dictionary, accordingly to the definition of the &OpenMath; 
##  symbol <C>meta.CDDate</C>.
##  <Log>
##  <![CDATA[
##  gap> DateISO8601();
##  "2017-02-05"
##  ]]>
##  </Log>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "DateISO8601", function()
local s, date;
s := IO_Popen("date", [ "+%y-%m-%d" ],"r");
date := IO_ReadLine(s);
IO_Close(s);
return Concatenation( "20", date{[ 1 .. Length(date)-1 ]} );
end);


###########################################################################
##
##  CurrentTimestamp
##
##  <#GAPDoc Label="CurrentTimestamp">
##  <ManSection>
##  <Func Name="CurrentTimestamp" Arg="" />
##  <Returns>
##    string
##  </Returns>	 
##  <Description>
##  Returns the result of the call to <File>date</File>. 
##  This is an internal function of the package which is 
##  used to add the timestamp to the &SCSCP; service description.
##  <Log>
##  <![CDATA[
##  gap> CurrentTimestamp();
##  "Tue 30 Jan 2017 11:19:38 BST"
##  ]]>
##  </Log>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "CurrentTimestamp", function() 
local s, date;
s := IO_Popen("date", [ ], "r");
date := IO_ReadLine(s);
IO_Close(s);
return date{[ 1 .. Length(date)-1 ]};
end);


###########################################################################
##
##  Hostname
##
##  <#GAPDoc Label="Hostname">
##  <ManSection>
##  <Func Name="Hostname" Arg=""/>
##  <Returns>
##    string    
##  </Returns>	 
##  <Description>
##  Returns the result of the call to <File>hostname</File>. This function 
##  may be used in the configuration file <File>scscp/config.g</File>
##  to specify that the default hostname which will be used by the &SCSCP; 
##  server will be detected automatically using <File>hostname</File>.
##  <Log>
##  <![CDATA[
##  gap> Hostname();
##  "scscp.gap-system.org"
##  ]]>
##  </Log>     
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "Hostname", function()
local s, hostname;
s := IO_Popen("hostname",[],"r");
hostname := IO_ReadLine(s);
IO_Close(s);
return hostname{[ 1 .. Length(hostname)-1 ]};;
end);


###########################################################################
##
##  MemoryUsageByGAPinKbytes
##
##  <#GAPDoc Label="MemoryUsageByGAPinKbytes">
##  <ManSection>
##  <Func Name="MemoryUsageByGAPinKbytes" Arg=""/>
##  <Returns>
##    integer
##  </Returns>	 
##  <Description>
##  Returns the current volume of the memory used by &GAP; in kylobytes. 
##  This is equivalent to calling <File>ps -p &lt;PID> -o vsz</File>, where
##  <C>&lt;PID></C> is the process ID of the &GAP; process. This is an 
##  internal function of the package which is used by the &SCSCP; server to 
##  report its memory usage in the <C>info_memory</C> attribute when being 
##  called with the option <C>debuglevel=2</C> (see options in 
##  <Ref Func="EvaluateBySCSCP" /> and <Ref Func="NewProcess" />).
##  <Log>
##  <![CDATA[
##  gap> MemoryUsageByGAPinKbytes();
##  649848
##  ]]>
##  </Log>     
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "MemoryUsageByGAPinKbytes", function()
local s, mem;
s := IO_Popen( "ps", [ "-p", String( IO_getpid() ), "-o", "vsz" ], "r");
IO_ReadLine(s);
mem := IO_ReadLine(s);
IO_Close(s);
RemoveCharacters( mem, " \n" );
return Int(mem);
end);


###########################################################################
##
##  LastReceivedCallID
##
##  <#GAPDoc Label="LastReceivedCallID">
##  <ManSection>
##  <Func Name="LastReceivedCallID" Arg=""/>
##  <Returns>
##    string
##  </Returns>	 
##  <Description>
##  Returns the call ID contained in the most recently received message. 
##  It may contain some useful debugging information; in particular, the 
##  call ID for the &GAP; &SCSCP; client and server contains colon-separated 
##  server name, port number, process ID and a random string.
##  <Log>
##  <![CDATA[
##  gap> LastReceivedCallID();
##  "scscp.gap-system.org:26133:77372:choDZBgA"
##  ]]>
##  </Log> 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "LastReceivedCallID", function()
return OMTempVars.OMATTR.content[2].content[1].content; 
end);


###########################################################################
##
##  IO_PickleToString
##
##  <#GAPDoc Label="IO_PickleToString">
##  <ManSection>
##  <Func Name="IO_PickleToString" Arg="obj"/>
##  <Returns>
##    string containing "pickled" object
##  </Returns>	 
##  <Description>
##  This function "pickles" or "serialises" the object <A>obj</A> using the
##  operation <Ref BookName="IO" Oper="IO_Pickle" /> from the &IO; package, 
##  and writes it to a string, from which it could be later restored using 
##  <Ref Func="IO_UnpickleFromString" />. This provides a way to design 
##  &SCSCP; procedures which transmit &GAP; objects in the "pickled" format 
##  as &OpenMath; strings, which may be useful for objects which may be 
##  "pickled" by the &IO; package but can not be converted to &OpenMath; 
##  or for which the "pickled" representation is more compact or can be 
##  encoded/decoded much faster.
##  <P/> 
##  See <Ref BookName="IO" Oper="IO_Pickle" /> and <Ref
##  BookName="IO" Oper="IO_Unpickle" /> for more details.
##  <Example>
##  <![CDATA[
##  gap> f := IO_PickleToString( GF( 125 ) );
##  "FFIEINTG\>15INTG\>13FAIL"
##  ]]>
##  </Example>        
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "IO_PickleToString", function( obj )
local rb, wb, s;
rb:="";
wb:="";
s:=IO_WrapFD(-1,rb,wb);
IO_Pickle( s, obj );
IO_Close( s );
return wb;
end);


###########################################################################
##
##  IO_UnpickleFromString
##
##  <#GAPDoc Label="IO_UnpickleFromString">
##  <ManSection>
##  <Func Name="IO_UnpickleFromString" Arg="s"/>
##  <Returns>
##    "unpickled" GAP object
##  </Returns>	 
##  <Description>
##  This function "unpickles" the string <A>s</A> which was
##  created using the function <Ref Func="IO_PickleToString" />,
##  using the operation <Ref BookName="IO" Oper="IO_Unpickle" /> 
##  from the &IO; package. See <Ref Func="IO_PickleToString" />
##  for more details and suggestions about its usage.
##  <Example>
##  <![CDATA[
##  gap> IO_UnpickleFromString( f );                    
##  GF(5^3)
##  gap> f = IO_UnpickleFromString( IO_PickleToString( f ) ); 
##  true
##  ]]>
##  </Example>   
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "IO_UnpickleFromString", function( str )
local rb, wb, s, r;
rb:=str;
wb:="";
s:=IO_WrapFD(-1,rb,wb);
r:=IO_Unpickle( s );
IO_Close( s );
return r;
end);


##########################################################################
##
##  SwitchSCSCPmodeToBinary
##
##  <#GAPDoc Label="SwitchSCSCPmodeToBinary">
##  <ManSection>
##  <Func Name="SwitchSCSCPmodeToBinary" Arg=""/>
##  <Func Name="SwitchSCSCPmodeToXML" Arg=""/>
##  <Returns>
##    nothing
##  </Returns>	 
##  <Description>
##  The &OpenMath; package supports both binary and XML encodings for 
##  &OpenMath;. To switch between them, use 
##  <Ref Func="SwitchSCSCPmodeToBinary"/> and
##  <Ref Func="SwitchSCSCPmodeToXML"/>.
##  When the package is loaded, the mode is initially set to XML.
##  On the clients's side, you can change the mode back and forth as 
##  many times as you wish during the same &SCSCP; session. The server
##  will autodetect the mode and will response in the same format, so
##  one does not need to set the mode on the server's side.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "SwitchSCSCPmodeToBinary", function( )
IN_SCSCP_BINARY_MODE := true;
end);

BindGlobal( "SwitchSCSCPmodeToXML", function( )
IN_SCSCP_BINARY_MODE := false;
end);


###########################################################################
##
#E 
##
