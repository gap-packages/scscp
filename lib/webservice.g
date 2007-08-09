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
# SCSCPprocTable     : global variable, defined in init.g, with the list 
#                      of pairs [ procname, procfunc ]
#
InstallSCSCPprocedure := function( procname, procfunc )
local pos, userinput, answer;
pos:=PositionProperty( SCSCPprocTable, x -> x[1]= procname );
if pos=fail then
  MakeReadWriteGlobal("SCSCPprocTable");
  Add( SCSCPprocTable, [ procname, procfunc ] );
  MakeReadOnlyGlobal("SCSCPprocTable");
  Print("InstallSCSCPprocedure : procedure ", procname, " installed. \n" ); 
else
  userinput := InputTextUser();
  repeat
    Print( procname ," is already installed. Do you want to reinstall it [y/n]? \c");
    answer := ReadLine( userinput );
    if answer="y\n" then
      MakeReadWriteGlobal("SCSCPprocTable");
      SCSCPprocTable[pos][2] := procfunc;
      MakeReadOnlyGlobal("SCSCPprocTable");     
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
end;