#!/bin/bash
# STATUS
# Soliciting feedback on usefulness 
#
# DESCRIPTION
# This utility is meant to be a convenient method for
# installing the ControlTier client software on a remote node. 
# Basically, this utility uses ctl-exec to automate the download of a 
# ControlTier-<vers>.zip file from a web repository
# and then extracts and invokes the installer. 
# It only works for Unix hosts.
#
# PREPARATIONS
# The following steps should be followed before running this script.
# 1) Install the ControlTier software on a host that will be your central
#    administration machine. 
# 2) Create a project. The default installation will already create
#    one called 'default'.
# 3) Define your hosts in Workbench. Use ProjectBuilder and an XML 
#    file to declare your host information.
#     3.1) Create a nodes.xml file in accordance to this XML format:
#          http://open.controltier.org/Workbench/Docs/reference/project-v10.html
#        Example nodes.xml content:
#
#        <!DOCTYPE project PUBLIC
#           "-//ControlTier Software Inc.//DTD Project Document 1.0//EN" "project.dtd">
#        <project>
#          <node name="strongbad" type="Node"
#                description="a development host"
#                hostname="strongbad.local"
#                osArch="i386" osFamily="unix" osName="Darwin" osVersion="9.2.2"
#                ctlbase="/ctier/ctl" ctlhome="/ctier/pkgs/ctl-1.1" 
#                ctlusername="${framework.ssh.user}"/>
#        </project>
#      3.2) Then load it via ProjectBuilder's 'load-objects' command:
#          ctl -m ProjectBuilder -c load-objects -- -filename nodes.xml
#  
# 4) PUT your installer into the Webdav repo using davutil's "put" command.
#    Here's an example:
#     ctl -m davutil -c put -- \
#         -file /path/to/ControlTier-3.2.3.zip \
#         -url http://strongbad:8080/jackrabbit/repository/workbench/pkgs/ControlTier-3.2.3.zip \
#         -username default -password default
# 5) Ensure the remote nodes have SSH and Java1.5 installed. The SSH setup should
#    allow key-based authentication and no password prompting.
#
# RUNNING
# Run this script without arguments to see the usage.
# The options that are in square braces are optional and are defaulted
# from the server's CTL install info.

PROG=`basename $0`

[ -z "$CTL_BASE" -o ! -d "$CTL_BASE" ] && {
    echo "ERROR: CTL_BASE not set or does not exist";
    exit 1;
}

# print USAGE and exit
syntax_error() {
    #echo "$USAGE" >&2
    echo "$SYNTAX $*" >&2
    exit 2
}

# check that an option has an argument
arg_syntax_check() {
    [ "$1" -lt 2 ] && syntax_error
}



USAGE="
SYNOPSIS
$PROG -node <> -installer-zip <> [-project <> ]
             [-server-host <>] [-server-port <>] [-installer-url <>]
             [-server-user <>] [-server-pass <>] [-java-home <>]
             [ -- deferred-args]
OPTIONS
 -node               node to install client software
 -installer-zip      installer file base name
 -installer-url      installer repository URL 
 -project            the project depot name
 -server-host        the host where the ControlTier Jetty is hosted
 -server-port        the port where the ControlTier Jetty is listening
 -server-user        the Workbench/Jackrabbit user name
 -server-pass        the Workbench/Jackrabbit password
 -server-davurl      the Jackrabbit base URL
 -java-home          the path to JAVA_HOME on the target host
 --                  deferred arguments that are passed to the install.sh script
# Example:
#    $PROG -node centos -installer-zip ControlTier-3.2.3.zip -java-home /usr/local/jdk1.5.0_14
#
# If you have a large number of hosts you can use script along with ctl-exec like so:
#
#    for node in \$(ctl-exec -I os-family=unix)
#    do
#        $PROG -node \$node -installer-zip ControlTier-3.2.3.zip -java-home /usr/local/jdk1.5.0_14
#    done
"

