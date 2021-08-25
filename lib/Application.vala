/*
 * Copyright 2019–2020 elementary, Inc. (https://elementary.io)
 * Copyright 2011–2013 Maxwell Barvian <maxwell@elementaryos.org>
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

namespace Granite {
    /**
     * This is the base class for all Granite-based apps. It has methods that help
     * to create a great deal of an app's functionality.
     */
    [Version (deprecated = true, deprecated_since = "0.5.0", replacement = "Gtk.Application")]
    public abstract class Application : Gtk.Application {

        public string build_data_dir;
        public string build_pkg_data_dir;
        public string build_release_name;
        public string build_version;
        public string build_version_info;

        /**
         * The user facing name of the application. This name is used
         * throughout the application and should be capitalized correctly.
         */
        public string program_name;

        /**
         * The compiled binary name, which must match the CMake exec name.
         * This is used to launch the application from a launcher or the
         * command line.
         */
        public string exec_name;

        /**
         * Years that the copyright extends to. Usually from the start
         * of the project to the most recent modification to it.
         */
        [Version (deprecated = true, deprecated_since = "0.4.2", replacement = "")]
        public string app_copyright;
        [Version (deprecated = true, deprecated_since = "0.4.2", replacement = "")]
        public string app_years;

        /**
         * Icon to be associated with the application.
         *
         * This is either the name of an icon shipped by the icon theme,
         * or the name of an icon shipped with the app (for custom icons).
         * The name should not include the full path or file extension.
         * WRONG: /usr/share/icons/myicon.png RIGHT: myicon
         */
        [Version (deprecated = true, deprecated_since = "0.4.2", replacement = "")]
        public string app_icon;

        /**
         * The launcher to be associated with this application.
         *
         * This should be the name of a file in /usr/share/applications/.
         * See [[http://standards.freedesktop.org/desktop-entry-spec/latest/]]
         * for more information.
         */
        public string app_launcher;

        /**
         * Main website or homepage for the application.
         *
         * If the application has no homepage, one should be created on
         * launchpad.net.
         */
        [Version (deprecated = true, deprecated_since = "0.4.2", replacement = "")]
        public string main_url;

        /**
         * A link to the software's public bug tracker.
         *
         * If the application does not have a bug tracker, one should be
         * created on launchpad.net.
         */
        [Version (deprecated = true, deprecated_since = "0.4.2", replacement = "")]
        public string bug_url;

        /**
         * Link to question and answer site or support forum for the app.
         *
         * Launchpad offers a QA service if one is needed.
         */
        [Version (deprecated = true, deprecated_since = "0.4.2", replacement = "")]
        public string help_url;

        /**
         * Link to where users can translate the application.
         *
         * Launchad offers a translation service if one is necessary.
         */
        [Version (deprecated = true, deprecated_since = "0.4.2", replacement = "")]
        public string translate_url;

        /**
         * Full names of the application authors for the about dialog.
         */
        [Version (deprecated = true, deprecated_since = "0.4.2", replacement = "")]
        public string[] about_authors = {};

        /**
         * Full names of documenters of the app for the about dialog.
         */
        [Version (deprecated = true, deprecated_since = "0.4.2", replacement = "")]
        public string[] about_documenters = {};

        /**
         * Names of the designers of the application's user interface.
         */
        [Version (deprecated = true, deprecated_since = "0.4.2", replacement = "")]
        public string[] about_artists = {};
        [Version (deprecated = true, deprecated_since = "0.4.2", replacement = "")]
        public string about_comments;

        /**
         * Names of the translators of the application.
         */
        [Version (deprecated = true, deprecated_since = "0.4.2", replacement = "")]
        public string about_translators;

        /**
         * The copyright license that the work is distributed under.
         */
        [Version (deprecated = true, deprecated_since = "0.4.2", replacement = "")]
        public string about_license;
        [Version (deprecated = true, deprecated_since = "0.4.2", replacement = "")]
        public Gtk.License about_license_type;

        /**
         * This creates a new Application class
         */
        protected Application () {
#if LINUX
            prctl (15, exec_name, 0, 0, 0);
#elif DRAGON_FLY || FREE_BSD || NET_BSD || OPEN_BSD
            setproctitle (exec_name);
#endif
            Granite.Services.Logger.initialize (program_name);
            Granite.Services.Logger.DisplayLevel = Granite.Services.LogLevel.INFO;
            message ("%s version: %s", program_name, build_version);
#if !WINDOWS
            var un = Posix.utsname ();
            message ("Kernel version: %s", (string) un.release);
#endif
            Granite.Services.Logger.DisplayLevel = Granite.Services.LogLevel.WARN;

            Intl.bindtextdomain (exec_name, build_data_dir + "/locale");

            handle_local_options.connect (on_handle_local_options);
        }

#if LINUX
        [CCode (cheader_filename = "sys/prctl.h", cname = "prctl")]
        extern static int prctl (int option, string arg2, ulong arg3, ulong arg4, ulong arg5);
#elif DRAGON_FLY || FREE_BSD
        [CCode (cheader_filename = "unistd.h", cname = "setproctitle")]
        extern static void setproctitle (string fmt, ...);
#elif NET_BSD || OPEN_BSD
        [CCode (cheader_filename = "stdlib.h", cname = "setproctitle")]
        extern static void setproctitle (string fmt, ...);
#endif

        /**
         * This method runs the application
         *
         * @param args array of arguments
         */
        public new int run (string[] args) {
            var option_group = new OptionGroup ("granite", "Granite Options", _("Show Granite Options"));
            option_group.add_entries (options);

            add_option_group ((owned)option_group);

            return base.run (args);
        }

        private int on_handle_local_options (VariantDict options) {
            set_options ();
            return -1;
        }

        protected static bool DEBUG = false; // vala-lint=naming-convention

        protected const OptionEntry[] options = { // vala-lint=naming-convention
            { "debug", 'd', 0, OptionArg.NONE, out DEBUG, "Enable debug logging", null },
            { null }
        };

        protected virtual void set_options () {

            if (DEBUG) {
                Granite.Services.Logger.DisplayLevel = Granite.Services.LogLevel.DEBUG;
            }
        }
    }
}
