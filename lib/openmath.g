#############################################################################
##
#W openmath.g               The SCSCP package             Alexander Konovalov
#W                                                               Steve Linton
##
#H $Id$
##
#############################################################################


#############################################################################
##
#F  OMgapRPC( <x> )
##
InstallGlobalFunction( OMgapRPC,
function( x )
# x is already the result of evaluation of the OM object
return x[1];
end);


##############################################################################
#
# SCSCP_RETRIEVE( <varnameasstring> )
#
InstallGlobalFunction( SCSCP_RETRIEVE,
function( varnameasstring )
if IsBoundGlobal( varnameasstring[1] ) then
  return EvalString( varnameasstring[1] );
else
  Error( "Unbound global variable ", varnameasstring[1], "\n" );
fi;
end);


##############################################################################
#
# SCSCP_STORE( <obj> )
#
InstallGlobalFunction( SCSCP_STORE, x -> x[1] );


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
local s,t, omstr;
if x <> [] then 
  Print( "WARNING: get_allowed_heads has no arguments, but called with argument ", x, 
         " which will be ignored!\n");
fi;
omstr:="<OMA>\n";
Append( omstr, "<OMS cd=\"scscp2\" name=\"symbol_set\"/>\n" );
for s in OMsymTable do
  for t in s[2] do
    Append( omstr, Concatenation( "<OMS cd=\"", s[1], "\" name=\"", t[1], "\"/>\n" ) );
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
tran := First( OMsymTable, s -> s[1]=x[1] );
if tran = fail then
    return false;
else
    symb := First( tran[2], t -> t[1]=x[2] );
    if symb=fail then
        return false;
    else
        return true;
    fi;
fi;        
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
Append( omstr, "<OMSTR>GAP</OMSTR>\n" );
Append( omstr, Concatenation("<OMSTR>", VERSION, "</OMSTR>\n" ) );
Append( omstr, Concatenation("<OMSTR>", SCSCPserverDescription, "</OMSTR>\n" ) );
Append( omstr, "</OMA>" );
return OMPlainString( omstr );
end);


##############################################################################
#
# SCSCP_GET_TRANSIENT_CD( <x> )
#
InstallGlobalFunction( SCSCP_GET_TRANSIENT_CD,
function( x )
local tran, s, omstr, t;
tran := First( OMsymTable, s -> s[1]=x[1] );
if tran = fail then
    Error("no_such_transient_cd");
else
    omstr:="<CD>\n<CDName>scscp_transient_1</CDName>\n";
    Append( omstr, Concatenation( "<CDReviewDate>", DateISO8601(), "</CDReviewDate>\n" ) );
    Append( omstr, Concatenation( "<CDDate>", DateISO8601(), "</CDDate>\n" ) );
    Append( omstr, Concatenation( "<CDVersion>", "0", "</CDVersion>\n" ) );
    Append( omstr, Concatenation( "<CDRevision>", "0", "</CDRevision>\n" ) );
    Append( omstr, "<CDStatus>private</CDStatus>\n" );
    Append( omstr, "<Description>This is a transient content dictionary containing information about procedures offered by the GAP SCSCP service</Description>\n" );
    for t in tran[2] do
        Append( omstr, Concatenation( "<CDDefinition>\n", "<Name>",t[1], "</Name>\n" ) );
        Append( omstr, Concatenation( "<Role>application</Role>\n<Description>",t[3],"</Description>\n</CDDefinition>\n" ) );
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
local omstr, tran, s, symb, t;
tran := First( OMsymTable, s -> s[1]=x[1] );
if tran = fail then
    Error("no_such_transient_cd");
else
    symb := First( tran[2], t -> t[1]=x[2] );
    if symb=fail then
        Error("no_such_symbol");
    else
        omstr:="<OMA>\n<OMS cd=\"scscp2\" name=\"signature\"/>\n";
        Append( omstr, Concatenation( "<OMS cd=\"", x[1], "\" name=\"", x[2], "\"/>\n" ) );
        Append( omstr, Concatenation( OMString( symb[4] : noomobj ), "\n" ) );
        Append( omstr, Concatenation( OMString( symb[5] : noomobj ), "\n" ) );
        Append( omstr, "<OMS cd=\"scscp2\" name=\"symbol_set_all\"/>\n" );
        Append( omstr, "</OMA>" );
        return OMPlainString( omstr );
    fi;
fi;        
end);