#
# the following are defaults based on the server node's install info
#
SERVER_HOST=$(awk '/framework.server.hostname/ {print $3}' $CTL_BASE/etc/framework.properties)
SERVER_PORT=8080
SERVER_USER=$(awk '/framework.server.username/ {print $3}' $CTL_BASE/etc/framework.properties)
SERVER_PASS=$(awk '/framework.server.password/ {print $3}' $CTL_BASE/etc/framework.properties)
SERVER_PKG_REPO=$(awk '/framework.pkgRepo.uri/ {print $3}' $CTL_BASE/etc/framework.properties)
PROJECT=$(awk '/depot.default.name/ {print $3}' $CTL_BASE/etc/project.properties)

[ "$#" -lt 1 ] && { echo "$USAGE" ; exit 2 ; }
#
# process the arguments
#
while [ "$#" -gt 0 ]; do
    OPT="$1"
    case "$OPT" in
    # options without arguments
	-h)
	    echo "$USAGE"
	    exit 0
	    ;;
    # options with arguments
	-installer-url)
	    arg_syntax_check "$#"
	    INSTALLER_URL="$2"
	    shift
	    ;;
	-installer-zip)
	    arg_syntax_check "$#"
	    INSTALLER_ZIP="$2"
	    shift
	    ;;
	-node)
	    arg_syntax_check "$#"
	    NODE="$2"
	    shift
	    ;;
	-project)
	    arg_syntax_check "$#"
	    PROJECT="$2"
	    shift
	    ;;
	-server-host)
	    arg_syntax_check "$#"
	    SERVER_HOST="$2"
	    shift
	    ;;
	-server-port)
	    arg_syntax_check "$#"
	    SERVER_PORT="$2"
	    shift
	    ;;
	-server-user)
	    arg_syntax_check "$#"
	    SERVER_USER="$2"
	    shift
	    ;;
	-server-pass)
	    arg_syntax_check "$#"
	    SERVER_PASS="$2"
	    shift
	    ;;
	-ctier-root)
	    arg_syntax_check "$#"
	    CTIER_ROOT="$2"
	    shift
	    ;;
	-java-home)
	    arg_syntax_check "$#"
	    JAVA_HOME="$2"
	    shift
	    ;;
	# deferred arguments (useful for the install.sh -Dkey=val pairs)
	--)
	    shift
	    break
	    ;;
    # unknown option
	-?)
	    syntax_error
	    ;;
    # end of options, just arguments left
	*)
	    break
    esac
    shift
done

DEFERRED_ARGS="$@"

# check required arguments
[ -z "$NODE" ] && { echo "-node not specified" ; exit 2 ; }
[ -z "$PROJECT" ] && { echo "-project not specified" ; exit 2 ; }
[ -z "$INSTALLER_ZIP" -a -z "$INSTALLER_URL" ] && { echo "-installer-zip or -installer-url must be specified" ; exit 2 ; }

# continue the defaulting
[ -z "$INSTALLER_URL" -a -n "$INSTALLER_ZIP" ] && { INSTALLER_URL=$SERVER_PKG_REPO/$INSTALLER_ZIP ; }
[ -z "$INSTALLER_ZIP" -a -n "$INSTALLER_URL" ] && { INSTALLER_ZIP=$(basename $INSTALLER_URL) ; }

#
# get additional node information about the target host from the nodes.properties
#
echo "Looking up host info for node: '$NODE' ..."
[ -r $CTL_BASE/depots/$PROJECT/etc/nodes.properties ] || { 
  echo "file not found: $CTL_BASE/depots/$PROJECT/etc/nodes.properties"; exit 1 ;
}
for line in $(grep "^node.${NODE}" $CTL_BASE/depots/$PROJECT/etc/nodes.properties|sort)
do 
    key=$(echo $line|cut -f1 -d=)
    val=$(echo $line|cut -f2 -d=)
    export NODE_$(echo $key|cut -f3 -d.|tr "-" "_" |tr "[:lower:]" "[:upper:]")=$val
    #NODE_CTL_BASE = /home/ctier/ctl
    #NODE_CTL_HOME = /home/ctier/pkgs/ctl-1.1
    #NODE_CTL_PASSWORD_SET = true
    #NODE_CTL_USERNAME = alexh
    #NODE_DESCRIPTION = a development host
    #NODE_HOSTNAME = strongbad
    #NODE_NAME = strongbad
