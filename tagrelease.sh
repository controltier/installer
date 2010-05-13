#!/bin/sh

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ] ; then
    echo "usage: newrelease <ctier-version> <ctl-path> <ct-path> <mf-path> [-status | -commit]"
    exit 1
fi

IDENT="release"

CTVER=$1
CTLVER=$CTVER
CTLVERNAME=`echo $CTLVER | perl -pe 's/\./-/g'`
CTLPATH=$2
CTVERNAME=`echo $CTVER | perl -pe 's/\./-/g'`
CTPATH=$3

#moduleforge/controltier source path
MFPATH=$4

CTLURL=`svn info --xml --non-interactive $CTLPATH | grep url | perl -pe 's/<.+?>//g' ` 
CTURL=`svn info --xml --non-interactive $CTPATH | grep url | perl -pe 's/<.+?>//g' ` 
MFURL=`svn info --xml --non-interactive $MFPATH | grep url | perl -pe 's/<.+?>//g' ` 

CTLBRANCH=`echo $CTLURL | perl -pe 's#^.*?/branches/(.*?)/?$#\1#g'`
CTBRANCH=`echo $CTURL | perl -pe 's#^.*?/branches/(.*?)/?$#\1#g'`
MFBRANCH=`echo $MFURL | perl -pe 's#^.*?/branches/(.*?)/?$#\1#g'`

CTLBASE=`echo $CTLURL | perl -pe 's#/branches/.*##g'`
CTBASE=`echo $CTURL | perl -pe 's#/branches/.*##g'`
MFBASE=`echo $MFURL | perl -pe 's#/branches/.*##g'`

CTLTAG="$CTLBASE/tags/ctl-dispatch-$CTLVERNAME-$IDENT"
CTTAG="$CTBASE/tags/controltier-$CTVERNAME-$IDENT"
MFTAG="$MFBASE/tags/controltier-$CTVERNAME-$IDENT"


if [ "$5" == "-commit" ] ; then
    svn copy -m \""Tag $CTLVER $IDENT from $CTLBRANCH branch"\" $CTLURL $CTLTAG ;
    svn copy -m \""Tag $CTVER $IDENT from $CTBRANCH branch"\" $CTURL $CTTAG ;
    svn copy -m \""Tag $CTVER $IDENT from $MFBRANCH branch"\" $MFURL $MFTAG ;
    echo COMMITED TAGS ;
else
    echo svn copy -m \""Tag $CTLVER $IDENT from $CTLBRANCH branch"\" $CTLURL $CTLTAG ;
    echo svn copy -m \""Tag $CTVER $IDENT from $CTBRANCH branch"\" $CTURL $CTTAG ;
    echo svn copy -m \""Tag $CTVER $IDENT from $MFBRANCH branch"\" $MFURL $MFTAG ;

    echo "Use -commit to commit commit to execute these commands"
fi


