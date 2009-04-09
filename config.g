#############################################################################
##
#W config.g                 The SCSCP package             Alexander Konovalov
#W                                                               Steve Linton
##
#H $Id$
##
## This is a sample configuration file for the GAP package SCSCP. 
##
#############################################################################

#############################################################################
#
# General parameters
#

# setting the default InfoLevel
SetInfoLevel(InfoSCSCP,4);

# If the SuppressOpenMathReferences is set to true, then 
# OMPutReference (lib/openmath.gi) will put the actual 
# OpenMath code for an object whenever it has id or not.
# This might be needed for compatibility with some systems.
# This parameter was set to false in the OpenMath package.
# Uncomment the next line, if you need to change it.
SuppressOpenMathReferences := true;

#############################################################################
#
# Default parameters for the server mode (note that they will be overwritten 
# if the server is started using scscp/gapscscp.sh script
#

# setting the default hostname to be used in the server mode
SCSCPserverAddress := "localhost"; # Hostname();

# setting the default port
SCSCPserverPort := 26133;

# setting the default description
SCSCPserverDescription:="GAP SCSCP service";
