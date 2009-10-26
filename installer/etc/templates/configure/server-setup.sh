#!/bin/sh
#
# $Revision: 9441 $
#
# Configure the ControlTier Server
#

CTIER_ROOT=${env.ctier_root}
ANT_HOME=${env.ctl_home}/pkgs/apache-ant-${package.ant.version}

errorMsg() {
   echo "$1" 1>&2
}

#
# This hack checks if this shell script was called within (most probably) a cygwin context
# during an ssh to a windows box and if so, to actually exec the .bat batch file instead.
#
if [ -n "$OS" -a "$OS" = "Windows_NT" ]
then
   exec cmd.exe /C .\\server-setup.bat "$@" -Dcygwin=true -Dframework.ssh.user=$USER
fi

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

if [ "${CTIER_ROOT}X" = "X" ]
then
    errorMsg "CTIER_ROOT not set or set incorrectly"
    exit 1
fi

if [ "${ANT_HOME}X" = "X" ]
then
   errorMsg "ANT_HOME not set"
   exit 1
fi


PATH=$JAVA_HOME/bin:/usr/bin:/bin:/usr/sbin:/sbin
export PATH

$JAVA_HOME/bin/java -Denv.ctier_root=$CTIER_ROOT -Dant.home=$ANT_HOME -cp $CTIER_ROOT/pkgs/configure/lib/installer.jar:$ANT_HOME/lib/commons-cli-1.0.jar:$ANT_HOME/lib/ant.jar:$ANT_HOME/lib/ant-launcher.jar:$ANT_HOME/lib/regexp-1.5.jar:$ANT_HOME/lib/ant-apache-regexp.jar:$ANT_HOME/lib/ant-contrib-1.0b1.jar:$ANT_HOME/lib/ant-nodeps.jar:$ANT_HOME/lib/ant-trax.jar \
     com.controltier.configure.CTierConfigurator $*

if [ $? -ne 0 ]; then
    exit 1
fi

echo "$argsOrig" > $CTIER_ROOT/pkgs/configure/server-setup.status

exit $?
