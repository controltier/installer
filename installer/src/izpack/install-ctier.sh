#!/bin/sh

export JAVA_HOME=$JDKPath

# Check if JAVA_HOME is set to a valid JDK
# @@@TODO

CTIER_ROOT=$INSTALL_PATH
export CTIER_ROOT
cd $INSTALL_PATH/pkgs/ControlTier-$CTVERSION;
chmod +x ./*.sh
sh ./install.sh

exit 0
