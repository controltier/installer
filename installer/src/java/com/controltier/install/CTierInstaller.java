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
import org.apache.tools.ant.util.StringUtils;
import org.apache.commons.cli.*;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.FileOutputStream;
import java.util.Properties;
import java.util.Iterator;


/**
 * CTierInstaller is ...
 *
 * @author Greg Schueler <a href="mailto:greg@controltier.com">greg@controltier.com</a>
 * @author Alex Honor <a href="mailto:alex@controltier.com">alex@controltier.com</a>
 * @version $Revision$
 */
public class CTierInstaller {
    boolean debug=false;    
    Properties installerProps;
    Properties configProps;
    Properties overrideProps;
    private String antHome;
    private String buildfile;
    private File defaultPropertiesFile;
    String installTarget;
    public static final String INSTALL_BUILD_FILE_PROP = "installer.buildfile";
    public static final String ANT_HOME_PROP = "ANT_HOME";
    public static final String INSTALLER_PROPS_FILE = "etc/installer.properties";
    public static final String BUILD_TARGET_INSTALL_CLIENT = "install-client";

    protected CommandLine cli;
    /**
     * reference to the command line {@link org.apache.commons.cli.Options} instance.
     */
    protected static final Options options = new Options();

    /**
     * Add the commandline options
     */
    static {
        options.addOption("h", "help", false, "print this message");
        options.addOption("v", "verbose", false, "verbose mode");
        options.addOption("f", "defaults", true, "default.properties file");
        options.addOption("c", "client", false, "install just the client");
        options.addOption("d", "dir", true, "ctier_root installation directory");
        options.addOption("p", "project", true, "default project project name");
        options.addOption(OptionBuilder.withArgName("property=value")
                .hasArgs()
                .withValueSeparator('=')
                .withDescription("property=value pair used during software setup")
                .create("D"));
    }


    private CTierInstaller(){
        installerProps = new Properties();
        configProps=new Properties();
        overrideProps=new Properties();
    }

    /**
     * called from setup shell/bat script. Calls the {@link #run} method.
     * @param args the command line arguments
     */
    public static void main(final String args[]) {
        int exitCode = 1;
        final CTierInstaller install = new CTierInstaller();
        try {
            install.run(args);
            exitCode = 0;
        } catch (Throwable exc) {
            System.err.println("ERROR: " + exc.getMessage());
            exc.printStackTrace(System.err);
        }
        System.exit(exitCode);
    }


    /**
     * Validates the defaultPropertiesFile, generates preference data and then invokes the adminCmd.xml
     *
     * @param args Command line args
     *
     */
    public void run(final String[] args) {
        int exitCode = 1; //pessimistic initial value
        parseArgs(args);
       try {
            go();
            exitCode = 0;
        } catch (Throwable e) {
            if (e.getMessage() == null) {
                e.printStackTrace();
            } else {
                System.err.println("error: " + e.getMessage());
            }
        }
        exit(exitCode);
    }

