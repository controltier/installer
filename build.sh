#!/bin/sh

SRC_DIR=`pwd`

MAVEN_HOME=$SRC_DIR/maven
export MAVEN_HOME

if [ "$JAVA_HOME" = "" ]; then
   echo "JAVA_HOME not defined" 2>&1
   exit 1
fi

PATH=$MAVEN_HOME/bin:$JAVA_HOME/bin:/usr/bin:/bin:/usr/sbin:/sbin
export PATH

if [ ! -x $MAVEN_HOME/bin/maven ]; then
   echo "$MAVEN_HOME/bin/maven does not exist or is not executable" 2>&1
   exit 1
fi

mkdir -p $MAVEN_HOME/repository/itnav/jars
if [ ! -d $MAVEN_HOME/repository/itnav/jars ]; then
   echo "unable to create directory: $MAVEN_HOME/repository/itnav/jars" 2>&1
   exit 1
fi

if [ ! -d workbench ]; then
   echo "directory: `pwd`/workbench, does not exist" 2>&1
   exit 1
fi

if [ ! -d commander ]; then
   echo "directory: `pwd`/commander, does not exist" 2>&1
   exit 1
fi

cd workbench

maven -Djava.net.preferIPv4Stack=true java:jar-resources
maven -Djava.net.preferIPv4Stack=true java:jar 
cp $SRC_DIR/workbench/target/itnav-*.jar $MAVEN_HOME/repository/itnav/jars
maven -Djava.net.preferIPv4Stack=true war

cd ../commander
maven -Djava.net.preferIPv4Stack=true java:jar-resources
maven -Djava.net.preferIPv4Stack=true extension:package
