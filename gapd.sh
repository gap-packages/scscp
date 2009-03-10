#!/bin/sh

#############################################################################
##
#W  gapscscp.sh             The SCSCP package             Alexander Konovalov
#W                                                               Steve Linton
##
#H $Id: $
##
## gapscscp.sh [-t] [-h host] [-a] [-p port] 
##
## If '-t' is specified than the output will be redirected to a temporary file.
## Otherwise, by default it will be redirected to /dev/null
## 
## If '-h host' is specified, this will overwrite the default hostname 
## given in scscp/config.g. Here 'host' can be 'localhost' or machine name 
## with or without domain.
##
## If '-a' is specified, then the output of the call to 'hostname' will be 
## used as the SCSCP server address. This option will overwrite the '-h'
## option.
##
## If '-p port' is specified, this will overwrite the default port for the
## SCSCP server given in scscp/config.g.
##
##
#############################################################################
##
## PART 1. MODIFY PATHS IF NEEDED
##
#############################################################################
##
##  Define the local call of GAP and call options, if necessary, for example,
##  memory usage, start with the workspace etc.
##  
GAP="/Users/ericjespers/CVSREPS/GAPDEV/bin/gap.sh -b -r"
##
#############################################################################
##
##  Define the location of the root directory of the GAP package SCSCP
##
SCSCP_ROOT="/Users/ericjespers/scscp/"
##
##
#############################################################################
#############################################################################
##
## PART 2. YOU NEED NOT TO MODIFY ANYTHING BELOW
##
#############################################################################
##
##  Parse the arguments.
##
autohost="no"
use_temp_file="no"
host=";"
port=";"

option="yes"
while [ $option = "yes" ]; do
  option="no"
  case $1 in

    -t) shift; option="yes"; use_temp_file="yes";;
    
    -h) shift; option="yes"; host=":=\""$1"\";"; shift;;

    -a) shift; option="yes"; autohost="yes";;

    -p) shift; option="yes"; port=":="$1";"; shift;;
    
  esac
done

if [ $use_temp_file = "yes" ]; then
	OUTFILE=`mktemp /tmp/gapscscp.XXXXXX`
else
	OUTFILE="/dev/null"
fi;

if [ $autohost = "yes" ]; then
	host=":=Hostname();"
fi;

echo "Starting SCSCP server with output to $OUTFILE" 

# The next line starts GAP SCSCP server. 
# To redirect stderr to /dev/null as well,
# replace $OUTFILE 2>&1 & with $OUTFILE &

echo 'LoadPackage("scscp");SetInfoLevel(InfoSCSCP,0);SCSCPserverAddress'$host'SCSCPserverPort'$port'Read("'$SCSCP_ROOT'/example/myserver.g"); if SCSCPserverStatus=fail then QUIT_GAP(); fi;' | exec $GAP > $OUTFILE &

