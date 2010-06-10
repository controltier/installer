#!/bin/sh

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] ; then
    echo "usage: newrelease <ct-version> <ctl-path> <ct-path> [-status | -diff | -commit]"
    exit 1
fi

CTVER=$1
CTLPATH=$2
CTPATH=$3
CCPATH=$CTPATH/ctl-center
CTLVER=$CTVER

if [ "$4" == "-status" ] ; then
    svn stat $CTLPATH/project.xml $CTLPATH/bundle/project.xml $CTLPATH/version.properties
    svn stat $CTPATH/version.properties $CTPATH/common/project.xml $CTPATH/commander/project.xml $CTPATH/workbench/project.xml $CTPATH/installer/project.xml  $CTPATH/buildall.sh $CTPATH/ctbuild/build.properties $CTPATH/ctbuild/jobs/jobs.xml
    svn stat $CCPATH/application.properties $CCPATH/grails-app/i18n/messages.properties $CCPATH/etc/install.xml $CCPATH/version.properties
    exit 0
fi
if [ "$4" == "-diff" ] ; then
    svn diff $CTLPATH/project.xml $CTLPATH/bundle/project.xml $CTLPATH/version.properties
    svn diff $CTPATH/version.properties $CTPATH/common/project.xml $CTPATH/commander/project.xml $CTPATH/workbench/project.xml $CTPATH/installer/project.xml  $CTPATH/buildall.sh $CTPATH/ctbuild/build.properties $CTPATH/ctbuild/jobs/jobs.xml
    svn diff $CCPATH/application.properties $CCPATH/grails-app/i18n/messages.properties $CCPATH/etc/install.xml $CCPATH/version.properties
    exit 0
fi

# update ctl version 

perl  -i'.orig' -p -e "s#^version\.number\s*=.*\$#version.number=$CTLVER#" $CTLPATH/version.properties
perl  -i'.orig' -p -e "s#<currentVersion>.*?</currentVersion>#<currentVersion>$CTLVER</currentVersion>#s" $CTLPATH/project.xml
perl  -i'.orig' -p -e "s#<currentVersion>.*?</currentVersion>#<currentVersion>$CTLVER</currentVersion>#s" $CTLPATH/bundle/project.xml
perl  -0777 -i'.orig' -p -e "s#(<id>ctl-dispatch</id>\s*)<version>.*?</version>#\$1<version>$CTLVER</version>#s" $CTLPATH/bundle/project.xml
perl  -0777 -i'.orig' -p -e "s#(<id>commander-extension</id>\s*)<version>.*?</version>#\$1<version>$CTVER</version>#sg" $CTLPATH/bundle/project.xml


# update version.properties
perl  -i'.orig' -p -e "s#^version\.number\s*=.*\$#version.number=$CTVER#" $CTPATH/version.properties
perl  -i'.orig' -p -e "s#^version\.release\.number\s*=.*\$#version.release\.number=0#" $CTPATH/version.properties
# update ctier versions and dependencies
perl  -i'.orig' -p -e "s#<currentVersion>.*?</currentVersion>#<currentVersion>$CTVER</currentVersion>#s" $CTPATH/common/project.xml

#update ctl dependency
perl  -0777 -i'.orig' -p -e "s#(<id>ctl</id>\s*)<version>.*?</version>#\$1<version>$CTLVER</version>#s" $CTPATH/common/project.xml


#commander
perl  -i'.orig' -p -e "s#<currentVersion>.*?</currentVersion>#<currentVersion>$CTVER</currentVersion>#s" $CTPATH/commander/project.xml
perl  -0777 -i'.orig' -p -e "s#(<id>ctl</id>\s*)<version>.*?</version>#\$1<version>$CTLVER</version>#s" $CTPATH/commander/project.xml
perl  -0777 -i'.orig' -p -e "s#(<id>ctier-.+?</id>\s*)<version>.*?</version>#\$1<version>$CTVER</version>#sg" $CTPATH/commander/project.xml
perl  -0777 -i'.orig' -p -e "s#(<id>core-seed</id>\s*)<version>.*?</version>#\$1<version>$CTVER</version>#sg" $CTPATH/commander/project.xml
perl  -0777 -i'.orig' -p -e "s#(<id>elements-seed</id>\s*)<version>.*?</version>#\$1<version>$CTVER</version>#sg" $CTPATH/commander/project.xml


#workbench