done

#
# Generate a script to install the client software for this node
#
INSTALL_BASEDIR=${INSTALLER_ZIP%.zip}
SCRIPT=/tmp/install-script-$NODE.sh
if [ -n "$JAVA_HOME" ]; then
 JAR=$JAVA_HOME/bin/jar
 JAVA=$JAVA_HOME/bin/java
else
 JAR=jar
 JAVA=java
fi
cat >$SCRIPT <<EOF
#!/bin/sh
#
# Install script for node $NODE
#

# check preconditions
$JAVA -version 2>&1| grep -q 1.5 || {
   echo "ERROR: Installer requires Java 1.5" ;
   exit 1 ;
}
curl --version 2>&1| grep -q http || {
   echo "ERROR: This installer requires curl" ;
   exit 1 ;
}

CTIER_ROOT=\$CTIER_ROOT;
export CTIER_ROOT;
echo "INFO: Installing in directory: '\$CTIER_ROOT' ...";
mkdir -p \$CTIER_ROOT/pkgs || { echo "ERROR: Failed to create directory" ; exit 1 ; }

# get the install package
cd \$CTIER_ROOT/pkgs;

# first check if the file is in the repository
curl --user $SERVER_USER:$SERVER_PASS  --silent --head $INSTALLER_URL | grep -q "200 OK" || {
   echo "ERROR: Web server reported not found: '$INSTALLER_URL'" ;
   exit 1 ;
}
echo "INFO: Downloading installer: '$INSTALLER_URL' ...";
curl --user $SERVER_USER:$SERVER_PASS $INSTALLER_URL \
     -o ./$INSTALLER_ZIP || { echo "ERROR: Download failed" ; exit 1 ; }

# double check this is not an HTML file containing an error message:
file ./$INSTALLER_ZIP | grep -q HTML && { 
   echo "ERROR: Downloaded content not Zip format but was HTML. HTML content: " ;
   cat ./$INSTALLER_ZIP ;
   exit 1 ;
}
# extract it
echo "INFO: extracting $INSTALLER_ZIP ...";
$JAR xf $INSTALLER_ZIP || { echo "ERROR: Failed to extract installer." ; exit 1 ; }

# invoke the installer
echo "INFO: invoking installer ...";
cd ${INSTALL_BASEDIR};
sh ./install.sh --client  \\
  -Dserver.jetty.hostname=$SERVER_HOST \\
  -Dserver.jetty.port=$SERVER_PORT \\
  -Djetty.user.name=$SERVER_USER \\
  -Djetty.user.password=$SERVER_PASS \\
  -Dclient.hostname=$NODE_HOSTNAME \\
  -Dclient.node.description=$NODE_DESCRIPTION \\
  $DEFERRED_ARGS || { echo "ERROR: installation failed." ; exit 1 ; }

# Now clean up the downloaded files
echo "INFO: cleaning up intermediate install files ..." ;

cd \$CTIER_ROOT/pkgs
rm -r ${INSTALL_BASEDIR}
echo "INFO: installation completed successfully on node: '$NODE_HOSTNAME'." ;

exit 0;
EOF
# ensure the script file was generated ok
[ $? == 0 ] || { echo "ERROR: Couldn't generate script file: '$SCRIPT'" ; exit 1 ; }


# Execute the generated scriptfile via 'ctl-exec'
ctl-exec -I ${NODE} --scriptfile $SCRIPT || {
    echo "ERROR: error occurred running scriptfile $SCRIPT for node: '$NODE'" ; exit 1 ;
}

exit 0;
