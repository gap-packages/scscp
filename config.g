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
# SuppressOpenMathReferences := true;

#############################################################################
#
# Default parameters for the server mode (note that they will be overwritten 
# if the server is started using scscp/gapscscp.sh script
#

# setting the default hostname to be used in the server mode. May be:
# * "localhost" or specific string
# * Hostname(); to determine it automatically
# * true to listen all network interfaces
# Uncomment needed line below.

SCSCPserverAddress := "localhost";
#SCSCPserverAddress := Hostname();
#SCSCPserverAddress := true;

# setting the default port
SCSCPserverPort := 26133;

# If SCSCPserverAcceptsOnlyTransientCD is true, the server
# will accept only procedures from scscp_transient_1 CD.
# otherwise calls like scscp1.procedure_call(integer2.euler(n))
# will be also possible (however, it is possible to have a
# designated procedure EvaluateOpenMathCode to evaluate 
# arbitrary OpenMath code.
#
SCSCPserverAcceptsOnlyTransientCD := true;

# setting the name of the service, for example, 
# "GAP SCSCP service", "Group identification service" etc.
SCSCPserviceName:="GAP SCSCP service";

# setting information about the version of the service,
# which may combine packages versions, timestamp when
# the server was started, and other information
SCSCPserviceVersion:= Concatenation( 
	"GAP ", VERSION, 
	" + SCSCP ", GAPInfo.PackagesInfo.scscp[1].Version,
	" started on ", CurrentTimestamp() );

# setting the default description, which may include, for example, 
# functions exposed, description of resources, contact details of 
# service provider, and any other useful information
SCSCPserviceDescription:= Concatenation( 
	"Started with scscp/example/myserver.g from SCSCP ", 
	GAPInfo.PackagesInfo.scscp[1].Version );
