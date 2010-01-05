#!/bin/bash
# ---------------------------------------------------------------------------
# Start script for the ControlTier Server
# ---------------------------------------------------------------------------

# Server settings
export JETTY_HOME=${server.jetty.home}
export JETTY_LOGS=${server.jetty.home.converted}/logs
export JETTY_RUN=$JETTY_LOGS
export JAVA_HOME=${USER_ENV.JAVA_HOME}
CONFIG_PROPS="-Dctlcenter.config.location=${env.ctier_root}/ctlcenter/ctlcenter-config.properties"
export JAVA_OPTIONS="-XX:MaxPermSize=128m -Xmx1024m -Xms256m $CONFIG_PROPS"

test -f $JETTY_LOGS/jetty.pid && {
    PID=`cat $JETTY_LOGS/jetty.pid`
    ps -p "$PID" > /dev/null
    [ "$?" = 0 ] && {
	echo "Jetty is already running (pid=$PID)"
	exit 1;
    }
}

DSTAMP=`date +%Y_%m_%d`
LOGFILE=$JETTY_LOGS/$DSTAMP.stderrout.log

echo -n "Starting Jetty: "
cd $JETTY_HOME
"$JAVA_HOME/bin/java" \
    $JAVA_OPTIONS \
    -jar "$JETTY_HOME/start.jar" \
    $JETTY_HOME/etc/jetty.xml >> $LOGFILE 2>&1 &

[ $? = 0 ] && {
    echo $! > $JETTY_LOGS/jetty.pid
    echo "OK"
    echo "Jetty started (pid=$!). Redirecting stderr/stdout to $LOGFILE"
} || {
    echo "FAILED"
    exit 1;
}

