###################################
# script for full controltier build
###################################

# configure JAVA_HOME and BUILD_ROOT as required
#export JAVA_HOME=/usr/java/jdk1.5.0_15
export BUILD_ROOT=$HOME/build

if [ ! -f $JAVA_HOME/bin/java ] ; then
    echo "ERROR: java is not configured correctly.  Set JAVA_HOME."
    exit 1
fi

if [ ! -f $HOME/.ssh/id_dsa.pub ] ; then
    echo "ERROR: $HOME/.ssh/id_dsa file must exist.  Please run: ssh-keygen -t dsa"
    exit 1
fi

CTLVERS=1.4.9
CTIERVERS=3.4.9
RCVERS=0.8.9
JCVERS=1.4.9


CTLSVNROOT="https://ctl-dispatch.svn.sourceforge.net/svnroot/ctl-dispatch"
CTIERSVNROOT="https://controltier.svn.sourceforge.net/svnroot/controltier"
JCSVNROOT="https://webad.svn.sourceforge.net/svnroot/webad"
SEEDSVNROOT="https://moduleforge.svn.sourceforge.net/svnroot/moduleforge/controltier"

CTLBRANCH=ctl-dispatch-1-4-support
CTIERBRANCH=controltier-3-4-support
JCBRANCH=jobcenter-1-4-support

prepare_build(){

# dl dir is for downloaded files
mkdir $BUILD_ROOT/dl

# local dir is for installed components needed for build
mkdir $BUILD_ROOT/local

# localrepo dir is the local repository for intermediate build files and other dependencies
mkdir $BUILD_ROOT/localrepo
export LOCALREPO=$BUILD_ROOT/localrepo
export LOCALREPOURL=file:$LOCALREPO


mkdir -p $LOCALREPO/apache-ant/zips
if [ ! -f $LOCALREPO/apache-ant/zips/apache-ant-1.7.1p1.zip ] ; then
    # get ant zip dependency to local repo if it doesn't exist
    cd $LOCALREPO/apache-ant/zips
    wget -N http://ctl-dispatch.sourceforge.net/repository/apache-ant/zips/apache-ant-1.7.1p1.zip
fi

# extract apache-ant to local dir for use during build
if [ ! -f $BUILD_ROOT/local/apache-ant-1.7.1p1/bin/ant ] ; then
    cd $BUILD_ROOT/local
    unzip -o $LOCALREPO/apache-ant/zips/apache-ant-1.7.1p1.zip
fi

export ANT_HOME=$BUILD_ROOT/local/apache-ant-1.7.1p1


# extract grails to local dir for use during build
if [ ! -f $BUILD_ROOT/local/grails-1.0.3/bin/grails ] ; then 
    # get grails bin distribution
    cd $BUILD_ROOT/dl
    wget -N http://dist.codehaus.org/grails/grails-bin-1.0.3.tar.gz
    cd $BUILD_ROOT/local
    tar xvzf $BUILD_ROOT/dl/grails-bin-1.0.3.tar.gz
fi

export GRAILS_HOME_103=$BUILD_ROOT/local/grails-1.0.3

# extract grails 1.1.1 to local dir for use during build of Jobcenter
if [ ! -f $BUILD_ROOT/local/grails-1.1.1/bin/grails ] ; then 
    # get grails bin distribution
    cd $BUILD_ROOT/dl
    wget -N http://dist.codehaus.org/grails/grails-bin-1.1.1.tar.gz
    cd $BUILD_ROOT/local
    tar xvzf $BUILD_ROOT/dl/grails-bin-1.1.1.tar.gz
fi

export GRAILS_HOME_111=$BUILD_ROOT/local/grails-1.1.1


# begin checkout of sources

cd $BUILD_ROOT

#checkout ctier source
svn co $CTIERSVNROOT/branches/$CTIERBRANCH ctiersvn
if [ 0 != $? ]
then
   echo "CTIER src checkout failed"
   exit 2
fi
export CTIERSVN=$BUILD_ROOT/ctiersvn

#checkout ctl source
svn co $CTLSVNROOT/branches/$CTLBRANCH ctlsvn
if [ 0 != $? ]
then
   echo "CTL src checkout failed"
   exit 2
fi
export CTLSVN=$BUILD_ROOT/ctlsvn

#checkout jobcenter source
svn co $JCSVNROOT/branches/$JCBRANCH/webad jobcentersvn
if [ 0 != $? ]
then
   echo "Jobcenter src checkout failed"
   exit 2
fi
export JCSVN=$BUILD_ROOT/jobcentersvn

#checkout modules source
svn co $SEEDSVNROOT/branches/$CTIERBRANCH ctierseedsvn
if [ 0 != $? ]
then
   echo "Controltier Seed src checkout failed"
   exit 2
fi
export SEEDSVN=$BUILD_ROOT/ctierseedsvn

}


