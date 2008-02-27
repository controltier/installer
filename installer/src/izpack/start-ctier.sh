#!/bin/sh

export JAVA_HOME=$JDKPath

if [ "true" != "$POST_INSTALL_START_SERVICES" ] ; then  
    exit 0
fi
# Check if JAVA_HOME is set to a valid JDK
# @@@TODO

. $USER_HOME/.ctierrc
echo Starting Workbench server...
cd $INSTALL_PATH/workbench/bin
./startup.sh

cd $INSTALL_PATH/pkgs/jobcenter-$JCVERSION/bin
./start-jobcenter.sh

cd $INSTALL_PATH/pkgs/reportcenter-$RCVERSION/bin
./start-reportcenter.sh

exit 0
