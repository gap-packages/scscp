###########################################################################
##
#W webservice.g             The SCSCP package            Olexandr Konovalov
#W                                                             Steve Linton
##
###########################################################################

###########################################################################
#
# InstallSCSCPprocedure( procname, procfunc 
#                        [, description ] [, narg1 [, narg2 ] [, signature ] ])
#
InstallGlobalFunction( InstallSCSCPprocedure, function( arg )
local procname, procfunc, procdesc, minarg, maxarg, signature, 
      nodesc, nonarg, nosig, pos, SCSCPprocTable, x, userinput, 
      answer, inforcemode;
      
# 
# Checking arguments
#

if ValueOption("force") <> fail then
  inforcemode := ValueOption("force");
else
  inforcemode := false;
fi;

nodesc := false;
nonarg := false;
nosig := false;
if Length( arg ) < 2 then
    Error( "InstallSCSCPprocedure must have at least two arguments:\n",
           "procedure name and the corresponding function\n");
fi;
if not IsString(arg[1]) then
    Error("InstallSCSCPprocedure: the 1st argument must be a string\n",
          "with the name of the procedure\n");
else  
    procname:=arg[1];
fi;
if not IsFunction(arg[2]) then
    Error("InstallSCSCPprocedure: the 2nd argument must be the function\n",
          "that will be called by the procedure\n");
else  
    procfunc:=arg[2];
fi;
if IsBound( arg[3] ) then
    if IsString( arg[3] ) then
        procdesc:=arg[3];
        pos:=4;
    elif IsInt( arg[3] ) then
        procdesc := Concatenation( procname, " is currently undocumented." );
        pos:=3;
    else 
        Error("InstallSCSCPprocedure: the 3rd argument must be either\n",
          "a string with the description of the procedure or\n",
          "a non-negative integer specifying the (minimal) number of its arguments!\n");
    fi;
    if IsBound( arg[pos] ) then
        if IsInt( arg[pos] ) then 
            if arg[pos]>=0 then
                minarg := arg[pos];  
            else
                Error("InstallSCSCPprocedure: the ", Ordinal(pos), 
                      " argument must be a non-negative integer!\n");
            fi;
        else
            Error("InstallSCSCPprocedure: the ", Ordinal(pos), 
                  " argument must be a non-negative integer,\n",
                  "it is not possible to specify the signature without ",
                  "at least the minimal number of arguments!\n" );
        fi;        
        if IsBound( arg[pos+1] ) then
            if IsInt( arg[pos+1] ) or IsInfinity( arg[pos+1] ) then       
                maxarg := arg[pos+1];   
                if maxarg < minarg then
                    Error("InstallSCSCPprocedure: the maximal number of ",
                      "arguments can not be smaller than their minimum number!\n");
                fi;
            else
                maxarg := minarg;
                signature := arg[pos+1];
            fi;
            if IsBound ( arg[pos+2] ) then  
                signature := arg[pos+2];  
            else # no arg[pos+2]
                nosig := true;
            fi; # is there arg[pos+2] ?
        else # no arg[pos+1]
            maxarg := minarg;
            nosig := true;
        fi; # is there arg[pos+1] ?
    else # no arg[pos];
        nonarg:=true;
        nosig := true; 
    fi; # is there arg[pos] ?
else # no arg[3]
    nodesc := true;
    nonarg := true;
    nosig := true;      
fi; # is there arg[3] ?

if nodesc then
    procdesc := Concatenation( procname, " is currently undocumented." );
fi;
if nonarg then
    minarg:=0;
    maxarg:=infinity; 
fi; 
if nosig then
    signature := rec();
fi;     
           
#
# Actual work
#

if not IsBound( OMsymRecord.scscp_transient_1 ) then
  OMsymRecord.scscp_transient_1 := rec();
fi;

if not IsBound( SCSCPtransientCDs.scscp_transient_1 ) then
  SCSCPtransientCDs.scscp_transient_1 := rec();
fi;  

if not IsBound( OMsymRecord.scscp_transient_1.(procname) ) or inforcemode then
	OMsymRecord.scscp_transient_1.(procname) := 
	  function(arg) return CallFuncList( procfunc, arg[1] ); end;
    SCSCPtransientCDs.scscp_transient_1.(procname) := rec(
    	Description := procdesc,
        Minarg := minarg,
        Maxarg := maxarg,
        Signature := signature );
    if not inforcemode then   
    	Info( InfoSCSCP, 1, "Installed SCSCP procedure ", procname ); 
    	Info( InfoSCSCP, 5, "  * ", procdesc );
    	Info( InfoSCSCP, 5, "  * Minimal number of arguments : ", minarg );
    	Info( InfoSCSCP, 5, "  * Maximal number of arguments : ", maxarg );
    	Info( InfoSCSCP, 5, "  * Signature : ", signature );
    fi;
else
  userinput := InputTextUser();
  repeat
    Print( procname ," is already installed. Do you want to reinstall it [y/n]? \c");
    answer := ReadLine( userinput );
    if answer="y\n" then
	  OMsymRecord.scscp_transient_1.(procname) := 
	    function(arg) return CallFuncList( procfunc, arg[1] ); end;
      SCSCPtransientCDs.scscp_transient_1.(procname) := rec(
    	Description := procdesc,
        Minarg := minarg,
        Maxarg := maxarg,
        Signature := signature );
      Print( "#I  Reinstalled SCSCP procedure ", procname ); 
      Info( InfoSCSCP, 2, "  * ", procdesc );
      Info( InfoSCSCP, 3, "  * Minimal number of arguments : ", minarg );
      Info( InfoSCSCP, 3, "  * Maximal number of arguments : ", maxarg );
      Info( InfoSCSCP, 4, "  * Signature : ", signature );
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


###########################################################################
##
#E 
##