:: install.bat
::
:: $Revision$
::
@ECHO off
setlocal


SET ANT_HOME=pkgs\@pkg.antdepo.expanded.name@\pkgs\@pkg.ant.expanded.name@

IF NOT DEFINED JAVA_HOME (
   ECHO JAVA_HOME not set
   GOTO:EOF
)

IF NOT EXIST "%JAVA_HOME%\bin\java.exe" (
    ECHO JAVA_HOME not set or set incorrectly: %JAVA_HOME%
   GOTO:EOF
)

::echo Classpath is %cp%
SET cp=lib\installer.jar;%ANT_HOME%\lib\ant.jar;%ANT_HOME%\lib\ant-launcher.jar;%ANT_HOME%\lib\regexp-1.5.jar;%ANT_HOME%\lib\ant-apache-regexp.jar;%ANT_HOME%\lib\ant-contrib-1.0b1.jar;%ANT_HOME%\lib\ant-nodeps.jar;%ANT_HOME%\lib\ant-trax.jar

::
:: run Commander
::

call "%JAVA_HOME%\bin\java.exe" ^
	-classpath "%cp%" ^
	-Dant.home="%ANT_HOME%" ^
	com.controltier.install.CTierInstaller %*

GOTO:EOF

:AddCpStr
SET cp=%cp%;%~1
GOTO:EOF
