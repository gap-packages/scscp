#!/bin/bash
GAP="/Users/ericjespers/CVSREPS/GAPDEV/bin/gap.sh"
SCSCP_DIR="/Users/ericjespers/scscp/example"
cd $SCSCP_DIR
TMPFILE=`mktemp /tmp/gapscscp.XXXXXX`
echo "Starting SCSCP server with output to $TMPFILE" 
$GAP "$SCSCP_DIR/myserver.g" > $TMPFILE 2>&1 &