build_ctl(){
#########################
#
# CTL build
#
# NOTE: if $HOME/.ssh/id_dsa does not exist, run ssh-keygen:
# ssh-keygen -t dsa


cd $CTLSVN
echo maven.repo.ctierlocal = $LOCALREPOURL > build.properties
MAVEN_HOME=$CTLSVN/maven
cd $CTLSVN && $MAVEN_HOME/bin/maven clean ctl:antConfigure
cd $CTLSVN && $MAVEN_HOME/bin/maven ctl:stgz ctl:tgz ctl:zip

mkdir -p $LOCALREPO/ctl/jars
mkdir -p $LOCALREPO/ctl/tgzs
mkdir -p $LOCALREPO/ctl-dispatch/tgzs
mkdir -p $LOCALREPO/ctl/zips
mkdir -p $LOCALREPO/ctl-dispatch/zips
cp target/ctl-dispatch-$CTLVERS.jar $LOCALREPO/ctl/jars/ctl-$CTLVERS.jar 
if [ 0 != $? ]
then
   echo "CTL build failed: cannot copy target/ctl-dispatch-$CTLVERS.jar"
   exit 2
fi

cp target/dist/zips/ctl-dispatch-$CTLVERS.zip $LOCALREPO/ctl/zips/ctl-$CTLVERS.zip 
if [ 0 != $? ]
then
   echo "CTL build failed: cannot copy target/dist/zips/ctl-dispatch-$CTLVERS.zip"
   exit 2
fi

cp target/dist/tgzs/ctl-dispatch-$CTLVERS.tgz $LOCALREPO/ctl/tgzs/ctl-$CTLVERS.tgz 
if [ 0 != $? ]
then
   echo "CTL build failed: cannot copy target/dist/tgzs/ctl-dispatch-$CTLVERS.tgz"
   exit 2
fi

cp target/dist/zips/ctl-dispatch-$CTLVERS.zip $LOCALREPO/ctl-dispatch/zips/ctl-dispatch-$CTLVERS.zip 
if [ 0 != $? ]
then
   echo "CTL build failed: cannot copy target/dist/zips/ctl-dispatch-$CTLVERS.zip"
   exit 2
fi

cp target/dist/tgzs/ctl-dispatch-$CTLVERS.tgz $LOCALREPO/ctl-dispatch/tgzs/ctl-dispatch-$CTLVERS.tgz 
if [ 0 != $? ]
then
   echo "CTL build failed: cannot copy target/dist/tgzs/ctl-dispatch-$CTLVERS.tgz"
   exit 2
fi
}

build_common(){
#######################
#
# CTIER common build
#
MAVEN_HOME=$CTIERSVN/maven	
echo maven.repo.ctlocal = $LOCALREPOURL >  $CTIERSVN/common/build.properties
cd $CTIERSVN/common
cd $CTIERSVN/common && $MAVEN_HOME/bin/maven -Djava.net.preferIPv4Stack=true java:jars
		

mkdir -p $LOCALREPO/ctier-common/jars
mkdir -p $LOCALREPO/ctier-common-vocabulary/jars
cp target/distributions/ctier-common/jars/ctier-common-$CTIERVERS.jar $LOCALREPO/ctier-common/jars/ctier-common-$CTIERVERS.jar 
if [ 0 != $? ]
then
   echo "CTIER common build failed: cannot copy target/distributions/ctier-common/jars/ctier-common-$CTIERVERS.jar"
   exit 2
fi  
cp target/distributions/ctier-common-vocabulary/jars/ctier-common-vocabulary-$CTIERVERS.jar $LOCALREPO/ctier-common-vocabulary/jars/ctier-common-vocabulary-$CTIERVERS.jar 
if [ 0 != $? ]
then
   echo "CTIER common build failed: cannot copy target/distributions/ctier-common-vocabulary/jars/ctier-common-vocabulary-$CTIERVERS.jar"
   exit 2
fi  
}