#############################################################################
##
##  Extending global variable OMsymTable defined in OpenMath package
##
Add( OMsymTable, [ "scscp1", [ 
    ["procedure_call", OMgapRPC ],
    ["procedure_completed", x -> x[1] ],
    ["procedure_terminated", x -> x[1] ],
    ["call_id", "call_id" ],
    ["info_memory", "info_memory" ],
    ["info_runtime", "info_message" ],
    ["info_runtime", "info_runtime" ],
    ["option_debuglevel", "option_debuglevel" ],
    ["option_max_memory", "option_max_memory" ],
    ["option_min_memory", "option_min_memory" ],
    ["option_return_cookie", "option_return_cookie" ],
    ["option_return_object", "option_return_object" ],
    ["option_return_nothing", "option_return_nothing" ],
    ["option_runtime", "option_runtime" ],
    ["error_CAS", "error_CAS" ]
    ] ] );

Add( OMsymTable, [ "scscp2", [ 
    [ "store", SCSCP_STORE ],
    [ "retrieve", SCSCP_RETRIEVE ],
    [ "unbind", SCSCP_UNBIND ],
    [ "get_allowed_heads", SCSCP_GET_ALLOWED_HEADS ],
    [ "is_allowed_head", SCSCP_IS_ALLOWED_HEAD ],
    [ "get_service_description", SCSCP_GET_SERVICE_DESCRIPTION ],
    [ "get_transient_cd", SCSCP_GET_TRANSIENT_CD ],
    [ "get_signature", SCSCP_GET_SIGNATURE ]
    ] ] );
    
# TODO: add to scscp2 Special symbols:
# symbol_set
# symbol_set_all
# signature
# service_description
# no_such_transient_cd
    

BindGlobal("OMgapCDName",
	function( x )
	return x[1];
	end);

    
Add( OMsymTable, [ "meta", [ 
    [ "CDName", OMgapCDName ]
    ] ] );    
    

        

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
##  This is a counterpart of the function OpenMath function OMGetObject.
##
InstallGlobalFunction( OMGetObjectWithAttributes,
function( stream )
    local return_tree,
          fromgap, # string
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
    
    fromgap := "";

    # Get one OpenMath object from 'stream' and put into 'fromgap',
    # using PipeOpenMathObject
    
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
    
    success := PipeOpenMathObject( stream, fromgap );

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

    # this means XML encoding
    if fromgap[1] = '<' and OMgetObjectXMLTree <> ReturnFail  then
        # This is the only difference from OMGetObject
        if return_tree then
            return OMgetObjectXMLTreeWithAttributes( fromgap : return_tree );
        else
            return OMgetObjectXMLTreeWithAttributes( fromgap );
        fi;    
    else
        return OMpipeObject( fromgap );
    fi;
end );


