###################################
# script for full controltier build
###################################

# configure JAVA_HOME and BUILD_ROOT as required
#export JAVA_HOME=/usr/java/jdk1.5.0_15
if [ -z "$BUILD_ROOT" ] ; then
    export BUILD_ROOT=$HOME/build
fi

if [ ! -f $JAVA_HOME/bin/java ] ; then
    echo "ERROR: java is not configured correctly.  Set JAVA_HOME."
    exit 1
fi

if [ ! -f $HOME/.ssh/id_dsa.pub ] ; then
    echo "ERROR: $HOME/.ssh/id_dsa file must exist.  Please run: ssh-keygen -t dsa"
    exit 1
fi

CTLVERS=3.5.0
CTIERVERS=3.5.0

CTLSVNROOT="https://ctl-dispatch.svn.sourceforge.net/svnroot/ctl-dispatch"
CTIERSVNROOT="https://controltier.svn.sourceforge.net/svnroot/controltier"
SEEDSVNROOT="https://moduleforge.svn.sourceforge.net/svnroot/moduleforge/controltier"

CTLBRANCH=ctl-dispatch-3-5-dev
CTIERBRANCH=controltier-3-5-dev

#grails version for ctl-center
GRAILSVERS=1.2.0

prepare_build(){

mkdir $BUILD_ROOT

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
    if [ ! -z "$PKGREPO" -a -f $PKGREPO/apache-ant/zips/apache-ant-1.7.1p1.zip ] ; then
        cp $PKGREPO/apache-ant/zips/apache-ant-1.7.1p1.zip $LOCALREPO/apache-ant/zips/
    else
        # get ant zip dependency to local repo if it doesn't exist
        cd $LOCALREPO/apache-ant/zips
        wget -N http://ctl-dispatch.sourceforge.net/repository/apache-ant/zips/apache-ant-1.7.1p1.zip
    fi
fi

# extract apache-ant to local dir for use during build
if [ ! -f $BUILD_ROOT/local/apache-ant-1.7.1p1/bin/ant ] ; then
    cd $BUILD_ROOT/local
    unzip -o $LOCALREPO/apache-ant/zips/apache-ant-1.7.1p1.zip
fi

export ANT_HOME=$BUILD_ROOT/local/apache-ant-1.7.1p1

# extract grails to local dir for use during build of CTL Center
if [ ! -f $BUILD_ROOT/local/grails-$GRAILSVERS/bin/grails ] ; then 
    if [ ! -z "$PKGREPO" -a -f $PKGREPO/grails/zips/grails-$GRAILSVERS.zip ] ; then
        cd $BUILD_ROOT/local
        unzip $PKGREPO/grails/zips/grails-$GRAILSVERS.zip
    else
        # get grails bin distribution
        cd $BUILD_ROOT/dl
        wget -N http://dist.codehaus.org/grails/grails-$GRAILSVERS.zip
        cd $BUILD_ROOT/local
        unzip $BUILD_ROOT/dl/grails-$GRAILSVERS.zip
    fi
fi

export GRAILS_HOME_111=$BUILD_ROOT/local/grails-$GRAILSVERS


# begin checkout of sources

cd $BUILD_ROOT

#checkout ctier source
if [ ! -d ctiersvn ] ; then
    svn co $CTIERSVNROOT/branches/$CTIERBRANCH ctiersvn
    if [ 0 != $? ]
    then
       echo "CTIER src checkout failed"
       exit 2
    fi
else
    svn up ctiersvn
    if [ 0 != $? ]
    then
       echo "CTIER src checkout failed"
       exit 2
    fi
fi
export CTIERSVN=$BUILD_ROOT/ctiersvn


#checkout ctl source
if [ ! -d ctlsvn ] ; then
    svn co $CTLSVNROOT/branches/$CTLBRANCH ctlsvn
    if [ 0 != $? ]
    then
       echo "CTL src checkout failed"
       exit 2
    fi
else
    svn up ctlsvn
    if [ 0 != $? ]
    then
       echo "CTL src checkout failed"
       exit 2
    fi
fi
export CTLSVN=$BUILD_ROOT/ctlsvn

export CCSVN=$CTIERSVN/ctl-center

#checkout modules source
if [ ! -d ctierseedsvn ] ; then
    svn co $SEEDSVNROOT/branches/$CTIERBRANCH ctierseedsvn
    if [ 0 != $? ]
    then
       echo "Controltier Seed src checkout failed"
       exit 2
    fi
else
    svn revert --recursive ctierseedsvn
    svn up ctierseedsvn
    if [ 0 != $? ]
    then
       echo "Controltier Seed src checkout failed"
       exit 2
    fi
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
if [ 0 != $? ]
then
   echo "CTL build failed"
   exit 2
fi
cd $CTLSVN && $MAVEN_HOME/bin/maven ctl:stgz ctl:tgz ctl:zip
if [ 0 != $? ]
then
   echo "CTL build failed"
   exit 2
fi
#remove previous build artifacts from maven repository
rm -rf $CTIERSVN/maven/repository/ctl
rm -rf $CTIERSVN/maven/repository/ctl-dispatch

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
cd $CTIERSVN/common && $MAVEN_HOME/bin/maven -Djava.net.preferIPv4Stack=true clean java:jars
if [ 0 != $? ]
then
   echo "CTIER common build failed"
   exit 2
fi  
		
rm -rf $CTIERSVN/maven/repository/ctier-common
rm -rf $CTIERSVN/maven/repository/ctier-common-vocabulary

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
		
rm -rf $CTIERSVN/maven/repository/controltier-seed

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
cd $CTIERSVN/workbench && $MAVEN_HOME/bin/maven -Djava.net.preferIPv4Stack=true clean java:jar-resources
if [ 0 != $? ]
then
   echo "Workbench build failed"
   exit 2
fi  
cd $CTIERSVN/workbench && $MAVEN_HOME/bin/maven -Djava.net.preferIPv4Stack=true java:jar war
if [ 0 != $? ]
then
   echo "Workbench build failed"
   exit 2
fi  

rm -rf $CTIERSVN/maven/repository/itnav

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
cd $CTIERSVN/commander && $MAVEN_HOME/bin/maven -Djava.net.preferIPv4Stack=true clean java:jar-resources 
if [ 0 != $? ]
then
   echo "CTIER commander-extension build failed "
   exit 2
fi  
cd $CTIERSVN/commander && $MAVEN_HOME/bin/maven -Djava.net.preferIPv4Stack=true extension:package
if [ 0 != $? ]
then
   echo "CTIER commander-extension build failed "
   exit 2
fi  

rm -rf $CTIERSVN/maven/repository/commander
rm -rf $CTIERSVN/maven/repository/commander-extension
rm -rf $CTLSVN/maven/repository/commander-extension
   
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
if [ 0 != $? ]
then
   echo "CTL bundle build failed"
   exit 2
fi  

#!! failed to download ctl-dispatch.jar ... !!!

rm -rf $CTIERSVN/maven/repository/ctl/tgzs
rm -rf $CTIERSVN/maven/repository/ctl/zips

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

build_ctl_center(){
#####################
#
# CTL Center build
#

cd $CCSVN
# copy the dependencies into the lib directory
cp $LOCALREPO/ctl/jars/ctl-$CTLVERS.jar lib/
cp $LOCALREPO/ctier-common/jars/ctier-common-$CTIERVERS.jar lib/
cp $LOCALREPO/ctier-common-vocabulary/jars/ctier-common-vocabulary-$CTIERVERS.jar lib/
cp $LOCALREPO/commander/jars/commander-$CTIERVERS.jar lib/
MYPATH=$PATH
export GRAILS_HOME=$GRAILS_HOME_111
export PATH=$PATH:$GRAILS_HOME/bin

#echo 'y' to the command to quell y/n prompt on second time running it:
echo -e "y\n" | $GRAILS_HOME/bin/grails install-plugin $CCSVN/plugins/grails-webrealms-0.1.zip

# run clean and test 
$ANT_HOME/bin/ant -Djetty.archive.available=true -f build.xml clean test
if [ 0 != $? ]
then
   echo "CTL Center tests failed"
   exit 2
fi  

#run dist phase
$ANT_HOME/bin/ant -Djetty.archive.available=true -f build.xml dist 
if [ 0 != $? ]
then
   echo "CTL Center build failed"
   exit 2
fi  

rm -rf $CTIERSVN/maven/repository/ctlcenter

# artifacts: ctlcenter-X.zip
mkdir -p $LOCALREPO/ctlcenter/zips
cp target/ctlcenter-$CTIERVERS.zip $LOCALREPO/ctlcenter/zips/ctlcenter-$CTIERVERS.zip 
if [ 0 != $? ]
then
   echo "Ctl Center build failed: cannot copy target/ctlcenter-$CTIERVERS.zip"
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
rm -rf $CTIERSVN/examples/target
mkdir -p $CTIERSVN/examples/target
svn export . $CTIERSVN/examples/target/examples
if [ 0 != $? ]
then
   echo "Examples source svn export failed"
   exit 2
fi  

cd target
zip -r ctier-examples-$CTIERVERS.zip examples
if [ 0 != $? ]
then
   echo "Examples package build failed"
   exit 2
fi  

rm -rf $CTIERSVN/examples/target/examples
rm -rf $CTIERSVN/maven/repository/ctier-examples

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

build_client_rpm(){
######################
#
# Installer build
#
MAVEN_HOME=$CTIERSVN/maven	
cd $CTIERSVN/installer
	
echo maven.repo.ctlocal = $LOCALREPOURL > $CTIERSVN/installer/build.properties
cd $CTIERSVN/installer && $MAVEN_HOME/bin/maven -Djava.net.preferIPv4Stack=true clean client:rpmbuild
if [ 0 != $? ]
then
   echo "Installer build failed"
   exit 2
fi  


#artifacts: ctier-client-$CTIERVERS-1.noarch.rpm

#ctier-client-3.4.9-1.noarch.rpm
ls $CTIERSVN/installer/target/rpm/RPMS/noarch/ctier-client-${CTIERVERS}-1.noarch.rpm 
if [ 0 != $? ]
then
   echo "Installer build failed: couldn't find target/rpmbuild/ctier-client-$CTIERVERS.rpm"
   exit 2
fi  

}
build_server_rpm(){
######################
#
# Installer build
#
MAVEN_HOME=$CTIERSVN/maven	
cd $CTIERSVN/installer
	
echo maven.repo.ctlocal = $LOCALREPOURL > $CTIERSVN/installer/build.properties
cd $CTIERSVN/installer && $MAVEN_HOME/bin/maven -Djava.net.preferIPv4Stack=true server:rpmbuild-full
if [ 0 != $? ]
then
   echo "Installer build failed"
   exit 2
fi  


#artifacts: ctier-client-$CTIERVERS-1.noarch.rpm

#ctier-client-3.4.9-1.noarch.rpm
ls $CTIERSVN/installer/target/rpm/RPMS/noarch/ctier-server-${CTIERVERS}-1.noarch.rpm 
if [ 0 != $? ]
then
   echo "Installer build failed: couldn't find target/rpmbuild/ctier-server-$CTIERVERS.rpm"
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
    build_ctl_center
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
            ctl_center)
                build_ctl_center
                ;;
            examples)
                build_examples
                ;;
            installer)
                build_installer
                ;;
            client_rpm)
                build_client_rpm
                ;;
            server_rpm)
                build_server_rpm
                ;;
            *)
                echo unknown action: ${i}
                exit 1
            ;;
        esac
    done
    exit 0
fi
