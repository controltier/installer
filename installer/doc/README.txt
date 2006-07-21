
		   ControlTier @pom.currentVersion@ Server & Client Install 
		   ====================================

    This document describes how to install ControlTier Server and Client
    using the install script.

Dependencies:

* Java 1.4

    This script requires Java 1.4 to be installed.  You must have the
    JAVA_HOME environment variable defined in your environment before
    running either install.sh or install.bat.

* Tomcat 4.1.30

    The server requires that a working copy of Tomcat 4.1.30 is
    installed in your system.


			     Installing Tomcat
		   ====================================

NOTE: If you have a working installation of Tomcat that you wish to use,
please note the values of CATALINA_HOME, and CATALINA_BASE, as well as
the port that Tomcat is configured to listen on, then skip to
"Installing ControlTier" below.

To install tomcat, download it from here:

    <http://apache.downlod.in/tomcat/tomcat-4/v4.1.31/bin/jakarta-tomcat-4.1.31.zip>

Then expand the archive into a directory on your system.  That directory
will be the CATALINA_HOME and CATALINA_BASE mentioned below.

To change the default port, modify the file
$CATALINA_BASE/conf/server.xml.

Configure webdav to allow write-access in the web.xml file:  modify the
file $CATALINA_BASE/webapps/webdav/WEB-INF/web.xml to include an
init-param section for "readonly"="false".


			   Installing ControlTier
		   ====================================


1. Download the latest version of the @pom.id@-@pom.currentVersion@.zip
from <http://...>

2. Expand the installer archive:

    jar xvf @pom.id@-@pom.currentVersion@.zip

    This will create the directory "@pom.id@-@pom.currentVersion@".

3. Change to that directory:

    cd @pom.id@-@pom.currentVersion@

4. Now edit the file "defaults.properties" to specify the installation
values.

   Be sure to specify all of the needed values.  The installer will warn
   you if a value is missing or looks incorrect.

5. Execute the install script

    sh install.sh

The install script will proceed to install and configure the ControlTier
client into the ANTDEPO_BASE and ANTDEPO_HOME, and the ControlTier
Server webapp into the Tomcat webapps directory.

NOTE: if your webdav app configuration is set to "readonly", the
installer will warn you.  You should follow the instructions to allow
write access to webdav before proceeding.

The installer will display the URL to access the ControlTier Workbench.

6. Start tomcat

   sh $CATALINA_BASE/bin/startup.sh

7. Visit the ControlTier Workbench URL shown by the install script.

8. (Optional) The installer adds the "headlines" demo project to your
project archives.  To explore the Headlines demo, please see:
<http://open.controltier.com/Docs/headlines_install.html>.


(c) 2006, ControlTier Software, Inc

<http://open.controltier.com>

$Id$
