#############################################################################
##
#W openmath.g               The SCSCP package              Olexandr Konovalov
#W                                                               Steve Linton
##
#############################################################################

SCSCP_UNBIND_MODE := false;
SCSCP_STORE_SESSION_MODE := true;

#############################################################################
#
# SCSCPtransientCDs stores information about transient CDs,
# namely description and signatures of installed procedures
#
BindGlobal( "SCSCPtransientCDs", rec() );
MakeReadWriteGlobal( "SCSCPtransientCDs" );


##############################################################################
#
# SCSCP_RETRIEVE( <varnameasstring> )
#
InstallGlobalFunction( SCSCP_RETRIEVE, x -> x[1] );


##############################################################################
#
# SCSCP_STORE_SESSION( <obj> )
# SCSCP_STORE_PERSISTENT( <obj> )
#
# These are dummy functions since the magic is done in RunSCSCPserver
#
InstallGlobalFunction( SCSCP_STORE_SESSION,    x -> x[1] );
InstallGlobalFunction( SCSCP_STORE_PERSISTENT, x -> x[1] );


##############################################################################
#
# SCSCP_UNBIND( <varnameasstring> )
#
InstallGlobalFunction( SCSCP_UNBIND,
function( varnameasstring )
UnbindGlobal( varnameasstring[1] );
return not IsBoundGlobal( varnameasstring[1] );
end);


##############################################################################
#
# SCSCP_GET_ALLOWED_HEADS( [ ] )
#
InstallGlobalFunction( SCSCP_GET_ALLOWED_HEADS,
function( x )
# the function should have an argument, which in this case will be an 
# empty list, since 'get_allowed_heads' has no arguments
local range, cd, name, omstr;
if x <> [] then 
  Print( "WARNING: get_allowed_heads has no arguments, but called with argument ", x, 
         " which will be ignored!\n");
fi;
omstr:="<OMA>\n";
Append( omstr, "<OMS cd=\"scscp2\" name=\"symbol_set\"/>\n" );
# we may eventually have more than one transient CD, then the loop will be uncommented
if SCSCPserverAcceptsOnlyTransientCD then
	range := [ "scscp_transient_1" ];
else
	range := RecNames(OMsymRecord);
fi;
for cd in range do
  for name in RecNames(OMsymRecord.(cd)) do
    if OMsymRecord.(cd).(name) <> fail then
      Append( omstr, Concatenation( "<OMS cd=\"", cd, "\" name=\"", name, "\"/>\n" ) );
    fi;  
  od;
od;
Append( omstr, "</OMA>" );
return OMPlainString( omstr );
end);


##############################################################################
#
# SCSCP_IS_ALLOWED_HEAD( <openmathsymbol> )
#
InstallGlobalFunction( SCSCP_IS_ALLOWED_HEAD,
function( x )
local tran, s, symb, t;
if IsBound( OMsymRecord.(x[1]) ) then
  if IsBound( OMsymRecord.(x[1]).(x[2]) ) then
    if OMsymRecord.(x[1]).(x[2]) <> fail then
      return true;
    fi;
  fi;
fi;
return false;
end);


##############################################################################
#
# SCSCP_GET_SERVICE_DESCRIPTION( [ ] )
#
InstallGlobalFunction( SCSCP_GET_SERVICE_DESCRIPTION,
function( x )
local omstr;
# the function should have an argument, which in this case will be an 
# empty list, since 'get_allowed_heads' has no arguments
if x <> [] then 
  Print( "WARNING: get_service_description has no arguments, but called with argument ", x, 
         " which will be ignored!\n");
fi;
omstr:="<OMA>\n<OMS cd=\"scscp2\" name=\"service_description\"/>\n";
Append( omstr, Concatenation("<OMSTR>", SCSCPserviceName, "</OMSTR>\n" ) );
Append( omstr, Concatenation("<OMSTR>", SCSCPserviceVersion, "</OMSTR>\n" ) );
Append( omstr, Concatenation("<OMSTR>", SCSCPserviceDescription, "</OMSTR>\n" ) );
Append( omstr, "</OMA>" );
return OMPlainString( omstr );
end);


