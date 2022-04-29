###########################################################################
##
#W special.g                The SCSCP package            Olexandr Konovalov
#W                                                             Steve Linton
##
###########################################################################


###########################################################################
#
# GetAllowedHeads( server, port )
#
InstallGlobalFunction( GetAllowedHeads, function( server, port )
local r, i, res;
r := EvaluateBySCSCP( "get_allowed_heads", 
                      [ ], server, port : output:="tree" ).object;
r := First( r.content, s -> s.name="OMA");
r := First( r.content, s -> s.name="OMA");
r := Filtered( r.content, OMIsNotDummyLeaf ); 
if r[1].attributes.name = "symbol_set" then
  res := rec();
  for i in [ 2.. Length(r) ] do
    if not IsBound( r[i].attributes.cd ) then
      # case of <OMA><OMS name="CDName" cd="meta"/><OMSTR>cdname</OMSTR></OMA>
      if IsBound(r[i].content) and Length(r[i].content)=2 then
        if r[i].content[1].attributes = rec( cd := "meta", name := "CDName" ) then
          res.(r[i].content[2].content[1].content) := true;
        else
	      Error( "Can not parse OpenMath object (expecting meta.CDName)\n" );
        fi;
      else
	    Error( "Can not parse OpenMath object! (expecting OMA with two children)\n" );
      fi;
    else
      if not IsBound( res.(r[i].attributes.cd ) )then
        res.( r[i].attributes.cd ) := [];
      fi;
      AddSet( res.( r[i].attributes.cd ), r[i].attributes.name );
    fi;
  od;  
  return res;
else
	Error( "Can not parse OpenMath object (expecting symbol_set)\n" );
fi;
end);


###########################################################################
#
# GetServiceDescription( server, port )
#
InstallGlobalFunction( GetServiceDescription, function( server, port )
local r;
r := EvaluateBySCSCP( "get_service_description", 
                      [ ], server, port : output:="tree" ).object;
r := First( r.content, s -> s.name="OMA");
r := First( r.content, s -> s.name="OMA");
r := Filtered( r.content, OMIsNotDummyLeaf ); 
if r[1].attributes.name = "service_description" then
  return rec( service_name := r[2].content[1].content,
                  version := r[3].content[1].content,
              description := r[4].content[1].content );
else
	Error( "Can not parse OpenMath object! \n" );
fi;
end);


###########################################################################
#
# GetSignature( cd, name, server, port )
#
InstallGlobalFunction( GetSignature, function( cd, name, server, port )
local r, ra, re;
r := EvaluateBySCSCP( "get_signature",
  [ OMPlainString( 
      Concatenation( "<OMS cd=\"", cd, "\" name=\"", name, "\"/>") ) ], 
  server, port : return_tree ).object;
r := First( r.content, s -> s.name="OMA");
ra := First( r.content, s -> s.name="OMA");
if ra = fail then
  re := First( r.content, s -> s.name="OME");
  r := Filtered( re.content, OMIsNotDummyLeaf ); 
  if r[1].attributes.name = "error_system_specific" then
    Error( r[2].content[1].content );
  else
	  Error( "Can not parse OpenMath object! \n" );
  fi; 
else
  r := Filtered( ra.content, OMIsNotDummyLeaf ); 
  if r[1].attributes.name = "signature" then
    return rec( symbol := r[2].attributes,
                minarg := OMParseXmlObj( r[3] ),
                maxarg := OMParseXmlObj( r[4] ),
                symbolargs := r[5].attributes );
  else
	  Error( "Can not parse OpenMath object! \n" );
  fi;
fi;  
end);


###########################################################################
#
# GetTransientCD( cdname, server, port )
#
InstallGlobalFunction( GetTransientCD, function( cdname, server, port )
local r, rcd, re, i, j, res, t, defs, d;
r := EvaluateBySCSCP( "get_transient_cd",
  [ OMPlainString( 
      Concatenation( "<OMA><OMS name=\"CDName\" cd=\"meta\"/><OMSTR>", 
                     cdname, "</OMSTR></OMA>" ) ) ], 
  server, port : return_tree ).object;
r := First( r.content, s -> s.name="OMA");
rcd := First( r.content, s -> s.name="CD");
if rcd = fail then
  re := First( r.content, s -> s.name="OME");
  r := Filtered( re.content, OMIsNotDummyLeaf ); 
  if r[1].attributes.name = "error_system_specific" then
    Error( r[2].content[1].content );
  else
	  Error( "Can not parse OpenMath object! \n" );
  fi; 
else
  r := Filtered( rcd.content, OMIsNotDummyLeaf ); 
  if r[1].name = "CDName" then
    res := rec();
    defs := [];
    for i in [ 1 .. Length(r) ] do
      if r[i].name = "CDDefinition" then
        t := Filtered( r[i].content, OMIsNotDummyLeaf ); 
        d := rec();
        for j in [ 1 .. Length(t) ] do
          if t[j].name = "Name" then
            d.Name := t[j].content[1].content;
          elif t[j].name = "Description" then
            d.Description := t[j].content[1].content;
          else
            Error("unhandled element in ", t[j], "\n" );	
          fi;  
        od;
        Add( defs, d );
      elif r[i].name = "CDName" then
		res.CDName := r[i].content[1].content;
	  elif r[i].name = "CDReviewDate" then
		res.CDReviewDate := r[i].content[1].content;
	  elif r[i].name = "CDDate" then
		res.CDDate := r[i].content[1].content;	
	  elif r[i].name = "CDVersion" then
		res.CDVersion := r[i].content[1].content;	
	  elif r[i].name = "CDRevision" then
		res.CDRevision := r[i].content[1].content;	
	  elif r[i].name = "CDStatus" then
		res.CDStatus := r[i].content[1].content;	
	  elif r[i].name = "Description" then
		res.Description := r[i].content[1].content;	
	  else
		Error("unhandled element in the retrieved content dictionary ", 
		      cdname, "\n" );	
      fi;
    od;  
    res.CDDefinitions := defs;
    return res;
  else
	Error( "Can not parse OpenMath object! \n" );
  fi;
fi;
end);


###########################################################################
#
# IsAllowedHead( cd, name, server, port )
#
InstallGlobalFunction( IsAllowedHead, function( cd, name, server, port )
return EvaluateBySCSCP( "is_allowed_head",
  [ OMPlainString( Concatenation( "<OMS cd=\"", cd, "\" name=\"", name, "\"/>") ) ], 
  server, port ).object;
end);

###########################################################################
##
#E 
##