build_controltier_seed(){
######################
#
# CTIER Seed build
#
# Note: this step uses the common sourcebase and maven dependency to build the controltier-seed
#
MAVEN_HOME=$CTIERSVN/maven	
echo maven.repo.ctlocal = $LOCALREPOURL >  $CTIERSVN/common/build.properties

mkdir -p $SEEDSVN/target
cd $CTIERSVN/common
cd $CTIERSVN/common && $MAVEN_HOME/bin/maven -Dseed.name=controltier -Dseed.build.name=controltier-seed-$CTIERVERS -Dseed.modulesrc.dir=$SEEDSVN/core/modules,$SEEDSVN/elements/modules -Dseed.target.dir=$SEEDSVN/target seed:build
if [ 0 != $? ]
then
   echo "Ctier Seed build failed: unable to create the controltier-seed-$CTIERVERS.jar"
   exit 2
fi  

mkdir -p $LOCALREPO/controltier-seed/jars
cp $SEEDSVN/target/controltier-seed-$CTIERVERS.jar $LOCALREPO/controltier-seed/jars/controltier-seed-$CTIERVERS.jar 
if [ 0 != $? ]
then
   echo "Ctier Seed build failed: cannot copy target/controltier-seed-$CTIERVERS.jar"
   exit 2
fi  
}

build_workbench(){
#########################
#
# CTIER workbench build
#

MAVEN_HOME=$CTIERSVN/maven	
cd $CTIERSVN/workbench

echo maven.repo.ctlocal = $LOCALREPOURL > $CTIERSVN/workbench/build.properties
cd $CTIERSVN/workbench && $MAVEN_HOME/bin/maven -Djava.net.preferIPv4Stack=true java:jar-resources
cd $CTIERSVN/workbench && $MAVEN_HOME/bin/maven -Djava.net.preferIPv4Stack=true java:jar war


mkdir -p $LOCALREPO/itnav/wars
cp target/itnav.war $LOCALREPO/itnav/wars/itnav-$CTIERVERS.war	
if [ 0 != $? ]
then
   echo "Workbench build failed: cannot copy target/itnav.war"
   exit 2
fi  
}

build_commander_extension(){
##################
#
# CTIER commander-extension build
#
MAVEN_HOME=$CTIERSVN/maven	
cd $CTIERSVN/commander

echo maven.repo.ctlocal = $LOCALREPOURL > $CTIERSVN/commander/build.properties
cd $CTIERSVN/commander && $MAVEN_HOME/bin/maven -Djava.net.preferIPv4Stack=true java:jar-resources 
cd $CTIERSVN/commander && $MAVEN_HOME/bin/maven -Djava.net.preferIPv4Stack=true extension:package
   
#    artifacts: commander-extension-X.jar, commander-X.jar
mkdir -p $LOCALREPO/commander-extension/jars
mkdir -p $LOCALREPO/commander/jars
cp dist/jars/commander-extension-$CTIERVERS.jar $LOCALREPO/commander-extension/jars/commander-extension-$CTIERVERS.jar 
if [ 0 != $? ]
then
   echo "CTIER commander-extension build failed: cannot copy dist/jars/commander-extension-$CTIERVERS.jar"
   exit 2
fi  

cp target/commander-$CTIERVERS.jar $LOCALREPO/commander/jars/commander-$CTIERVERS.jar 
if [ 0 != $? ]
then
   echo "CTIER commander-extension build failed: cannot copy target/commander-$CTIERVERS.jar"
   exit 2
fi  
}


build_ctl_bundle(){
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
cp target/dist/zips/ctl-$CTLVERS.zip $LOCALREPO/ctl/zips/ctl-$CTLVERS.zip 
if [ 0 != $? ]
then
   echo "CTL bundle build failed: cannot copy target/dist/zips/ctl-$CTLVERS.zip"
   exit 2
fi  

cp target/dist/tgzs/ctl-$CTLVERS.tgz $LOCALREPO/ctl/tgzs/ctl-$CTLVERS.tgz 
if [ 0 != $? ]
then
   echo "CTL bundle build failed: cannot copy target/dist/tgzs/ctl-$CTLVERS.tgz"
   exit 2
fi  
#echo ctl_bundle disabled

}