perl  -i'.orig' -p -e "s#<currentVersion>.*?</currentVersion>#<currentVersion>$CTVER</currentVersion>#s" $CTPATH/workbench/project.xml
perl  -0777 -i'.orig' -p -e "s#(<id>ctl</id>\s*)<version>.*?</version>#\$1<version>$CTLVER</version>#s" $CTPATH/workbench/project.xml
perl  -0777 -i'.orig' -p -e "s#(<id>ctier-.+?</id>\s*)<version>.*?</version>#\$1<version>$CTVER</version>#sg" $CTPATH/workbench/project.xml
perl  -0777 -i'.orig' -p -e "s#(<id>commander</id>\s*)<version>.*?</version>#\$1<version>$CTVER</version>#sg" $CTPATH/workbench/project.xml
perl  -0777 -i'.orig' -p -e "s#(<id>core-seed</id>\s*)<version>.*?</version>#\$1<version>$CTVER</version>#sg" $CTPATH/workbench/project.xml
perl  -0777 -i'.orig' -p -e "s#(<id>elements-seed</id>\s*)<version>.*?</version>#\$1<version>$CTVER</version>#sg" $CTPATH/workbench/project.xml
#installer
perl  -i'.orig' -p -e "s#<currentVersion>.*?</currentVersion>#<currentVersion>$CTVER</currentVersion>#s" $CTPATH/installer/project.xml
perl  -0777 -i'.orig' -p -e "s#(<id>ctl</id>\s*)<version>.*?</version>#\$1<version>$CTLVER</version>#s" $CTPATH/installer/project.xml
perl  -0777 -i'.orig' -p -e "s#(<id>itnav</id>\s*)<version>.*?</version>#\$1<version>$CTVER</version>#sg" $CTPATH/installer/project.xml
perl  -0777 -i'.orig' -p -e "s#(<id>commander-extension</id>\s*)<version>.*?</version>#\$1<version>$CTVER</version>#sg" $CTPATH/installer/project.xml
perl  -0777 -i'.orig' -p -e "s#(<id>ctier-examples</id>\s*)<version>.*?</version>#\$1<version>$CTVER</version>#sg" $CTPATH/installer/project.xml
perl  -0777 -i'.orig' -p -e "s#(<id>ctlcenter</id>\s*)<version>.*?</version>#\$1<version>$CTVER</version>#sg" $CTPATH/installer/project.xml

# update ctlcenter version

perl  -i'.orig' -p -e "s#^version\.number\s*=.*\$#version.number=$CTVER#" $CCPATH/version.properties
perl  -i'.orig' -p -e "s#^app\.version=.*\$#app.version=$CTVER#" $CCPATH/application.properties
perl  -i'.orig' -p -e "s#^ctlcenter\.version\.num=.*\$#ctlcenter.version.num=$CTVER#" $CCPATH/grails-app/i18n/messages.properties
perl  -i'.orig' -p -e "s#<property\s+name=\"ctlcenter.version\"\s+value=\".*?\"#<property name=\"ctlcenter.version\" value=\"$CTVER\"#" $CCPATH/etc/install.xml
perl  -i'.orig' -p -e "s#<property\s+name=\"commander.version\"\s+value=\".*?\"#<property name=\"commander.version\" value=\"$CTVER\"#" $CCPATH/etc/install.xml
perl  -i'.orig' -p -e "s#<property\s+name=\"ctl.version\"\s+value=\".*?\"#<property name=\"ctl.version\" value=\"$CTLVER\"#" $CCPATH/etc/install.xml

echo "updating project.xml"

echo > $CTPATH/ctbuild/build.properties
ant -Dctl.path=$CTLPATH -Dctier.path=$CTPATH  -f $CTPATH/ctbuild/build.xml

if [ "$4" == "-commit" ] ; then
    svn commit -m "update version to $CTLVER, update dependencies" $CTLPATH/project.xml $CTLPATH/bundle/project.xml $CTLPATH/version.properties
    svn commit -m "update version to $CTVER, update dependencies" $CTPATH/version.properties $CTPATH/common/project.xml $CTPATH/commander/project.xml $CTPATH/workbench/project.xml $CTPATH/installer/project.xml \
         $CCPATH/application.properties $CCPATH/grails-app/i18n/messages.properties $CCPATH/etc/install.xml $CCPATH/version.properties
    svn commit -m "update project.xml definitions to latest"  $CTPATH/ctbuild/build.properties $CTPATH/ctbuild/jobs/jobs.xml $CTPATH/buildall.sh
fi
