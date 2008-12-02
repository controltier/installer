###################################
# script for full controltier build
###################################

# configure JAVA_HOME and BUILD_ROOT as required
export JAVA_HOME=/usr/java/jdk1.5.0_15
export BUILD_ROOT=$HOME

CTLVERS=1.2
CTIERVERS=3.2.4
RCVERS=0.6
JCVERS=1.1


# dl dir is for downloaded files
mkdir $BUILD_ROOT/dl

# local dir is for installed components needed for build
mkdir $BUILD_ROOT/local

# localrepo dir is the local repository for intermediate build files and other dependencies
mkdir $BUILD_ROOT/localrepo
export LOCALREPO=$BUILD_ROOT/localrepo
export LOCALREPOURL=file:$LOCALREPO

# get ant zip dependency to local repo
mkdir -p $LOCALREPO/apache-ant/zips
cd $LOCALREPO/apache-ant/zips
wget -N http://ctl-dispatch.sourceforge.net/repository/apache-ant/zips/apache-ant-1.7.1p1.zip

# get grails bin distribution
cd $BUILD_ROOT/dl
wget -N http://dist.codehaus.org/grails/grails-bin-1.0.3.tar.gz


# extract grails and apache-ant to local dir for use during build
cd $BUILD_ROOT/local
tar xvzf $BUILD_ROOT/dl/grails-bin-1.0.3.tar.gz
unzip -o $LOCALREPO/apache-ant/zips/apache-ant-1.7.1p1.zip

export ANT_HOME=$BUILD_ROOT/local/apache-ant-1.7.1p1
export GRAILS_HOME=$BUILD_ROOT/local/grails-1.0.3


# begin checkout of sources

cd $BUILD_ROOT

#checkout ctier source
svn co https://controltier.svn.sourceforge.net/svnroot/controltier/branches/controltier-3-2-dev ctiersvn
export CTIERSVN=$BUILD_ROOT/ctiersvn

#checkout ctl source
svn co https://ctl-dispatch.svn.sourceforge.net/svnroot/ctl-dispatch/trunk ctlsvn
export CTLSVN=$BUILD_ROOT/ctlsvn

#checkout jobcenter source
svn co https://webad.svn.sourceforge.net/svnroot/webad/branches/jobcenter-1-0-dev/webad jobcentersvn
export JCSVN=$BUILD_ROOT/jobcentersvn


#########################
#
# CTL build
#
# NOTE: if $HOME/.ssh/id_dsa does not exist, run ssh-keygen:
# ssh-keygen -t dsa

cd $CTLSVN
echo maven.repo.ctierlocal = $LOCALREPOURL > build.properties
MAVEN_HOME=$CTLSVN/maven
$MAVEN_HOME/bin/maven clean ctl:antConfigure
$MAVEN_HOME/bin/maven ctl:stgz ctl:tgz ctl:zip

mkdir -p $LOCALREPO/ctl/jars
mkdir -p $LOCALREPO/ctl-dispatch/tgzs
cp target/ctl-dispatch-$CTLVERS.jar $LOCALREPO/ctl/jars/ctl-$CTLVERS.jar || (echo "CTL build failed: cannot copy target/ctl-dispatch-$CTLVERS.jar" && exit 1)
cp target/dist/tgzs/ctl-dispatch-$CTLVERS.tgz $LOCALREPO/ctl-dispatch/tgzs/ctl-dispatch-$CTLVERS.tgz || (echo "CTL build failed: cannot copy target/dist/tgzs/ctl-dispatch-$CTLVERS.tgz" && exit 1)

#######################
#
# CTIER common build
#
MAVEN_HOME=$CTIERSVN/maven	
cd $CTIERSVN/common
$MAVEN_HOME/bin/maven -Djava.net.preferIPv4Stack=true java:jars
		

mkdir -p $LOCALREPO/ctier-common/jars
mkdir -p $LOCALREPO/ctier-common-vocabulary/jars
mkdir -p $LOCALREPO/ctier-base-seed/jars
cp target/distributions/ctier-common/jars/ctier-common-$CTIERVERS.jar $LOCALREPO/ctier-common/jars/ctier-common-$CTIERVERS.jar || (echo "CTIER common build failed: cannot copy target/distributions/ctier-common/jars/ctier-common-$CTIERVERS.jar" && exit 1)
cp target/distributions/ctier-common-vocabulary/jars/ctier-common-vocabulary-$CTIERVERS.jar $LOCALREPO/ctier-common-vocabulary/jars/ctier-common-vocabulary-$CTIERVERS.jar || (echo "CTIER common build failed: cannot copy target/distributions/ctier-common-vocabulary/jars/ctier-common-vocabulary-$CTIERVERS.jar" && exit 1)
cp target/distributions/ctier-base-seed/jars/ctier-base-seed-$CTIERVERS.jar $LOCALREPO/ctier-base-seed/jars/ctier-base-seed-$CTIERVERS.jar || (echo "CTIER common build failed: cannot copy target/distributions/ctier-base-seed/jars/ctier-base-seed-$CTIERVERS.jar" && exit 1)

#########################
#
# CTIER workbench build
#

cd $CTIERSVN/workbench

echo maven.repo.ctlocal = $LOCALREPOURL > build.properties
$MAVEN_HOME/bin/maven -Djava.net.preferIPv4Stack=true java:jar-resources
$MAVEN_HOME/bin/maven -Djava.net.preferIPv4Stack=true java:jar war