#############################################################################
##
#F OMgetObjectXMLTreeWithAttributes(string)
##
## This is a counterpart of the OpenMath function OMgetObjectXMLTree
##
InstallGlobalFunction( OMgetObjectXMLTreeWithAttributes,
    function ( string )
    local return_tree, node, attrs, t, obj;
    
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
       
    # Now we already know attributes BEFORE the the real computation is started.
    # This allows us to know in advance which kind of return (object/cookie/tree)
    # is expected, and which runtime and memory limits were specified, if any.
        
    if return_tree then
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
OMObjects.OMR := function ( node )
local ref, pos1, pos2, name, address, port;
if IsBound( node.attributes.xref ) then
  ref := node.attributes.xref;
  pos1:=Position( ref, '@' );
  pos2:=Position( ref, ':' );
  name := ref{[1..pos1-1]};
  address:=ref{[pos1+1..pos2-1]};
  port:=Int(ref{[pos2+1..Length(ref)]});
  if SCSCPserverMode then
    if [address,port]=[SCSCPserverAddress,SCSCPserverPort] then
      if IsBound( node.attributes.xref ) then
        if IsBoundGlobal( name ) then
          return EvalString( name );
        else
          Error( "Client request refers to an unbound variable ", node.attributes.xref, "\n");
        fi;    
      elif IsBound( node.attributes.href ) then
        return OMTempVars.OMREF.(node.attributes.href);
      else
        Error("SCSCP:OMObjects.OMR : can not handle OMR in ", node, "\n");
      fi;
    else
      return EvaluateBySCSCP( "retrieve", [ name ], address, port ).object;
    fi;        
  else
    return node.attributes.xref;
  fi;
elif IsBound( node.attributes.href ) then
  ref := node.attributes.href;
  # we assume that the first symbol is hash '#'
  return OMTempVars.OMREF.(ref{[2..Length(ref)]});
else
  Error( "OpenMath reference: only href and xref are supported !\n");
fi;  
end; 
   

#############################################################################
##
##  OMPutProcedureCall ( stream, proc_name, objrec : omcd:=omcdname )
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
local omcdname, has_attributes, attr, nameandargs;

if IsClosedStream( stream )  then
  Error( "OMPutProcedureCall: the 2nd argument <proc_name> must be a string \n" );
fi;

if IsBound( objrec.object ) and not IsList( objrec.object ) then
  Error( "OMPutProcedureCall: in the 3nd argument <objrec.object> must be a list \n" );
fi;

if IsOutputTextStream( stream )  then
  SetPrintFormattingStatus( stream, false );
fi;

if ValueOption("omcd") <> fail then
  omcdname := ValueOption("omcd");
  if omcdname="" then
    omcdname := "scscp_transient_1";
  fi;  
else
  omcdname := "scscp_transient_1";
fi;

OMIndent := 0;
WriteLine( stream, "<?scscp start ?>" );
OMWriteLine( stream, [ "<OMOBJ>" ] );
if IsBound(objrec.attributes) and Length(objrec.attributes)>0 then
  has_attributes:=true;
  OMIndent := OMIndent + 1;
  OMWriteLine( stream, [ "<OMATTR>" ] );
  OMIndent := OMIndent + 1;
  OMWriteLine( stream, [ "<OMATP>" ] );
  OMIndent := OMIndent + 1;
  for attr in objrec.attributes do
    OMPutSymbol( stream, "scscp1", attr[1] );
    if attr[1]="call_id" then
      OMWriteLine( stream, [ "<OMSTR>", attr[2], "</OMSTR>" ] );
    elif attr[1] in [ "option_min_memory", "option_max_memory",
                      "option_runtime", "option_debuglevel" ] then
      OMWriteLine( stream, [ "<OMI>", attr[2], "</OMI>" ] );                      
    elif attr[1] in [ "option_return_object", 
                      "option_return_cookie",
                      "option_return_nothing" ] then
      OMWriteLine( stream, [ "<OMSTR></OMSTR>" ] );
    else
      Error("Unsupported option : ", attr[1], "\n" );
    fi;
  od;
  OMIndent := OMIndent - 1;    
  OMWriteLine( stream, [ "</OMATP>" ] );
  OMIndent := OMIndent - 1;
else
  has_attributes:=false;
fi;
OMIndent := OMIndent + 1;
OMWriteLine( stream, [ "<OMA>" ] );
OMIndent := OMIndent + 1;
OMPutSymbol( stream, "scscp1", "procedure_call" );
if proc_name in [ "get_allowed_heads", "get_service_description", 
                  "get_signature", "get_transient_cd", "is_allowed_head", 
                  "retrieve", "store", "unbind" ] then
  OMPutApplication( stream, "scscp2", proc_name, objrec.object );
else
  OMPutApplication( stream, omcdname, proc_name, objrec.object );
fi;
OMIndent := OMIndent - 1;
OMWriteLine( stream, [ "</OMA>" ] );
OMIndent := OMIndent - 1;
if has_attributes then
  OMWriteLine( stream, [ "</OMATTR>" ] );
  OMIndent := OMIndent - 1;
fi;
OMWriteLine( stream, [ "</OMOBJ>" ] );
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
local has_attributes, attr;
if IsClosedStream( stream )  then
  Error( "closed stream" );
fi;
if IsOutputTextStream( stream )  then
  SetPrintFormattingStatus( stream, false );
fi;
OMIndent := 0;
WriteLine( stream, "<?scscp start ?>" );
OMWriteLine( stream, [ "<OMOBJ>" ] );
if IsBound(objrec.attributes) and Length(objrec.attributes)>0 then
  has_attributes:=true;
  OMIndent := OMIndent + 1;
  OMWriteLine( stream, [ "<OMATTR>" ] );
  OMIndent := OMIndent + 1;
  OMWriteLine( stream, [ "<OMATP>" ] );
  OMIndent := OMIndent + 1;
  for attr in objrec.attributes do
    OMPutSymbol( stream, "scscp1", attr[1] );
    if attr[1]="call_id" then
      OMWriteLine( stream, [ "<OMSTR>", attr[2], "</OMSTR>" ] );
    elif attr[1] in [ "info_memory", "info_runtime" ] then
      OMWriteLine( stream, [ "<OMI>", attr[2], "</OMI>" ] );                      
    else
      Error("Unsupported attribute : ", attr[1], "\n" );
    fi;
  od;
  OMIndent := OMIndent - 1;    
  OMWriteLine( stream, [ "</OMATP>" ] );
  OMIndent := OMIndent - 1;
else
  has_attributes:=false;
fi;
OMIndent := OMIndent + 1;
OMPutApplication( stream, "scscp1", "procedure_completed", [ objrec.object ] );
OMIndent := OMIndent - 1;
if has_attributes then
  OMWriteLine( stream, [ "</OMATTR>" ] );
  OMIndent := OMIndent - 1;
fi;
OMWriteLine( stream, [ "</OMOBJ>" ] );
WriteLine( stream, "<?scscp end ?>" );
if IsInputOutputTCPStream( stream ) then
  IO_Flush( stream![1] );
fi;
return true;
end);


