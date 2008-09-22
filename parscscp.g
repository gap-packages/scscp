#############################################################################
##
#W parscscp.g               The SCSCP package             Alexander Konovalov
#W                                                               Steve Linton
##
#H $Id: $
##
#############################################################################

for i in [26133..26134] do
  Print("Trying port ", i, " ...\n");
  t:=PingWebService( "localhost", i );
  if t=fail then
    Exec("./gapscscp.sh");
  else
    Print(" - already running!\n");
  fi;
od;    	
    