    private void go() {
       loadProperties();
        // The props specified via -Dkey=val take precedence over values in the
        // defaults.properties file.
        if (overrideProps.size()>0) {
           for (Iterator iter = overrideProps.keySet().iterator(); iter.hasNext();) {
               final String key = (String) iter.next();
               final String val = overrideProps.getProperty(key);
               configProps.setProperty(key, val);
           }
            try {
                configProps.store(new FileOutputStream(defaultPropertiesFile),
                        "Merged command line overrides and default.properties");
            } catch (IOException e) {
                throw new SetupException("failed merging properties", e);
            }
        }

        validateEnvironment();
        final AntProject project = new AntProject(new File(buildfile), defaultPropertiesFile, debug);
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

    private void loadProperties() throws SetupException {
        fileExists(INSTALLER_PROPS_FILE, true);
        fileExists(defaultPropertiesFile.getAbsolutePath(), true);

        //load manifest and installer properties
        final File manifest = new File(INSTALLER_PROPS_FILE);
        try {
            installerProps.load(new FileInputStream(manifest));
            configProps.load(new FileInputStream(defaultPropertiesFile));
        } catch (IOException e){
            throw new SetupException(e);
        }
        // load required properties for the installer
        antHome = installerProps.getProperty(ANT_HOME_PROP);
        buildfile = installerProps.getProperty(INSTALL_BUILD_FILE_PROP);
    }


    /**
     * Checks the basic defaultPropertiesFile assumptions
     */
    private void validateEnvironment() {
        // valid ant defaultPropertiesFile
        if (!checkIfDir(ANT_HOME_PROP, antHome)) {
            throw new SetupException(antHome + " is not a valid Ant home");
        }
        fileExists(buildfile, true);

        //TODO: do we need to verify info from the manifest properties?
    }

    public CommandLine parseArgs(String[] args) {
        final int argErrorCode = 2;

        final CommandLineParser parser = new PosixParser();
        try {
            cli = parser.parse(options, args);
        } catch (ParseException e) {
            help();
            exit(argErrorCode);
        }
        if (cli.hasOption("h")||cli.hasOption("?")) {
            help();
            exit(argErrorCode);
        }

        if (cli.hasOption('f')) {
           defaultPropertiesFile = new File(cli.getOptionValue('f'));
            if (! defaultPropertiesFile.exists()) {
                error("Specified file does not exist: " + defaultPropertiesFile.getAbsolutePath());
                exit(argErrorCode);
            }
        } else {
            defaultPropertiesFile = new File("default.properties");
        }

        if (cli.hasOption('d')) {
            final File ctierRoot = new File(cli.getOptionValue('d'));
            System.setProperty("env.ctier_root", ctierRoot.getAbsolutePath());            
        }
        if (cli.hasOption('p')) {
            final String projectName = cli.getOptionValue('p');
            verbose("Project project name set: '" + projectName+"'");
            overrideProps.put("project.default.name", projectName);
        }

        if (cli.hasOption('c')) {
            installTarget = BUILD_TARGET_INSTALL_CLIENT;            
        }

        if (cli.hasOption('v')) {
            debug=true;
        }

        if (cli.hasOption('D')) {
            if (cli.getOptionValues('D').length % 2 != 0) {
                error("bad property=value pair");
                help();
                exit(argErrorCode);
            }
            for (int i = 0; i < cli.getOptionValues('D').length; i++) {
                final String propname = cli.getOptionValues('D')[i];
                final String value = cli.getOptionValues('D')[++i];
                log("property: " + propname + "=" + value);
                overrideProps.put(propname, value);
            }
        }
        return cli;
    }

    public void exit(int code) {
        System.exit(code);
    }

    public void help() {
       final HelpFormatter formatter = new HelpFormatter();
        formatter.printHelp(80,
                "install [options]",
                "options:",
                options,
                "Examples:\n"
                        + "\tinstall --client -d /install/dir -Dkey=val\n"
                        + "\tinstall -d /ctier -Dserver.jetty.hostname=development\n");
    }

    public void log(String output) {
        System.out.println(output);
    }

    public void error(String output) {
        System.err.println(output);
    }

    public void warn(String output) {
        log(output);
    }

    public void verbose(String output) {
        log(output);
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
         * @param debug    debug flag
         */
        AntProject(final File buildFile, final File propFile, boolean debug) {
            project = new Project();
            project.init();
            project.addBuildListener(new Logger(debug));
            project.setProperty("ant.home", antHome);
            project.setProperty("ant.file", buildFile.getAbsolutePath());
            project.setProperty("basedir", new File("").getAbsolutePath());
            project.setProperty("ctier.installfile", propFile.getAbsolutePath());
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
    public class SetupException extends RuntimeException {
        public SetupException(final String message) {
            super(message);
        }

        public SetupException(Throwable t) {
            super(t);
        }

        public SetupException(final String message, Throwable t) {
            super(message, t);
        }
    }

}
