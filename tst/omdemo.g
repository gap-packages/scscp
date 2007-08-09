# This is a GAP demonstration file. 
# To run a demonstration enter the following:
# gap> LogTo(); # (if you are logging to a file)
# gap> ReadLib("demo.g");
# gap> Demonstration("omdemo.g");
# (probably you will need the full path in the last 
# command). Then you may press <Enter> to go to the 
# next step or press <q> to terminate demonstration
#
# -------------------------------------------------
#
# This tests reads OM objects from scscp/tst/test.om file
# It does not use network connection and only test OMGetObjectWithAttributes
#
LoadPackage("scscp");
InstallSCSCPprocedure("WS_factorial", Factorial );
InstallSCSCPprocedure("GroupIdentificationService", IdGroup );
Terminate:=function() return "Terminated"; end;
InstallSCSCPprocedure( "Terminate", Terminate );
test:=Filename( Directory("~/scscp-gapdev/tst"), "omdemo.om");
stream:=InputTextFile(test);
OMGetObjectWithAttributes(stream); # 1
OMGetObjectWithAttributes(stream); # Primes
OMGetObjectWithAttributes(stream); # 120
OMGetObjectWithAttributes(stream); # [24,12] (procedure_call)
OMGetObjectWithAttributes(stream); # [24,12] (procerure completed)
OMGetObjectWithAttributes(stream); # Error message (enter quit after it)
CloseStream(stream);