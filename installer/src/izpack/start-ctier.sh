#!/bin/sh

export JAVA_HOME=$JDKPath

if [ "true" != "$POST_INSTALL_START_SERVICES" ] ; then  
    exit 0
fi
# Check if JAVA_HOME is set to a valid JDK
# @@@TODO

. $USER_HOME/.ctierrc
echo Starting server...
$JETTY_HOME/bin/jetty.sh start

exit 0
