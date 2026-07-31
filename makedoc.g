#
# This file is a script which compiles the package manual.
#
if fail = LoadPackage("AutoDoc", "2022.07.10") then
    Error("AutoDoc version 2022.07.10 or newer is required.");
fi;

AutoDoc(rec(
    autodoc := true,
    extract_examples := true,
    gapdoc := rec(
        main := "manual.xml",
        files := [
            "lib/connect.gd",
            "lib/openmath.gd",
            "lib/process.gd",
            "lib/remote.gd",
            "lib/scscp.gd",
            "lib/utils.g",
            "lib/xstream.gd",
            "par/parlist.g",
            "tracing/tracing.g",
        ],
    ),
    scaffold := rec( MainPage := false, TitlePage := false ),
));
