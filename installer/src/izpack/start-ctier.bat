set JAVA_HOME=$JDKPath

@REM Check if JAVA_HOME is set to a valid JDK
@REM See http://docs.codehaus.org/display/JETTY/Win32Wrapper

if NOT "$POST_INSTALL_START_SERVICES" == "true" (
   GOTO:EOF
)

CD "$USER_HOME"
CALL CTIER.BAT

CD "${INSTALL_PATH}\pkgs\jetty-${JETTYVERSION}\bin"

ECHO Installing jetty as a windows service ...
Jetty-Service.exe --install jetty-service.conf

ECHO Starting jetty...
Jetty-Service.exe --start jetty-service.conf

EXIT 0
