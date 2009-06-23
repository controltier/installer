#!/bin/sh

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ] || [ -z "$5" ] || [ -z "$6" ]  || [ -z "$7" ]  ; then
    echo "usage: newrelease <ctl-version> <ctl-path> <ctier-version> <ct-path> <jc-version> <jc-path> <mf-path>  [-status | -commit]"
    exit 1
fi

IDENT="release"


CTLVER=$1
CTLVERNAME=`echo $CTLVER | perl -pe 's/\./-/g'`
CTLPATH=$2
CTVER=$3
CTVERNAME=`echo $CTVER | perl -pe 's/\./-/g'`
CTPATH=$4
JCVER=$5
JCVERNAME=`echo $JCVER | perl -pe 's/\./-/g'`
JCPATH=$6

#moduleforge/controltier source path
MFPATH=$7

CTLURL=`svn info --xml --non-interactive $CTLPATH | grep url | perl -pe 's/<.+?>//g' ` 
CTURL=`svn info --xml --non-interactive $CTPATH | grep url | perl -pe 's/<.+?>//g' ` 
JCURL=`svn info --xml --non-interactive $JCPATH | grep url | perl -pe 's/<.+?>//g' | perl -pe 's{/branches/(.+?)/.*$}{/branches/\1}'` 
MFURL=`svn info --xml --non-interactive $MFPATH | grep url | perl -pe 's/<.+?>//g' ` 

CTLBRANCH=`echo $CTLURL | perl -pe 's#^.*?/branches/(.*?)/?$#\1#g'`
CTBRANCH=`echo $CTURL | perl -pe 's#^.*?/branches/(.*?)/?$#\1#g'`
JCBRANCH=`echo $JCURL | perl -pe 's#^.*?/branches/(.*?)/?$#\1#g'`
MFBRANCH=`echo $MFURL | perl -pe 's#^.*?/branches/(.*?)/?$#\1#g'`

CTLBASE=`echo $CTLURL | perl -pe 's#/branches/.*##g'`
CTBASE=`echo $CTURL | perl -pe 's#/branches/.*##g'`
JCBASE=`echo $JCURL | perl -pe 's#/branches/.*##g'`
MFBASE=`echo $MFURL | perl -pe 's#/branches/.*##g'`

CTLTAG="$CTLBASE/tags/ctl-dispatch-$CTLVERNAME-$IDENT"
CTTAG="$CTBASE/tags/controltier-$CTVERNAME-$IDENT"
JCTAG="$JCBASE/tags/jobcenter-$JCVERNAME-$IDENT"
MFTAG="$MFBASE/tags/controltier-$CTVERNAME-$IDENT"


if [ "$8" == "-commit" ] ; then
    svn copy -m \""Tag $CTLVER release from $CTLBRANCH branch"\" $CTLURL $CTLTAG ;
    svn copy -m \""Tag $CTVER release from $CTBRANCH branch"\" $CTURL $CTTAG ;
    svn copy -m \""Tag $JCVER release from $JCBRANCH branch"\" $JCURL $JCTAG ;
    svn copy -m \""Tag $CTVER release from $MFBRANCH branch"\" $MFURL $MFTAG ;
    echo COMMITED TAGS ;
else
    echo svn copy -m \""Tag $CTLVER release from $CTLBRANCH branch"\" $CTLURL $CTLTAG ;
    echo svn copy -m \""Tag $CTVER release from $CTBRANCH branch"\" $CTURL $CTTAG ;
    echo svn copy -m \""Tag $JCVER release from $JCBRANCH branch"\" $JCURL $JCTAG ;
    echo svn copy -m \""Tag $CTVER release from $MFBRANCH branch"\" $MFURL $MFTAG ;

    echo "Use -commit to commit commit to execute these commands"
fi

#echo ant -Dctl.branchname=$CTLBRANCH -Dctl.path=$CTLPATH -Dctier.branchname=$CTBRANCH -Dctier.path=$CTPATH -Djc.branchname=$JCBRANCH -Djc.path=$JCPATH -Drc.branchname=$CTBRANCH -f $CTPATH/ctbuild/build.xml 


