set JAVA_HOME=$JDKPath

@rem Check if JAVA_HOME is set to a valid JDK
@rem @@@TODO

if NOT "$POST_INSTALL_START_SERVICES" == "true" (
   GOTO:EOF
)

cd "$USER_HOME"
call CTIER.BAT
echo "Starting Workbench server..."
cd "$INSTALL_PATH\workbench\bin"
call STARTUP.BAT

cd "$INSTALL_PATH\pkgs\jobcenter-$JCVERSION\bin"
start "Jobcenter-$JCVERSION ($INSTALL_JOBCENTER_PORT)" START-JOBCENTER.BAT

exit 0
