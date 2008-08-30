#!/bin/bash
# ---------------------------------------------------------------------------
# Stop script for the ControlTier Server
# ---------------------------------------------------------------------------


export JETTY_HOME=${server.jetty.home}

PIDFILE=$JETTY_LOGS/jetty.pid

test -f $PIDFILE || {
    echo "Jetty is not running."
    exit 0
}

PID=`cat $PIDFILE`

ps -p "$PID" > /dev/null
[ "$?" != 0 ] && {
    echo "Jetty not running."
    exit 0
}

echo -n "Stopping Jetty: "
kill "$PID" || {
    echo "FAILED"
    exit 1
}
echo "OK"
rm $PIDFILE