mkdir -p $LOCALREPO/itnav/wars
cp target/itnav.war $LOCALREPO/itnav/wars/itnav-$CTIERVERS.war	|| (echo "Workbench build failed: cannot copy target/itnav.war" && exit 1)

##################
#
# CTIER commander-extension build
#
cd $CTIERSVN/commander
$MAVEN_HOME/bin/maven -Djava.net.preferIPv4Stack=true java:jar-resources 
$MAVEN_HOME/bin/maven -Djava.net.preferIPv4Stack=true extension:package
   
#    artifacts: commander-extension-X.jar, commander-X.jar
mkdir -p $LOCALREPO/commander-extension/jars
mkdir -p $LOCALREPO/commander/jars
cp dist/jars/commander-extension-$CTIERVERS.jar $LOCALREPO/commander-extension/jars/commander-extension-$CTIERVERS.jar || (echo "CTIER commander-extension build failed: cannot copy dist/jars/commander-extension-$CTIERVERS.jar" && exit 1)
cp target/commander-$CTIERVERS.jar $LOCALREPO/commander/jars/commander-$CTIERVERS.jar || (echo "CTIER commander-extension build failed: cannot copy target/commander-$CTIERVERS.jar" && exit 1)

##################
#
# Download coreutils-extension jar
#

mkdir -p $LOCALREPO/coreutils-extension/jars
cd $LOCALREPO/coreutils-extension/jars
wget -N http://ctl-dispatch.sourceforge.net/repository/coreutils-extension/jars/coreutils-extension-0.9.jar || (echo "Couldn't get coreutils-extension" && exit 1 )

##################
#
# CTL bundle build
#

cd $CTLSVN/bundle
export MAVEN_HOME=../maven
echo maven.repo.ctier = $LOCALREPOURL > build.properties
$MAVEN_HOME/bin/maven clean ctl:bundle

#!! failed to download ctl-dispatch.jar ... !!!

# artifacts: ctl-X.tgz, ctl-X.zip
mkdir -p $LOCALREPO/ctl/zips
mkdir -p $LOCALREPO/ctl/tgzs
cp target/dist/zips/ctl-$CTLVERS.zip $LOCALREPO/ctl/zips/ctl-$CTLVERS.zip || (echo "CTL bundle build failed: cannot copy target/dist/zips/ctl-$CTLVERS.zip" && exit 1)
cp target/dist/tgzs/ctl-$CTLVERS.tgz $LOCALREPO/ctl/tgzs/ctl-$CTLVERS.tgz || (echo "CTL bundle build failed: cannot copy target/dist/tgzs/ctl-$CTLVERS.tgz" && exit 1)

#####################
#
# Jobcenter build
#

cd $JCSVN
# copy the dependencies into the lib directory
cp $LOCALREPO/ctl/jars/ctl-$CTLVERS.jar lib/
cp $LOCALREPO/ctier-common/jars/ctier-common-$CTIERVERS.jar lib/
cp $LOCALREPO/ctier-common-vocabulary/jars/ctier-common-vocabulary-$CTIERVERS.jar lib/
cp $LOCALREPO/commander/jars/commander-$CTIERVERS.jar lib/
export PATH=$PATH:$GRAILS_HOME/bin
$ANT_HOME/bin/ant -Djetty.archive.available=true -f build.xml dist || (echo "Jobcenter build failed" && exit 1)

# artifacts: jobcenter-X.zip
mkdir -p $LOCALREPO/jobcenter/zips
cp target/jobcenter-$JCVERS.zip $LOCALREPO/jobcenter/zips/jobcenter-$JCVERS.zip || (echo "Jobcenter build failed: cannot copy target/jobcenter-$JCVERS.zip" && exit 1)


######################
#
# Reportcenter build
#

cd $CTIERSVN/reportcenter
# copy the dependencies into the lib directory
cp $LOCALREPO/ctier-common/jars/ctier-common-$CTIERVERS.jar lib/
export PATH=$PATH:$GRAILS_HOME/bin
$ANT_HOME/bin/ant -Djetty.archive.available=true -f build.xml dist || (echo "Reportcenter build failed" && exit 1)

#artifacts: reportcenter-X.zip
mkdir -p $LOCALREPO/reportcenter/zips
cp target/reportcenter-$RCVERS.zip $LOCALREPO/reportcenter/zips/reportcenter-$RCVERS.zip || (echo "Reportcenter build failed: cannot copy target/reportcenter-$RCVERS.zip" && exit 1)


######################
#
# Installer build
#

cd $CTIERSVN/installer
	
echo maven.repo.ctlocal = $LOCALREPOURL > build.properties
$MAVEN_HOME/bin/maven -Djava.net.preferIPv4Stack=true clean installer:create || (echo "Installer build failed" && exit 1)

#artifacts: ControlTier-Installer-$CTIERVERS.jar, ControlTier-$CTIERVERS.zip

ls target/dist/ControlTier-Installer/jars/ControlTier-Installer-$CTIERVERS.jar || (echo "Installer build failed: couldn't find target/dist/ControlTier-Installer/jars/ControlTier-Installer-$CTIERVERS.jar" && exit 1)
ls target/dist/ControlTier/zips/ControlTier-$CTIERVERS.zip || (echo "Installer build failed: couldn't find target/dist/ControlTier/zips/ControlTier-$CTIERVERS.zip" && exit 1)
