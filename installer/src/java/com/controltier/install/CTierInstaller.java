/*
 * CTierInstaller.java
 * 
 * User: greg
 * Created: Jul 17, 2006 12:00:55 PM
 * $Id$
 */
package com.controltier.install;


import org.apache.tools.ant.BuildEvent;
import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.DefaultLogger;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.ProjectHelper;
import org.apache.tools.ant.taskdefs.Property;
import org.apache.tools.ant.util.StringUtils;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.Properties;


/**
 * CTierInstaller is ...
 *
 * @author Greg Schueler <a href="mailto:greg@controltier.com">greg@controltier.com</a>
 * @version $Revision$
 */
public class CTierInstaller {
    Properties installerProps;
    Properties configProps;
    private String antHome;
    private String buildfile;
    private File install;
    private File manifest;
    String installTarget;
    public static final String INSTALL_BUILD_FILE_PROP = "installer.buildfile";
    public static final String ANT_HOME_PROP = "ANT_HOME";
    public static final String INSTALLER_PROPS_FILE = "etc/installer.properties";
    public static final String BUILD_TARGET_INSTALL_CLIENT = "install-client";
    public static final String BUILD_TARGET_INSTALL_SERVER = "install-server";

    private CTierInstaller(){
        installerProps = new Properties();
        configProps=new Properties();
    }

    /**
     * called from setup shell/bat script. Calls the {@link #execute} method.
     */
    public static void main(final String args[]) {
        int exitCode = 1;
        final CTierInstaller install = new CTierInstaller();
        try {
            install.execute(args);
            exitCode = 0;
        } catch (Throwable exc) {
            System.err.println("ERROR: " + exc.getMessage());
            exc.printStackTrace(System.err);
        }
        System.exit(exitCode);
    }

    /**
     * Validates the install, generates preference data and then invokes the adminCmd.xml
     *
     * @param args Command line args
     *
     * @throws SetupException thrown if error
     */
    public void execute(final String[] args) throws SetupException, IOException {
        loadProperties();
        validateEnvironment();
        boolean debug=false;
        if(args.length>0){
            for (int i = 0; i < args.length; i++) {
                String arg = args[i];
                if("-v".equals(arg)){
                    debug=true;
                }else if("-target".equals(arg)){
                    i++;
                    installTarget = args[i];
                } else if ("-client".equals(arg)) {
                    installTarget = BUILD_TARGET_INSTALL_CLIENT;
                } else if ("-server".equals(arg)) {
                    installTarget = BUILD_TARGET_INSTALL_SERVER;
                }else if(arg.startsWith("-D")){

                }
            }
        }
        final AntProject project = new AntProject(new File(buildfile), install, debug);
        // Fire the build
        project.execute();
    }
    private static boolean fileExists(String name, boolean assertexists){
        File file = new File(name);
        if (!file.exists() && assertexists) {
            throw new RuntimeException("Missing file: " + name);
        }
        return file.exists();
    }

    // check if path exists as a directory
    private boolean checkIfDir(final String propName, final String path) {
        if (null == path || path.equals("")) {
            throw new IllegalArgumentException(propName + "property had null or empty value");
        }
        return new File(path).exists();
    }

    private void loadProperties() throws IOException {
        fileExists(INSTALLER_PROPS_FILE, true);
        fileExists("default.properties", true);

        //load manifest and installer properties
         manifest = new File(INSTALLER_PROPS_FILE);
         install = new File("default.properties");
        installerProps.load(new FileInputStream(manifest));
        configProps.load(new FileInputStream(install));

        // load required properties for the installer
        antHome = installerProps.getProperty(ANT_HOME_PROP);
        buildfile = installerProps.getProperty(INSTALL_BUILD_FILE_PROP);



    }


    /**
     * Checks the basic install assumptions
     */
    private void validateEnvironment() throws SetupException {
        // valid ant install
        if (!checkIfDir(ANT_HOME_PROP, antHome)) {
            throw new SetupException(antHome + " is not a valid Ant install");
        }
        fileExists(buildfile, true);

        //TODO: do we need to verify info from the manifest properties?
    }

    /**
     * Wrapper around Ant's {@link Project} class. Used to invoke the adminCmd.xml build file using supplied preference
     * data.
     */
    protected class AntProject {
        final Project project;

        /**
         * Base constructor.
         *
         * @param buildFile File referenceing the adminCmd.xml buld file
         * @param propFile  Preference properties file
         * @param params    Command line parms
         */
        AntProject(final File buildFile, final File propFile, boolean debug) {
            project = new Project();
            project.init();
            project.addBuildListener(new Logger(debug));
            project.setProperty("ant.home", antHome);
            project.setProperty("ant.file", buildFile.getAbsolutePath());
            project.setProperty("basedir", new File("").getAbsolutePath());
            final Property ptask = new Property();
            ptask.setProject(project);
            ptask.setFile(propFile);
            ptask.maybeConfigure();
            ptask.perform();
            ProjectHelper.configureProject(project, buildFile);
        }

        /**
         * Execute the project
         */
        void execute() {
            project.fireBuildStarted();
            BuildException be = null;
            try {
                project.executeTarget(null == installTarget ? "execute" : installTarget);
            } catch (BuildException e) {
                be = e;
            } finally {
                project.fireBuildFinished(be);
            }
        }
    }

    /**
     * Buildlistener impl that prints out command finished/successful
     */
    public class Logger extends DefaultLogger {
        /**
         * base constructor
         *
         * @param verbose flag indicating if message output level should be verbose or info level
         */
        private Logger(final boolean verbose) {
            setOutputPrintStream(System.out);
            setErrorPrintStream(System.err);
            if (verbose) {
                setMessageOutputLevel(Project.MSG_VERBOSE);
            } else {
                setMessageOutputLevel(Project.MSG_INFO);
            }
        }

        /**
         * Overrides DefaultLogger
         *
         * @param event a <code>BuildEvent</code> value
         */
        public void buildFinished(final BuildEvent event) {
            final Throwable error = event.getException();
            final StringBuffer message = new StringBuffer();

            if (error == null) {
                message.append(StringUtils.LINE_SEP);
                message.append("Setup build successful.");
            } else {
                message.append(StringUtils.LINE_SEP);
                message.append("Setup failed.");
                message.append(StringUtils.LINE_SEP);

                if (Project.MSG_VERBOSE <= msgOutputLevel
                    || !(error instanceof BuildException)) {
                    message.append(StringUtils.getStackTrace(error));
                } else {
                    if (error instanceof BuildException) {
                        message.append(error.toString()).append(lSep);
                    } else {
                        message.append(error.getMessage()).append(lSep);
                    }
                }
            }
            final String msg = message.toString();
            if (!msg.equals("")) {
                if (error == null) {
                    printMessage(msg, out, Project.MSG_VERBOSE);
                } else {
                    printMessage(msg, err, Project.MSG_ERR);
                }
                log(msg);
            }
        }
    }


    /**
     * Exception class
     */
    public class SetupException extends Exception {
        public SetupException(final String message) {
            super(message);
        }
    }

}
