#!/bin/sh

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ] || [ -z "$5" ] || [ -z "$6" ] || [ -z "$7" ] || [ -z "$8" ] ; then
    echo "usage: newrelease <ctl-version> <ctl-path> <ctier-version> <ct-path> <jc-version> <jc-path> <rc-version> <rc-path>"
    exit 1
fi

CTLVER=$1
CTLPATH=$2
CTVER=$3
CTPATH=$4
JCVER=$5
JCPATH=$6
RCVER=$7
RCPATH=$8

# update ctl version 

perl  -i'.orig' -p -e "s#^version\.number\s*=.*\$#version.number=$CTLVER#" $CTLPATH/version.properties
perl  -i'.orig' -p -e "s#<currentVersion>.*?</currentVersion>#<currentVersion>$CTLVER</currentVersion>#s" $CTLPATH/project.xml
perl  -i'.orig' -p -e "s#<currentVersion>.*?</currentVersion>#<currentVersion>$CTLVER</currentVersion>#s" $CTLPATH/bundle/project.xml
perl  -0777 -i'.orig' -p -e "s#(<id>ctl-dispatch</id>\s*)<version>.*?</version>#\$1<version>$CTLVER</version>#s" $CTLPATH/bundle/project.xml
perl  -0777 -i'.orig' -p -e "s#(<id>commander-extension</id>\s*)<version>.*?</version>#\$1<version>$CTVER</version>#sg" $CTLPATH/bundle/project.xml


# update version.properties
perl  -i'.orig' -p -e "s#^version\.number\s*=.*\$#version.number=$CTVER#" $CTPATH/version.properties
# update ctier versions and dependencies
perl  -i'.orig' -p -e "s#<currentVersion>.*?</currentVersion>#<currentVersion>$CTVER</currentVersion>#s" $CTPATH/common/project.xml

#update ctl dependency
perl  -0777 -i'.orig' -p -e "s#(<id>ctl</id>\s*)<version>.*?</version>#\$1<version>$CTLVER</version>#s" $CTPATH/common/project.xml


#commander
perl  -i'.orig' -p -e "s#<currentVersion>.*?</currentVersion>#<currentVersion>$CTVER</currentVersion>#s" $CTPATH/commander/project.xml
perl  -0777 -i'.orig' -p -e "s#(<id>ctl</id>\s*)<version>.*?</version>#\$1<version>$CTLVER</version>#s" $CTPATH/commander/project.xml
perl  -0777 -i'.orig' -p -e "s#(<id>ctier-.+?</id>\s*)<version>.*?</version>#\$1<version>$CTVER</version>#sg" $CTPATH/commander/project.xml


#workbench

perl  -i'.orig' -p -e "s#<currentVersion>.*?</currentVersion>#<currentVersion>$CTVER</currentVersion>#s" $CTPATH/workbench/project.xml
perl  -0777 -i'.orig' -p -e "s#(<id>ctl</id>\s*)<version>.*?</version>#\$1<version>$CTLVER</version>#s" $CTPATH/workbench/project.xml
perl  -0777 -i'.orig' -p -e "s#(<id>ctier-.+?</id>\s*)<version>.*?</version>#\$1<version>$CTVER</version>#sg" $CTPATH/workbench/project.xml
perl  -0777 -i'.orig' -p -e "s#(<id>commander</id>\s*)<version>.*?</version>#\$1<version>$CTVER</version>#sg" $CTPATH/workbench/project.xml
#installer
perl  -i'.orig' -p -e "s#<currentVersion>.*?</currentVersion>#<currentVersion>$CTVER</currentVersion>#s" $CTPATH/installer/project.xml
perl  -0777 -i'.orig' -p -e "s#(<id>ctl</id>\s*)<version>.*?</version>#\$1<version>$CTLVER</version>#s" $CTPATH/installer/project.xml
perl  -0777 -i'.orig' -p -e "s#(<id>itnav</id>\s*)<version>.*?</version>#\$1<version>$CTVER</version>#sg" $CTPATH/installer/project.xml
perl  -0777 -i'.orig' -p -e "s#(<id>commander-extension</id>\s*)<version>.*?</version>#\$1<version>$CTVER</version>#sg" $CTPATH/installer/project.xml
perl  -0777 -i'.orig' -p -e "s#(<id>jobcenter</id>\s*)<version>.*?</version>#\$1<version>$JCVER</version>#sg" $CTPATH/installer/project.xml
perl  -0777 -i'.orig' -p -e "s#(<id>reportcenter</id>\s*)<version>.*?</version>#\$1<version>$RCVER</version>#sg" $CTPATH/installer/project.xml

# update jobcenter version

perl  -i'.orig' -p -e "s#^version\.number\s*=.*\$#version.number=$JCVER#" $JCPATH/version.properties
perl  -i'.orig' -p -e "s#^app\.version=.*\$#app.version=$JCVER#" $JCPATH/application.properties
perl  -i'.orig' -p -e "s#^jobcenter\.version\.num=.*\$#jobcenter.version.num=$JCVER#" $JCPATH/grails-app/i18n/messages.properties
perl  -i'.orig' -p -e "s#<property\s+name=\"jobcenter.version\"\s+value=\".*?\"#<property name=\"jobcenter.version\" value=\"$JCVER\"#" $JCPATH/etc/install.xml
perl  -i'.orig' -p -e "s#<property\s+name=\"commander.version\"\s+value=\".*?\"#<property name=\"commander.version\" value=\"$CTVER\"#" $JCPATH/etc/install.xml
perl  -i'.orig' -p -e "s#<property\s+name=\"ctl.version\"\s+value=\".*?\"#<property name=\"ctl.version\" value=\"$CTLVER\"#" $JCPATH/etc/install.xml

# update reportcenter version

perl  -i'.orig' -p -e "s#^version\.number\s*=.*\$#version.number=$RCVER#" $RCPATH/version.properties
perl  -i'.orig' -p -e "s#^app\.version=.*\$#app.version=$RCVER#" $RCPATH/application.properties
perl  -i'.orig' -p -e "s#^reportcenter\.version\.num=.*\$#reportcenter.version.num=$RCVER#" $RCPATH/grails-app/i18n/messages.properties
perl  -i'.orig' -p -e "s#<property\s+name=\"reportcenter.version\"\s+value=\".*?\"#<property name=\"reportcenter.version\" value=\"$RCVER\"#" $RCPATH/etc/install.xml
perl  -i'.orig' -p -e "s#<property\s+name=\"commander.version\"\s+value=\".*?\"#<property name=\"commander.version\" value=\"$CTVER\"#" $RCPATH/etc/install.xml
perl  -i'.orig' -p -e "s#<property\s+name=\"ctl.version\"\s+value=\".*?\"#<property name=\"ctl.version\" value=\"$CTLVER\"#" $RCPATH/etc/install.xml



if [ "$9" == "-commit" ] ; then
    svn commit -m "update version to $CTLVER, update dependencies" $CTLPATH/project.xml $CTLPATH/bundle/project.xml
    svn commit -m "update version to $CTVER, update dependencies" $CTPATH/version.properties $CTPATH/common/project.xml $CTPATH/commander/project.xml $CTPATH/workbench/project.xml $CTPATH/installer/project.xml
    svn commit -m "update version to $JCVER" $JCPATH/application.properties $JCPATH/grails-app/i18n/messages.properties $JCPATH/etc/install.xml $JCPATH/version.properties
    svn commit -m "update version to $RCVER" $RCPATH/application.properties $RCPATH/grails-app/i18n/messages.properties $RCPATH/etc/install.xml $RCPATH/version.properties
fi
