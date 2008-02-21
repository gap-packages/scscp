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
    function( arg ) 
    JUMP_TO_CATCH(arg[2]); 
    end );

#BIND_GLOBAL("ErrorInner",
#        function( arg )
#    local   context, mayReturnVoid,  mayReturnObj,  lateMessage,  earlyMessage,  
#            x,  prompt,  res, errorLVars, justQuit, printThisStatement;
#    if not IsRecord(arg[1]) then
#        # old calling convention to avoid breaking SCSCP
#        PrintTo("*errout*", "ErrorInner called with obsolete calling coventions\n");
#        
#        context := arg[1];
#        if not IsLVarsBag(context) then
#            PrintTo("*errout*", "ErrorInner: 1st argument (context) must be a local variables bag\n");
#            LEAVE_ALL_NAMESPACES();
#            JUMP_TO_CATCH(1);
#        fi; 
#        justQuit := arg[2];
#        if not justQuit in [false, true] then
#            PrintTo("*errout*", "ErrorInner: 2nd argument (justQuit) must be true or false\n");
#            LEAVE_ALL_NAMESPACES();
#            JUMP_TO_CATCH(1);
#        fi;
#        
#        mayReturnVoid := arg[3];
#        if not mayReturnVoid in [false, true] then
#            PrintTo("*errout*", "ErrorInner: 3rd argument (mayReturnVoid) must be true or false\n");
#            LEAVE_ALL_NAMESPACES();
#            JUMP_TO_CATCH(1);
#        fi;
#        mayReturnObj := arg[4];
#        if not mayReturnObj in [false, true] then
#            PrintTo("*errout*", "ErrorInner: 4th argument (mayReturnObj) must be true or false\n");
#            LEAVE_ALL_NAMESPACES();
#            JUMP_TO_CATCH(1);
#        fi;
#        lateMessage := arg[5];
#        if not lateMessage in [false, true] and not IsString(lateMessage) then
#            PrintTo("*errout*", "ErrorInner: 5th argument (lateMessage) must be a string or false\n");
#            LEAVE_ALL_NAMESPACES();
#            JUMP_TO_CATCH(1);
#        fi;
#        earlyMessage := arg{[6..Length(arg)]};
#        printThisStatement := true;
#    else
#        context := arg[1].context;
#        if not IsLVarsBag(context) then
#            PrintTo("*errout*", "ErrorInner:   option context must be a local variables bag\n");
#            LEAVE_ALL_NAMESPACES();
#            JUMP_TO_CATCH(1);
#        fi; 
#        
#        if IsBound(arg[1].justQuit) then
#            justQuit := arg[1].justQuit;
#            if not justQuit in [false, true] then
#                PrintTo("*errout*", "ErrorInner: option justQuit must be true or false\n");
#                LEAVE_ALL_NAMESPACES();
#                JUMP_TO_CATCH(1);
#            fi;
#        else
#            justQuit := false;
#        fi;
#        
#        if IsBound(arg[1].mayReturnVoid) then
#            mayReturnVoid := arg[1].mayReturnVoid;
#            if not mayReturnVoid in [false, true] then
#                PrintTo("*errout*", "ErrorInner: option mayReturnVoid must be true or false\n");
#                LEAVE_ALL_NAMESPACES();
#                JUMP_TO_CATCH(1);
#            fi;
#        else
#            mayReturnVoid := false;
#        fi;
#        
#        if IsBound(arg[1].mayReturnObj) then
#            mayReturnObj := arg[1].mayReturnObj;
#            if not mayReturnObj in [false, true] then
#                PrintTo("*errout*", "ErrorInner: option mayReturnObj must be true or false\n");
#                LEAVE_ALL_NAMESPACES();
#                JUMP_TO_CATCH(1);
#            fi;
#        else
#            mayReturnObj := false;
#        fi;
#        
#        if IsBound(arg[1].printThisStatement) then
#            printThisStatement := arg[1].printThisStatement;
#            if not printThisStatement in [false, true] then
#                PrintTo("*errout*", "ErrorInner: option printThisStatement must be true or false\n");
#                LEAVE_ALL_NAMESPACES();
#                JUMP_TO_CATCH(1);
#            fi;
#        else
#            printThisStatement := true;
#        fi;
#        
#        if IsBound(arg[1].lateMessage) then
#            lateMessage := arg[1].lateMessage;
#            if not lateMessage in [false, true] and not IsString(lateMessage) then
#                PrintTo("*errout*", "ErrorInner: option lateMessage must be a string or false\n");
#                LEAVE_ALL_NAMESPACES();
#                JUMP_TO_CATCH(1);
#            fi;
#        else
#            lateMessage := "";
#        fi;
#        
#        earlyMessage := arg[2];
#        if Length(arg) <> 2 then
#            PrintTo("*errout*","ErrorInner: new format takes exactly two arguments\n");
#            LEAVE_ALL_NAMESPACES();
#            JUMP_TO_CATCH(1);
#        fi;
#        
#    fi;
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
#        if ErrorLevel = 0 then LEAVE_ALL_NAMESPACES(); fi;
#        JUMP_TO_CATCH(0);
#    fi;
#    PrintTo("*errout*","Error, ");
#    for x in earlyMessage do
#        PrintTo("*errout*",x);
#    od;
#    if printThisStatement then 
#        if context <> GetBottomLVars() then
#            PrintTo("*errout*"," in\n  \c");
#            PRINT_CURRENT_STATEMENT(context);
#            Print("\c");
#            PrintTo("*errout*"," called from \n");
#        else
#            PrintTo("*errout*","\c\n");
#        fi;
#    else
#        PrintTo("*errout*"," called from\c\n");
#    fi;
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
#	if ErrorLevel = 0 then LEAVE_ALL_NAMESPACES(); fi;
#        if not justQuit then
#	   # dont try and do anything else after this before the longjump 	
#            SetUserHasQuit(1);	
#        fi;
#        JUMP_TO_CATCH(3);
#    fi;
#    if Length(res) > 0 then
#        return res[1];
#    else
#        return;
#    fi;
#end);