##############################################################################
#
# SCSCP_GET_TRANSIENT_CD( <x> )
#
InstallGlobalFunction( SCSCP_GET_TRANSIENT_CD,
function( x )
local omstr, procname;
if not IsBound( OMsymRecord.(x[1]) ) then
    Error("no_such_transient_cd");
else
    omstr:="<CD>\n<CDName>scscp_transient_1</CDName>\n";
    Append( omstr, Concatenation( "<CDReviewDate>", DateISO8601(), "</CDReviewDate>\n" ) );
    Append( omstr, Concatenation( "<CDDate>", DateISO8601(), "</CDDate>\n" ) );
    Append( omstr, Concatenation( "<CDVersion>", "0", "</CDVersion>\n" ) );
    Append( omstr, Concatenation( "<CDRevision>", "0", "</CDRevision>\n" ) );
    Append( omstr, "<CDStatus>private</CDStatus>\n" );
    Append( omstr, "<Description>This is a transient CD for the GAP SCSCP service</Description>\n" );
    for procname in RecNames( OMsymRecord.(x[1]) ) do
        Append( omstr, Concatenation( "<CDDefinition>\n", "<Name>", procname, "</Name>\n" ) );
        Append( omstr, Concatenation( "<Description>",
                                      SCSCPtransientCDs.(x[1]).(procname).Description,
                                      "</Description>\n</CDDefinition>\n" ) );
    od;
fi;
Append( omstr, "</CD>" );
return OMPlainString( omstr );
end);


##############################################################################
#
# SCSCP_GET_SIGNATURE( <openmathsymbol> )
#
InstallGlobalFunction( SCSCP_GET_SIGNATURE,
function( x )
local omstr;
if not IsBound( OMsymRecord.(x[1]) ) then
    Error("no_such_transient_cd");
else
    if not IsBound( OMsymRecord.(x[1]).(x[2]) ) then
        Error("no_such_symbol");
    else
        omstr:="<OMA>\n<OMS cd=\"scscp2\" name=\"signature\"/>\n";
        Append( omstr, Concatenation( "<OMS cd=\"", x[1], "\" name=\"", x[2], "\"/>\n" ) );
        Append( omstr, Concatenation( OMString( SCSCPtransientCDs.(x[1]).(x[2]).Minarg : noomobj ), "\n" ) );
        Append( omstr, Concatenation( OMString( SCSCPtransientCDs.(x[1]).(x[2]).Maxarg : noomobj ), "\n" ) );
        Append( omstr, "<OMS cd=\"scscp2\" name=\"symbol_set_all\"/>\n" );
        Append( omstr, "</OMA>" );
        return OMPlainString( omstr );
    fi;
fi;        
end);


#############################################################################
##
##  Extending global record OMsymRecord previously created in OpenMath package
##
OMsymRecord.scscp1 := rec(
	procedure_call := x -> x[1], # x is already converted from OM to GAP 
	procedure_completed := 
    	function(x); 
        if IsBound(x[1]) then 
        	return x[1];
        else # when no object is returned
        	return "procedure completed";
        fi;
        end,
    procedure_terminated := x -> x[1],
    call_id := "call_id",
    info_memory := "info_memory",
    info_message := "info_message",
    info_runtime := "info_runtime",
    option_debuglevel := "option_debuglevel",
    option_max_memory := "option_max_memory",
    option_min_memory := "option_min_memory",
    option_return_cookie := "option_return_cookie",
    option_return_object := "option_return_object",
    option_return_nothing := "option_return_nothing",
    option_return_deferred := "option_return_deferred",
    option_runtime := "option_runtime",
    error_CAS := "error_CAS"
);

OMsymRecord.scscp2 := rec( 
    store_session := SCSCP_STORE_SESSION,
    store_persistent := SCSCP_STORE_PERSISTENT,
    retrieve := SCSCP_RETRIEVE,
    unbind := SCSCP_UNBIND,
    get_allowed_heads := SCSCP_GET_ALLOWED_HEADS,
    is_allowed_head := SCSCP_IS_ALLOWED_HEAD,
    get_service_description := SCSCP_GET_SERVICE_DESCRIPTION,
    get_transient_cd := SCSCP_GET_TRANSIENT_CD,
    get_signature := SCSCP_GET_SIGNATURE
);
    
