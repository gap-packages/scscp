#############################################################################
##
#W webservice.g             The SCSCP package             Alexander Konovalov
#W                                                               Steve Linton
##
#H $Id$
##
#############################################################################

##############################################################################
#
# InstallSCSCPprocedure( procname, procfunc )
#
# procname           : a string with the name of the procedure
# procfunc           : the function that will be called by the procedure
#
InstallGlobalFunction( InstallSCSCPprocedure,
function( procname, procfunc )
local pos, SCSCPprocTable, x, userinput, answer;
pos := PositionProperty( OMsymTable, x -> x[1]="SCSCP_transient_1" );
if pos = fail then
  pos := Length(OMsymTable) + 1;
  OMsymTable[pos] := [ "SCSCP_transient_1", [ ] ];
fi;
SCSCPprocTable := OMsymTable[ pos ][2];
pos:=PositionProperty( SCSCPprocTable, x -> x[1]=procname );
if pos=fail then
  Add( SCSCPprocTable, [ procname, function(arg) return CallFuncList( procfunc, arg[1] ); end ] );
  Print("InstallSCSCPprocedure : procedure ", procname, " installed. \n" ); 
else
  userinput := InputTextUser();
  repeat
    Print( procname ," is already installed. Do you want to reinstall it [y/n]? \c");
    answer := ReadLine( userinput );
    if answer="y\n" then
      SCSCPprocTable[pos][2] := procfunc;
      Print("InstallSCSCPprocedure : procedure ", procname, " reinstalled. \n" ); 
      break;
    elif answer="n\n" then
      Print("InstallSCSCPprocedure : nothing to install. \n" );
      break;
    else
      Print("You must enter only y or n. Re-enter your answer, please! \n");
    fi;
  until answer in [ "y\n", "n\n" ];
  CloseStream( userinput );
fi;
end);


##############################################################################
#
# SCSCP_RETRIEVE( <varnameasstring> )
#
InstallGlobalFunction( SCSCP_RETRIEVE,
function( varnameasstring )
if IsBoundGlobal( varnameasstring ) then
  return EvalString( varnameasstring );
else
  Error( "Unbound global variable ", varnameasstring, "\n" );
fi;
end);


##############################################################################
#
# SCSCP_STORE( <obj> )
#
InstallGlobalFunction( SCSCP_STORE, x -> x );


##############################################################################
#
# SCSCP_UNBIND( <varnameasstring> )
#
InstallGlobalFunction( SCSCP_UNBIND,
function( varnameasstring )
UnbindGlobal( varnameasstring );
return not IsBoundGlobal( varnameasstring );
end);