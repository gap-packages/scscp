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

# If the SCSCPsuppressReferences is set to true, then 
# OMPutReference (lib/openmath.gi) will put the actual 
# OpenMath code for an object whenever it has id or not.
# This might be needed for compatibility with some systems.
SCSCPsuppressReferences := false;

#############################################################################
#
# Default parameters for the server mode
#

# setting the default hostname to be used in the server mode
SCSCPserverAddress := "localhost";

# setting the default port
SCSCPserverPort := 26133;