OMsymRecord.meta := rec(
	CDName := x -> x[1]
);
       

#############################################################################
##
#F  OMGetObjectWithAttributes( <stream> )
##
##  <stream> is an input stream with an OpenMath object on it.
##  Takes precisely one object off <stream> (using PipeOpenMathObject)
##  and puts it into a string.
##  From there the OpenMath object is turned into a record r with fields
##  r.object, containing the corresponding GAP object, and r.attributes, 
##  which is a list of pairs [ name, value ], for example 
##  [ ["call_id", "user007" ], ["option_runtime", 300000] ]
##  This is a counterpart of the function OMGetObject from OpenMath package .
##
InstallGlobalFunction( OMGetObjectWithAttributes,
function( stream )
    local return_tree,
          fromgap, # string
          firstbyte,
          gap_obj,
          success, # whether PipeOpenMathObject worked
          readline;
        
    if IsClosedStream( stream )  then
        Error( "closed stream" );
    elif IsEndOfStream( stream )  then
        Error( "end of stream" );
    fi;
    
    if ValueOption("return_tree") <> fail then
        return_tree := true;
    else
        return_tree := false;  
    fi;

    # read new line until <?scscp start ?>
    repeat
      readline:=ReadLine(stream);
      if readline=fail then
        return fail;
      fi;  
      NormalizeWhitespace( readline );
      if Length( readline ) > 0 then 
        Info( InfoSCSCP, 2, readline );
      fi;  
    until readline= "<?scscp start ?>";

    firstbyte := ReadByte(stream);
    
    if firstbyte = 24 then 
  	    # Reading binary encoding => set reply mode to binary
  	    IN_SCSCP_BINARY_MODE:=true;  
 	    gap_obj := GetNextObject( stream, firstbyte );
     	gap_obj := OMParseXmlObj( gap_obj.content[1] );
        return rec( object := gap_obj, attributes := OMParseXmlObj( OMTempVars.OMATTR ) );
    else
    
    	if firstbyte = fail then
      		Info( InfoSCSCP, 2, "OpenMath object not retrieved by PipeOpenMathObject" );
      		return fail;
    	fi;
    	
     	# Reading XML encoding => set reply mode to XML
     	IN_SCSCP_BINARY_MODE:=false;  
        fromgap := "";                
        # Get one OpenMath object from 'stream' and put into 'fromgap',
        # using PipeOpenMathObject
    
	    success := PipeOpenMathObject( stream, fromgap, firstbyte );

    	if success <> true  then
      		Info( InfoSCSCP, 2, "OpenMath object not retrieved by PipeOpenMathObject" );
      		return fail;
    	fi;
    
    	# Now 'fromgap' is the string with OpenMath encoding
        
    	if InfoLevel( InfoSCSCP ) > 2 then
      		Print("#I Received message: \n");
      		Print( fromgap );
      		Print( "\n" );
    	fi;

    	# read new line until <?scscp end ?>
    	repeat
      		readline:=ReadLine(stream);
      		if readline=fail then
        		return fail;
      		fi;  
      		NormalizeWhitespace( readline );
      		if Length( readline ) > 0 then 
        		Info( InfoSCSCP, 2, readline );
      		fi; 
    	until readline= "<?scscp end ?>";

    	# convert the OpenMath string into a Gap object using an appropriate
    	# function

        if return_tree then
        	return OMgetObjectXMLTreeWithAttributes( fromgap : return_tree );
        else
            return OMgetObjectXMLTreeWithAttributes( fromgap );
        fi;   
    fi;
end );