#############################################################################
##
##  OMPutError( stream, cd, name, list )
##
InstallGlobalFunction( OMPutError,
function ( stream, cd, name, list )
local  obj;
OMWriteLine( stream, [ "<OME>" ] );
OMIndent := OMIndent + 1;
OMPutSymbol( stream, cd, name );
for obj  in list  do
    OMPut( stream, obj );
od;
OMIndent := OMIndent - 1;
OMWriteLine( stream, [ "</OME>" ] );
return;
end);


#############################################################################
##
##  OMPutProcedureTerminated( stream, objrec, error_cd, error_type )
## 
##  The first argument is a stream
##  The second argument is a record like the one returned by
##  OMGetObjectWithAttributes, for example:
##  rec ( object := 120,
##    attributes := [ [ "info_runtime", 1000 ], 
##                    [ "info_memory", 2048 ],
##                    [ "call_id", "user007" ] ] )
##  The third argument is a string with CD name for the fourth argument.
##  The fourth argument is a string with error type, for example
##  "error_memory", "error_runtime", "error_system_specific" as defined
##  in the 'scscp1' OM CD.
##
InstallGlobalFunction( OMPutProcedureTerminated,
function( stream, objrec, error_cd, error_type )
local has_attributes, attr;
if IsClosedStream( stream )  then
  Error( "closed stream" );
fi;
if IsOutputTextStream( stream )  then
  SetPrintFormattingStatus( stream, false );
fi;
OMIndent := 0;
WriteLine( stream, "<?scscp start ?>" );
OMWriteLine( stream, [ "<OMOBJ>" ] );
if IsBound(objrec.attributes) and Length(objrec.attributes)>0 then
  has_attributes:=true;
  OMIndent := OMIndent + 1;
  OMWriteLine( stream, [ "<OMATTR>" ] );
  OMIndent := OMIndent + 1;
  OMWriteLine( stream, [ "<OMATP>" ] );
  OMIndent := OMIndent + 1;
  for attr in objrec.attributes do
    OMPutSymbol( stream, "scscp1", attr[1] );
    if attr[1]="call_id" then
      OMWriteLine( stream, [ "<OMSTR>", attr[2], "</OMSTR>" ] );
    elif attr[1] in [ "info_memory", "info_runtime" ] then
      OMWriteLine( stream, [ "<OMI>", attr[2], "</OMI>" ] );                      
    else
      Error("Unsupported attribute : ", attr[1], "\n" );
    fi;
  od;
  OMIndent := OMIndent - 1;    
  OMWriteLine( stream, [ "</OMATP>" ] );
  OMIndent := OMIndent - 1;
else
  has_attributes:=false;
fi;
OMIndent := OMIndent + 1;
OMWriteLine( stream, [ "<OMA>" ] );
OMIndent := OMIndent + 1;
OMPutSymbol( stream, "scscp1", "procedure_terminated" );
OMPutError( stream, error_cd, error_type, [ objrec.object ] );
OMIndent := OMIndent - 1;
OMWriteLine( stream, [ "</OMA>" ] );
OMIndent := OMIndent - 1;
if has_attributes then
  OMWriteLine( stream, [ "</OMATTR>" ] );
  OMIndent := OMIndent - 1;
fi;
OMWriteLine( stream, [ "</OMOBJ>" ] );
WriteLine( stream, "<?scscp end ?>" );
if IsInputOutputTCPStream( stream ) then
  IO_Flush( stream![1] );
fi;
return true;
end);
