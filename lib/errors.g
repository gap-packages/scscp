#############################################################################
##
#W errors.g                 The SCSCP package              Olexandr Konovalov
#W                                                               Steve Linton
##
#############################################################################

MakeReadWriteGlobal( "ErrorInner" );
UnbindGlobal( "ErrorInner" );

BindGlobal( "ErrorInner", function( arg ) 
   
        if not IsLVarsBag(arg[1].context) then
            PrintTo("*errout*", "ErrorInner:   option context must be a local variables bag\n");
            LEAVE_ALL_NAMESPACES();
            JUMP_TO_CATCH(1);
        fi; 
        
        if IsBound(arg[1].justQuit) then
            if not arg[1].justQuit in [false, true] then
                PrintTo("*errout*", "ErrorInner: option justQuit must be true or false\n");
                LEAVE_ALL_NAMESPACES();
                JUMP_TO_CATCH(1);
            fi;
        fi;
        
        if IsBound(arg[1].mayReturnVoid) then
            if not arg[1].mayReturnVoid in [false, true] then
                PrintTo("*errout*", "ErrorInner: option mayReturnVoid must be true or false\n");
                LEAVE_ALL_NAMESPACES();
                JUMP_TO_CATCH(1);
            fi;
        fi;
        
        if IsBound(arg[1].mayReturnObj) then
            if not arg[1].mayReturnObj in [false, true] then
                PrintTo("*errout*", "ErrorInner: option mayReturnObj must be true or false\n");
                LEAVE_ALL_NAMESPACES();
                JUMP_TO_CATCH(1);
            fi;
        fi;
        
        if IsBound(arg[1].printThisStatement) then
            if not arg[1].printThisStatement in [false, true] then
                PrintTo("*errout*", "ErrorInner: option printThisStatement must be true or false\n");
                LEAVE_ALL_NAMESPACES();
                JUMP_TO_CATCH(1);
            fi;
        fi;
        
        if IsBound(arg[1].lateMessage) then
            if not arg[1].lateMessage in [false, true] and not IsString(arg[1].lateMessage) then
                PrintTo("*errout*", "ErrorInner: option lateMessage must be a string or false\n");
                LEAVE_ALL_NAMESPACES();
                JUMP_TO_CATCH(1);
            fi;
        fi;
 
        if Length(arg) <> 2 then
            PrintTo("*errout*","ErrorInner: new format takes exactly two arguments\n");
            LEAVE_ALL_NAMESPACES();
            JUMP_TO_CATCH(1);
        fi;
         
    JUMP_TO_CATCH( arg[2] ); # arg[2] = earlyMessage in the library version of ErrorInner
    
    end );

###########################################################################
##
#E 
##