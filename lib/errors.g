#############################################################################
##
#W errors.g                 The SCSCP package             Alexander Konovalov
#W                                                               Steve Linton
##
#H $Id$
##
#############################################################################

MakeReadWriteGlobal( "ErrorInner" );
UnbindGlobal( "ErrorInner" );

BIND_GLOBAL( "ErrorInner",
    function(arg) 
    JUMP_TO_CATCH(arg); 
    end );

#BIND_GLOBAL("ErrorInner",
#        function( arg )
#    local   context, mayReturnVoid,  mayReturnObj,  lateMessage,  earlyMessage,  
#            x,  prompt,  res, errorLVars, justQuit;
#    Print("ErrorInner called with", arg, "\n");     
#    context := arg[1];
#    if not IsLVarsBag(context) then
#        PrintTo("*errout*", "ErrorInner: 1st argument (context) must be a local variables bag\n");
#    fi; 
#    justQuit := arg[2];
#    if not justQuit in [false, true] then
#        PrintTo("*errout*", "ErrorInner: 2nd argument (justQuit) must be true or false\n");
#        JUMP_TO_CATCH(1);
#    fi;
#    mayReturnVoid := arg[3];
#    if not mayReturnVoid in [false, true] then
#        PrintTo("*errout*", "ErrorInner: 3rd argument (mayReturnVoid) must be true or false\n");
#        JUMP_TO_CATCH(1);
#    fi;
#    mayReturnObj := arg[4];
#    if not mayReturnObj in [false, true] then
#        PrintTo("*errout*", "ErrorInner: 4th argument (mayReturnObj) must be true or false\n");
#        JUMP_TO_CATCH(1);
#    fi;
#    lateMessage := arg[5];
#    if not lateMessage in [false, true] and not IsString(lateMessage) then
#        PrintTo("*errout*", "ErrorInner: 5th argument (lateMessage) must be a string or false\n");
#        JUMP_TO_CATCH(1);
#    fi;
#    earlyMessage := arg{[6..Length(arg)]};
#    
#    ErrorLevel := ErrorLevel+1;
#    errorCount := errorCount+1;
#    errorLVars := ErrorLVars;
#    ErrorLVars := context;
#    if QUITTING or not BreakOnError then
#        PrintTo("*errout*","Error, ");
#        for x in earlyMessage do
#            PrintTo("*errout*",x);
#        od;
#        PrintTo("*errout*","\n");
#        ErrorLevel := ErrorLevel-1;
#        ErrorLVars := errorLVars;
#        JUMP_TO_CATCH(0);
#    fi;
#    PrintTo("*errout*","Error, ");
#    for x in earlyMessage do
#        PrintTo("*errout*",x);
#    od;
#    PrintTo("*errout*","\n");
#    if IsBound(OnBreak) and IsFunction(OnBreak) then
#        OnBreak();
#    fi;
#    if IsString(lateMessage) then
#        PrintTo("*errout*",lateMessage,"\n");
#    elif lateMessage then
#        if IsBound(OnBreakMessage) and IsFunction(OnBreakMessage) then
#            OnBreakMessage();
#        fi;
#    fi;
#    if ErrorLevel > 1 then
#        prompt := Concatenation("brk_",String(ErrorLevel),"> ");
#    else
#        prompt := "brk> ";
#    fi;
#    
#    # MODIFIED
#    justQuit:=true;
#
#    if not justQuit then
#        res := SHELL(context,mayReturnVoid,mayReturnObj,1,false,prompt,false,"*errin*","*errout*",false);
#    else
#        res := fail;
#    fi;
#    ErrorLevel := ErrorLevel-1;
#    ErrorLVars := errorLVars;
#    if res = fail then
#        if IsBound(OnQuit) and IsFunction(OnQuit) then
#            OnQuit();
#        fi;
#        JUMP_TO_CATCH(3);
#    fi;
#    if Length(res) > 0 then
#        return res[1];
#    else
#        return;
#    fi;
#end);