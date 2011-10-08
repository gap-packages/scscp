###########################################################################
##
#W parscscp.g             The SCSCP package             Alexander Konovalov
#W                                                             Steve Linton
##
###########################################################################

for i in [26133..26134] do
  Print("Trying port ", i, " ...\n");
  t:=PingSCSCPservice( "localhost", i );
  if t=fail then
    Exec( Concatenation( "./gapd.sh -p ", String(i) ) );
  else
    Print(" - already running!\n");
  fi;
od;  

###########################################################################
##
#E
##