#############################################################################
##
#F OMgetObjectXMLTreeWithAttributes(string)
##
## This is a counterpart of the OpenMath function OMgetObjectXMLTree
##
InstallGlobalFunction( OMgetObjectXMLTreeWithAttributes,
function(string)
    local return_tree, return_deferred, node, attrs, t, obj, pos, name;

    if ValueOption("return_tree") <> fail then
        return_tree := true;
    else
        return_tree := false;
    fi;

    OMTempVars.OMBIND := rec(  );
    OMTempVars.OMREF := rec(  );

    # This is the difference from OMgetObjectXMLTree
    OMTempVars.OMATTR := rec(  );

    node := ParseTreeXMLString( string ).content[1];

    node.content := Filtered( node.content, OMIsNotDummyLeaf );

    # Print( "ParseTreeXMLString( string ) = ", node.content, "\n" );

    attrs := List( Filtered( node.content[1].content, t -> t.name = "OMATP" ), OMParseXmlObj );

    if Length(attrs)=1 then
        attrs:=attrs[1];
    fi;

    # At this point we already know attributes BEFORE the the real computation is started.
    # This allows us to know in advance which kind of return (object/cookie/tree)
    # is expected, and which runtime and memory limits were specified, if any.

    # Now we will check that this is really procedure_call message and that
    # the procedure is allowed, that is, it is from scscp{1,2} or scscp_transient_X CD

    if SCSCPserverMode then

        SCSCP_UNBIND_MODE := false;
        SCSCP_STORE_SESSION_MODE := true;

        pos:=PositionProperty( node.content[1].content, r -> r.name="OMA");	# expected scscp1.procedure_call
        if pos=fail then
            return rec( object := [ "Message rejected: it must be a proper scscp1.procedure_call" ],
                        attributes := attrs, is_error:=true );
        else
            node.content[1].content[pos].content :=
              Filtered( node.content[1].content[pos].content, OMIsNotDummyLeaf );
            if not IsBound( node.content[1].content[pos].content[1] ) or
               not IsBound( node.content[1].content[pos].content[1].attributes ) or
               not node.content[1].content[pos].content[1].attributes in
               [ rec( name := "procedure_call", cd := "scscp1" ),
                 rec( name := "procedure_completed", cd := "scscp1" ),
                 rec( name := "procedure_terminated", cd := "scscp1") ]
              then
                return rec( object := [ "Message rejected because it is not a proper scscp1.procedure_call" ],
                            attributes := attrs, is_error:=true );
            else
                node.content[1].content[pos].content[2].content :=
                  Filtered( node.content[1].content[pos].content[2].content, OMIsNotDummyLeaf );
                if not IsBound( node.content[1].content[pos].content[2].content[1] ) or
                   not IsBound( node.content[1].content[pos].content[2].content[1].attributes ) or
                   not IsBound( node.content[1].content[pos].content[2].content[1].attributes.cd ) then
                    return rec( object := [ "Message rejected because it is not properly formatted" ],
                                attributes := attrs, is_error:=true );
                elif SCSCPserverAcceptsOnlyTransientCD and
                  # check that we are not parsing procedure_completed message
                  # while resolving a reference to a remote object
                  not node.content[1].content[pos].content[1].attributes =
                      rec( name := "procedure_completed", cd := "scscp1" ) and
                  ( Length( node.content[1].content[pos].content[2].content[1].attributes.cd ) < 5 or
                    not node.content[1].content[pos].content[2].content[1].attributes.cd{[1..5]} = "scscp" ) then
                    return rec( object := [
                                   "Message rejected because the procedure ",
                                   node.content[1].content[pos].content[2].content[1].attributes.cd, ".",
                                   node.content[1].content[pos].content[2].content[1].attributes.name,
                                   " is not allowed"],
                                attributes := attrs, is_error:=true );
                else
                    # some checks for some particular special procedures might be here
                    if node.content[1].content[pos].content[2].content[1].attributes.cd = "scscp2" then
                        name := node.content[1].content[pos].content[2].content[1].attributes.name;
                        if name = "unbind" then
                            SCSCP_UNBIND_MODE := true;
                        elif name = "store_persistent" then
                            SCSCP_STORE_SESSION_MODE := false;
                        fi;
                    fi;
                fi;
            fi;
        fi;

    fi;

    # if the security check is done, we may proceed
    if ForAny( attrs, t -> t[1]="option_return_deferred" ) then
        return_deferred := true;
    else
        return_deferred := false;
    fi;

    if return_tree or return_deferred then
        obj := node.content[1];
    else
        obj := OMParseXmlObj( node.content[1] );
    fi;

    # the next check was is a temporary measure to verify that
    # attributes were identified properly

    #if OMTempVars.OMATTR <> rec() then
    #  if OMParseXmlObj( OMTempVars.OMATTR ) <> attrs then
    #    Error("Attributes were not properly identified:\n",
    #    "OMParseXmlObj( OMTempVars.OMATTR ) = ", OMParseXmlObj( OMTempVars.OMATTR ), "\n",
    #    "attrs = ", attrs );
    #  fi;
    #fi;

    return rec( object:=obj, attributes:=attrs );
end );


