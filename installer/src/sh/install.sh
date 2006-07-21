#!/bin/sh
#
# $RCSfile$
# $Revision$
#
# installs ControlTier server and client
#

ANT_HOME=pkgs/@pkg.antdepo.expanded.name@/pkgs/@pkg.ant.expanded.name@

errorMsg() {
   echo "$1" 1>&2
}

argsOrig=$*


if [ "${JAVA_HOME}X" = "X" ]
then
   errorMsg "JAVA_HOME not set"
   exit 1
fi
if [ ! -x $JAVA_HOME/bin/java ] 
then
   errorMsg "JAVA_HOME not set or set incorrectly"
   exit 1
fi

if [ "${ANT_HOME}X" = "X" ]
then
   errorMsg "ANT_HOME not set"
   exit 1
fi



PATH=$JAVA_HOME/bin:/usr/bin:/bin:/usr/sbin:/sbin
export PATH

$JAVA_HOME/bin/java -Dant.home=$ANT_HOME -cp lib/installer.jar:$ANT_HOME/lib/ant.jar:$ANT_HOME/lib/ant-launcher.jar:$ANT_HOME/lib/regexp-1.2.jar:$ANT_HOME/lib/ant-apache-regexp.jar:$ANT_HOME/lib/ant-contrib-1.0b1.jar:$ANT_HOME/lib/ant-nodeps.jar:$ANT_HOME/lib/ant-trax.jar \
     com.controltier.install.CTierInstaller $*

if [ $? -ne 0 ]; then
    exit 1
fi

echo "$argsOrig" > etc/install.status

exit $?
