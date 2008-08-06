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
local s,t;
return List( OMsymTable, s -> [ s[1], List( s[2], t -> t[1] ) ] );
end);

	
#############################################################################
##
##  Extending global variable OMsymTable defined in OpenMath package
##
Add( OMsymTable, [ "scscp1", [ 
    ["procedure_call", OMgapRPC ],
    ["procedure_completed", x -> x[1] ],
    ["procedure_terminated", x -> x[1] ],
    ["call_ID", "call_ID" ],
    ["info_memory", "info_memory" ],
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
    [ "get_allowed_heads", SCSCP_GET_ALLOWED_HEADS ]
    ] ] );
    
# TODO: add to scscp2 :
# * Determining supported procedures:
# get_allowed_heads
# get_transient_cd
# get_signature
# signature
# get_service_description
# service_description
#
# * Special symbols:
# symbol_set
# symbol_set_all
# no_such_transient_cd
        

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
##  [ ["call_ID", "user007" ], ["option_runtime", 300000] ]
##  This is a counterpart of the function OpenMath function OMGetObject.
##
InstallGlobalFunction( OMGetObjectWithAttributes,
function( stream )
    local
        fromgap, # string
        success, # whether PipeOpenMathObject worked
        readline;
        
    if IsClosedStream( stream )  then
        Error( "closed stream" );
    elif IsEndOfStream( stream )  then
        Error( "end of stream" );
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
        return OMgetObjectXMLTreeWithAttributes( fromgap );
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
    local  node, obj;

    OMTempVars.OMBIND := rec(  );
    OMTempVars.OMREF := rec(  );
    
    # This is the difference from OMgetObjectXMLTree
    OMTempVars.OMATTR := rec(  );

    node := ParseTreeXMLString( string ).content[1];

    node.content := Filtered( node.content, OMIsNotDummyLeaf );

    # Print( "ParseTreeXMLString( string ) = ", node.content, "\n" );
    # Error( "Error inserted by me to catch node.content \n" );
   
    obj := OMParseXmlObj( node.content[1] );
    
    # OMTempVars.OMATTR will be non-empty abter this, but this will also
    # enforce computation of 'obj'
    #TO-DO: We need to get attributes BEFORE the real computation is started
    #This will allow to understand earlier whether the result is a reference
    #or not. Of course, THIS can be known later, but what about such options
    #as the runtime and memory limits ???
    
    if OMTempVars.OMATTR <> rec() then
      return rec ( object:=obj, attributes:=OMParseXmlObj( OMTempVars.OMATTR ) );
    else
      return rec ( object:=obj, attributes:=[] );
    fi;         

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
      return EvaluateBySCSCP( "SCSCP_RETRIEVE", [ name ], address, port ).object;
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
##                    [ "call_ID", "user007" ] ] )
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
else
  omcdname := "SCSCP_transient_1";
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
    if attr[1]="call_ID" then
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
if proc_name in [ "store", "retrieve", "unbind", "get_allowed_heads" ] then
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
return;
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
##                    [ "call_ID", "user007" ] ] )
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
    if attr[1]="call_ID" then
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
return;
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
##  OMPutProcedureTerminated( stream, objrec, error_type )
## 
##  The first argument is a stream
##  The second argument is a record like the one returned by
##  OMGetObjectWithAttributes, for example:
##  rec ( object := 120,
##    attributes := [ [ "info_runtime", 1000 ], 
##                    [ "info_memory", 2048 ],
##                    [ "call_ID", "user007" ] ] )
##  The third argument is a string with error type, for example
##  "error_memory", "error_runtime", "error_system_specific" as defined
##  in the 'scscp1' OM CD.
##
InstallGlobalFunction( OMPutProcedureTerminated,
function( stream, objrec, error_type )
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
    if attr[1]="call_ID" then
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
OMPutError( stream, "scscp1", error_type, [ objrec.object ] );
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
return;
end);


#############################################################################
## 
## OMString
##
OMString := function ( x )
local str, outstream;
str := "";
outstream := OutputTextString( str, true );
OMPutObject( outstream, x );
CloseStream( outstream );
NormalizeWhitespace( str );
return str;
end;