#############################################################################
##
##  OMObjects.OMATTR( node )
##
##  we overwrite the OpenMath function OMObjects.OMATTR with our definition
##  (if OMObjects.OMATTR will be called from OpenMath, the OMTempWars.OMATTR
##  will be ignored)
##
OMObjects.OMATTR := function ( node )
OMTempVars.OMATTR:=Filtered( node.content, 
                    function ( x )
                    return x.name = "OMATP";
                    end )[1];                  
node.content := Filtered( node.content, 
                    function ( x )
                    return x.name <> "OMATP";
                    end );
return OMParseXmlObj( node.content[1] );
end;


#############################################################################
##
##  OMObjects.OMATP( node )
##
##  We add OMObjects.OMATP function to the list of functions OMObjects
##  defined as a global variable in the OpenMath package
## 
OMObjects.OMATP := function ( node )
local i;
#DisplayXMLStructure(node);
return List( [1,3..Length(node.content)-1], i -> 
             [ OMParseXmlObj(node.content[i]), OMParseXmlObj(node.content[i+1]) ] );
end;


#############################################################################
##
##  OMObjects.OMR( node )
##
##  This overwrites OMObjects.OMR defined in OpenMath package as
##  return OMTempVars.OMREF.(node.attributes.href);
## 
OMObjects.OMR := function ( node )
local ref, pos1, pos2, pos3, name, server, port;
if IsBound( node.attributes.href ) then
  ref := node.attributes.href;
  pos1:=PositionSublist( ref, "://" );
  pos2:=PositionNthOccurrence( ref, ':', 2);
  if pos1=fail then
    # reference to an object within the same OpenMath document 
    if ref[1]=CHAR_INT(35) then
      return OMTempVars.OMREF.(ref{[2..Length(ref)]});
    else
      Error( "OpenMath reference: the first symbol must be ", CHAR_INT(35), "\n" ); 
    fi;
  elif pos2=fail then
    # reference to an object in a file
    Error("References to files are not implemented yet");
  else
    # reference to a remote object
    if not ref{[1..pos1+2]} = "scscp://" then
    	Error("Can not parse the reference ", ref, "\n");
    fi;
    pos3 := PositionNthOccurrence( ref, '/', 3);
    server:=ref{[pos1+3..pos2-1]};
    port:=Int(ref{[pos2+1..pos3-1]});
    name := ref{[pos3+1..Length(ref)]};
    if SCSCPserverMode then
      # check that the object is on the same server
      if [server,port]=[SCSCPserverAddress,SCSCPserverPort] then
        if IsBoundGlobal( name ) and
           Length( name ) > 12 and
           StartsWith( name, "TEMPVarSCSCP" ) then
          if SCSCP_UNBIND_MODE then
            SCSCP_UNBIND_MODE := false;
          	return name;
          else
          	return EvalString( name );
          fi;	
        else
          Error( "Client request refers to an unbound variable ", node.attributes.href, "\n");
        fi;    
      else # for a "foreign" object
        return EvaluateBySCSCP( "retrieve", [ RemoteObject(name,server,port) ], server, port ).object;
      fi;    
    else # in the client's mode
      return RemoteObject( node.attributes.href, server, port );
    fi;
  fi;
else
  Error( "OpenMath reference: only href is supported !\n");
fi;  
end; 


