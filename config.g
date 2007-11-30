#############################################################################
##
#W config.g                 The SCSCP package             Alexander Konovalov
#W                                                               Steve Linton
##
#H $Id:$
##
## This is a sample configuration file for the GAP package SCSCP. 
##
#############################################################################

#############################################################################
#
# General parameters
#

# setting the default InfoLevel
SetInfoLevel(InfoSCSCP,1);

#############################################################################
#
# Parameters for the server mode
#

# setting the hostname (will be user in served mode)
SCSCPserverAddress := "localhost";

# setting the port
SCSCPserverPort := 26133;