build_jobcenter(){
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
MYPATH=$PATH
export GRAILS_HOME=$GRAILS_HOME_111
export PATH=$PATH:$GRAILS_HOME/bin
grails install-plugin $JCSVN/plugins/grails-webrealms-0.1.zip
$ANT_HOME/bin/ant -Djetty.archive.available=true -f build.xml dist 
if [ 0 != $? ]
then
   echo "Jobcenter build failed"
   exit 2
fi  


# artifacts: jobcenter-X.zip
mkdir -p $LOCALREPO/jobcenter/zips
cp target/jobcenter-$JCVERS.zip $LOCALREPO/jobcenter/zips/jobcenter-$JCVERS.zip 
if [ 0 != $? ]
then
   echo "Jobcenter build failed: cannot copy target/jobcenter-$JCVERS.zip"
   exit 2
fi  
export PATH=$MYPATH
export GRAILS_HOME=

}

build_reportcenter(){
######################
#
# Reportcenter build
#

cd $CTIERSVN/reportcenter
# copy the dependencies into the lib directory
cp $LOCALREPO/ctier-common/jars/ctier-common-$CTIERVERS.jar lib/
MYPATH=$PATH
export GRAILS_HOME=$GRAILS_HOME_103
export PATH=$PATH:$GRAILS_HOME/bin
$ANT_HOME/bin/ant -Djetty.archive.available=true -f build.xml dist 
if [ 0 != $? ]
then
   echo "Reportcenter build failed"
   exit 2
fi  


#artifacts: reportcenter-X.zip
mkdir -p $LOCALREPO/reportcenter/zips
cp target/reportcenter-$RCVERS.zip $LOCALREPO/reportcenter/zips/reportcenter-$RCVERS.zip 
if [ 0 != $? ]
then
   echo "Reportcenter build failed: cannot copy target/reportcenter-$RCVERS.zip"
   exit 2
fi  
export PATH=$MYPATH
export GRAILS_HOME=
}

build_examples(){
######################
#
# examples package build
#
cd $CTIERSVN/examples
mkdir -p $CTIERSVN/examples/target
svn export . $CTIERSVN/examples/target/examples
cd target
zip -r ctier-examples-$CTIERVERS.zip examples
if [ 0 != $? ]
then
   echo "Examples package build failed"
   exit 2
fi  

#artifacts: ctier-examples-X.zip
mkdir -p $LOCALREPO/ctier-examples/zips
cp $CTIERSVN/examples/target/ctier-examples-$CTIERVERS.zip $LOCALREPO/ctier-examples/zips/ctier-examples-$CTIERVERS.zip 
if [ 0 != $? ]
then
   echo "Examples build failed: cannot copy target/ctier-examples-$CTIERVERS.zip"
   exit 2
fi  

}

build_installer(){
######################
#
# Installer build
#
MAVEN_HOME=$CTIERSVN/maven	
cd $CTIERSVN/installer
	
echo maven.repo.ctlocal = $LOCALREPOURL > $CTIERSVN/installer/build.properties
cd $CTIERSVN/installer && $MAVEN_HOME/bin/maven -Djava.net.preferIPv4Stack=true clean installer:create 
if [ 0 != $? ]
then
   echo "Installer build failed"
   exit 2
fi  


#artifacts: ControlTier-Installer-$CTIERVERS.jar, ControlTier-$CTIERVERS.zip

ls target/dist/ControlTier-Installer/jars/ControlTier-Installer-$CTIERVERS.jar 
if [ 0 != $? ]
then
   echo "Installer build failed: couldn't find target/dist/ControlTier-Installer/jars/ControlTier-Installer-$CTIERVERS.jar"
   exit 2
fi  

ls target/dist/ControlTier/zips/ControlTier-$CTIERVERS.zip 
if [ 0 != $? ]
then
   echo "Installer build failed: couldn't find target/dist/ControlTier/zips/ControlTier-$CTIERVERS.zip"
   exit 2
fi  

}


if [ -z "$*" ] ; then

    prepare_build
    build_ctl
    build_common
    build_controltier_seed
    build_commander_extension
    build_workbench
    build_ctl_bundle
    build_jobcenter
    build_reportcenter
    build_examples
    build_installer
else
    prepare_build
    for i in $* ; do
        case "$i" in
            ctl)
                build_ctl
                ;;
            common)
                build_common
                ;;
            controltier_seed)
                build_controltier_seed
                ;;
            workbench)
                build_workbench
                ;;
            commander_extension)
                build_commander_extension
                ;;
            ctl_bundle)
                build_ctl_bundle
                ;;
            jobcenter)
                build_jobcenter
                ;;
            reportcenter)
                build_reportcenter
                ;;
            examples)
                build_examples
                ;;
            installer)
                build_installer
                ;;
            *)
                echo unknown action: ${i}
                exit 1
            ;;
        esac
    done
    exit 0
fi