#############################################################################
##
##  OMPutProcedureCall ( stream, proc_name, objrec : cd:=cdname )
## 
##  The first argument is a stream
##  The second argument is procedure name as a string.
##  The third is a record similar to those returned by
##  OMGetObjectWithAttributes, but the objrec.object a list
##  of arguments, for example:
##  rec ( object := [ SmallGroup(24,12) ],
##    attributes := [ [ "option_runtime", 1000 ],
##                    [ "call_id", "user007" ] ] )
##
InstallGlobalFunction( OMPutProcedureCall,
function( stream, proc_name, objrec )
local writer, cdname, debug_option, has_attributes, attr, nameandargs;
if IN_SCSCP_BINARY_MODE then
	writer:=OpenMathBinaryWriter(stream);
else 
	writer:=OpenMathXMLWriter(stream);
fi;
if IsClosedStream( stream )  then
  Error( "OMPutProcedureCall: the 1st argument <proc_name> must be an open stream \n" );
fi;

if IsBound( objrec.object ) and not IsList( objrec.object ) then
  Error( "OMPutProcedureCall: in the 3rd argument <objrec.object> must be a list \n" );
fi;

if IsOutputTextStream( stream )  then
  SetPrintFormattingStatus( stream, false );
fi;

if ValueOption("cd") <> fail then
  cdname := ValueOption("cd");
  if cdname="" then
    cdname := "scscp_transient_1";
  fi;  
else
  cdname := "scscp_transient_1";
fi;

if ValueOption("debuglevel") <> fail then
  debug_option := ValueOption("debuglevel");
else
  debug_option := 0;
fi;

OMIndent := 0;
if IN_SCSCP_TRACING_MODE then SCSCPTraceSendMessage( stream![3][1] ); fi;
WriteLine( stream, "<?scscp start ?>" );
OMPutOMOBJ( writer );
if IsBound(objrec.attributes) and Length(objrec.attributes)>0 then
  has_attributes:=true;
  OMPutOMATTR( writer );
  OMPutOMATP( writer );
  for attr in objrec.attributes do
    OMPutSymbol( writer, "scscp1", attr[1] );
    if attr[1] in [ "call_id", "option_min_memory", "option_max_memory",
                      "option_runtime", "option_debuglevel" ] then
      OMPut( writer, attr[2] );
    elif attr[1] in [ "option_return_object", 
                      "option_return_cookie",
                      "option_return_nothing",
                      "option_return_deferred" ] then
      OMPut( writer, "" );
    else
      Error("Unsupported option : ", attr[1], "\n" );
    fi;
  od;
  OMPutEndOMATP( writer );
else
  has_attributes:=false;
fi;
OMPutOMA( writer );
OMPutSymbol( writer, "scscp1", "procedure_call" );
if proc_name in [ "get_allowed_heads", 
                  "get_service_description", 
                  "get_signature", 
                  "get_transient_cd", 
                  "is_allowed_head", 
                  "retrieve", 
                  "store_session", 
                  "store_persistent", 
                  "unbind" ] then
  OMPutApplication( writer, "scscp2", proc_name, objrec.object );
else
  OMPutApplication( writer, cdname, proc_name, objrec.object );
fi;
OMPutEndOMA( writer );
if has_attributes then
  OMPutEndOMATTR( writer );
fi;
OMPutEndOMOBJ( writer );
WriteLine( stream, "<?scscp end ?>" );
if IsInputOutputTCPStream( stream ) then
  IO_Flush( stream![1] );
fi;
return true;
end);


