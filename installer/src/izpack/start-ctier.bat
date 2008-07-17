set JAVA_HOME=$JDKPath

@rem Check if JAVA_HOME is set to a valid JDK
@rem See http://docs.codehaus.org/display/JETTY/Win32Wrapper

if NOT "$POST_INSTALL_START_SERVICES" == "true" (
   GOTO:EOF
)

cd "$USER_HOME"
call CTIER.BAT
echo "Starting server..."
cd "${INSTALL_PATH}\pkgs\jetty-${JETTYVERSION}\bin"
Jetty-Service.exe --start jetty-service.conf

exit 0
