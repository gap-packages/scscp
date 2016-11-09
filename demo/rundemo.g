LogTo();

if not IsBound( Demonstration ) then
	ReadLib("demo.g");
fi;	

MakeReadWriteGlobal("Demonstration");
UnbindGlobal( "Demonstration" );
#
# This is a modified version of Demonstration from lib/demo.g
# to colorise GAP prompt and input
#
BindGlobal( "Demonstration", function( file )
    local   input,  keyboard,  result, storedtime;

    input := InputTextFile( file );
    while input = fail do
        Error( "Cannot open file ", file );
    od;

    Print( "\nStart of demonstration.\n\n" );

    InputLogTo( "*stdout*" );
    keyboard := InputTextUser();
    # Use the following line in two places if you wish
    # GAP prompt and input displayed in bold
    # Print( "\033[1m\033[34m", "demo> \c", "\033[0m" );
    Print( "\033[34m", "demo> \c", "\033[0m" );
    while CHAR_INT( ReadByte( keyboard ) ) <> 'q' do
        storedtime := Runtime();
        result:=READ_COMMAND_REAL( input, true ); # Executing the command.
        time := Runtime()-storedtime;
        if Length(result) = 2 then
            last3 := last2;
            last2 := last;
            last := result[2];
            View(result[2]);
            Print("\n" );
        fi;

        if IsEndOfStream( input ) then
            break;
        fi;
        Print( "\033[34m", "demo> \c", "\033[0m" );
    od;
    Print( "\nEnd of demonstration.\n\n", "\033[0m");
    CloseStream( keyboard );
    CloseStream( input );
    InputLogTo();
end );

Demonstration("paris2011.g");