#############################################################################
##
##  OMPutProcedureCompleted ( stream, objrec )
## 
##  The first argument is a stream
##  The second argument is a record like the one returned by
##  OMGetObjectWithAttributes, for example:
##  rec ( object := 120,
##    attributes := [ [ "info_runtime", 1000 ], 
##                    [ "info_memory", 2048 ],
##                    [ "call_id", "user007" ] ] )
##
InstallGlobalFunction( OMPutProcedureCompleted,
function( stream, objrec )
local writer, has_attributes, attr;
if IN_SCSCP_BINARY_MODE then
	writer:=OpenMathBinaryWriter(stream);
else 
	writer:=OpenMathXMLWriter(stream);
fi;
if IsClosedStream( stream )  then
  Error( "closed stream" );
fi;
if IsOutputTextStream( stream )  then
  SetPrintFormattingStatus( stream, false );
fi;
OMIndent := 0;
if IN_SCSCP_TRACING_MODE then SCSCPTraceSendMessage(0); fi;
WriteLine( stream, "<?scscp start ?>" );
OMPutOMOBJ( writer );
if IsBound(objrec.attributes) and Length(objrec.attributes)>0 then
  has_attributes:=true;
  OMPutOMATTR( writer );
  OMPutOMATP( writer );
  for attr in objrec.attributes do
  	if attr[1] in [ "call_id", "info_memory", "info_message", "info_runtime" ] then
      OMPutSymbol( writer, "scscp1", attr[1] );
      OMPut( writer, attr[2] );
    else
      Error("Unsupported attribute : ", attr[1], "\n" );
    fi;
  od;
  OMPutEndOMATP( writer );
else
  has_attributes:=false;
fi;
if IsBound(objrec.object) then
  OMPutApplication( writer, "scscp1", "procedure_completed", [ objrec.object ] );
else
  OMPutApplication( writer, "scscp1", "procedure_completed", [ ] );
fi;  
if has_attributes then
  OMPutEndOMATTR( writer );
fi;
OMPutEndOMOBJ( writer );
WriteLine( stream, "<?scscp end ?>" );
if IsInputOutputTCPStream( stream ) then
  IO_Flush( stream![1] );
fi;
return true;
end);


#############################################################################
##
##  OMPutProcedureTerminated( stream, objrec, error_cd, error_type )
## 
##  The first argument is a stream
##  The second argument is a record like the one returned by
##  OMGetObjectWithAttributes, for example:
##  rec (  attributes := [ [ "info_runtime", 1000 ], 
##                         [ "info_memory", 2048 ],
##                         [ "call_id", "user007" ] ],
##  object := "localhost:26133 reports : Rational operations: <divisor> must not be zero")
##  The third argument is a string with CD name for the fourth argument.
##  The fourth argument is a string with error type, for example
##  "error_memory", "error_runtime", "error_system_specific" as defined
##  in the 'scscp1' OM CD.
##
InstallGlobalFunction( OMPutProcedureTerminated,
function( stream, objrec, error_cd, error_type )
local writer, has_attributes, attr;
if IN_SCSCP_BINARY_MODE then
	writer:=OpenMathBinaryWriter(stream);
else 
	writer:=OpenMathXMLWriter(stream);
fi;
if IsClosedStream( stream )  then
  Error( "closed stream" );
fi;
if IsOutputTextStream( stream )  then
  SetPrintFormattingStatus( stream, false );
fi;
OMIndent := 0;
if IN_SCSCP_TRACING_MODE then SCSCPTraceSendMessage(0); fi;
WriteLine( stream, "<?scscp start ?>" );
OMPutOMOBJ( writer );
if IsBound(objrec.attributes) and Length(objrec.attributes)>0 then
  has_attributes:=true;
  OMPutOMATTR( writer );
  OMPutOMATP( writer );
  for attr in objrec.attributes do
    if attr[1] in [ "call_id", "info_memory", "info_runtime" ] then
    	OMPutSymbol( writer, "scscp1", attr[1] );
    	OMPut( writer, attr[2] );
    else
      Error("Unsupported attribute : ", attr[1], "\n" );
    fi;
  od;
  OMPutEndOMATP( writer );
else
  has_attributes:=false;
fi;
OMPutOMA( writer );
OMPutSymbol( writer, "scscp1", "procedure_terminated" );
OMPutError( writer, error_cd, error_type, [ objrec.object ] );
OMPutEndOMA( writer );
if has_attributes then
  OMPutEndOMATTR( writer );
fi;
OMPutEndOMOBJ( writer );
WriteLine( stream, "<?scscp end ?>" );
if IsInputOutputTCPStream( stream ) then
  IO_Flush( stream![1] );
fi;
return true;
end);

###########################################################################
##
#E 
##
