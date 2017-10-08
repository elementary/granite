/*
 *  Copyright (C) 2011-2013 Maxwell Barvian <maxwell@elementaryos.org>
 *
 *  This program or library is free software; you can redistribute it
 *  and/or modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation; either
 *  version 3 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 *  Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General
 *  Public License along with this library; if not, write to the
 *  Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 *  Boston, MA 02110-1301 USA.
 */

namespace Granite {
    /**
     * This is the base class for all Granite-based apps. It has methods that help
     * to create a great deal of an app's functionality.
     */
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
        public Application () {
#if LINUX
            prctl (15, exec_name, 0, 0, 0);
#elif DRAGON_FLY || FREE_BSD || NET_BSD || OPEN_BSD
            setproctitle (exec_name);
#endif
            Granite.Services.Logger.initialize (program_name);
            Granite.Services.Logger.DisplayLevel = Granite.Services.LogLevel.INFO;
            message ("%s version: %s", program_name, build_version);
            var un = Posix.utsname ();
            message ("Kernel version: %s", (string) un.release);
            Granite.Services.Logger.DisplayLevel = Granite.Services.LogLevel.WARN;

            Intl.bindtextdomain (exec_name, build_data_dir + "/locale");

            handle_local_options.connect (on_handle_local_options);
        }

#if LINUX
        [CCode (cheader_filename = "sys/prctl.h", cname = "prctl")]
            protected extern static int prctl (int option, string arg2, ulong arg3, ulong arg4, ulong arg5);
#elif DRAGON_FLY || FREE_BSD
        [CCode (cheader_filename = "unistd.h", cname = "setproctitle")]
            protected extern static void setproctitle (string fmt, ...);
#elif NET_BSD || OPEN_BSD
        [CCode (cheader_filename = "stdlib.h", cname = "setproctitle")]
            protected extern static void setproctitle (string fmt, ...);
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

        protected static bool DEBUG = false;

        protected const OptionEntry[] options = {
            { "debug", 'd', 0, OptionArg.NONE, out DEBUG, "Enable debug logging", null },
            { null }
        };

        protected virtual void set_options () {

            if (DEBUG)
                Granite.Services.Logger.DisplayLevel = Granite.Services.LogLevel.DEBUG;
        }

        /**
         * This methods creates a new App Menu
         *
         * @param menu the menu to create the App Menu for
         *
         * @return app_menu
         */
        [Version (deprecated = true, deprecated_since = "0.4.2", replacement = "Gtk.MenuButton")]
        public Granite.Widgets.AppMenu create_appmenu (Gtk.Menu menu) {

            var app_menu = new Granite.Widgets.AppMenu.with_app (this, menu);
            app_menu.show_about.connect (show_about);

            return app_menu;
        }

        protected Granite.Widgets.AboutDialog about_dlg;

        /**
         * This method shows the about dialog of this app.
         *
         * @param parent This widget is the window that is calling the about page being created.
         */
        [Version (deprecated = true, deprecated_since = "0.4.2", replacement = "")]
        public virtual void show_about (Gtk.Widget parent) {
            assert (parent is Gtk.Window);

            var developers_string = _("%s's Developers").printf (program_name);

            string copyright_string;
            if (parent.get_style_context ().get_direction () == Gtk.TextDirection.RTL) {
                copyright_string = "%s %s".printf (developers_string, app_years);
            } else {
                copyright_string = "%s %s".printf (app_years, developers_string);
            }

            Granite.Widgets.show_about_dialog ((Gtk.Window) parent,
                                               "program_name", program_name,
                                               "version", build_version,
                                               "logo_icon_name", app_icon,

                                               "comments", about_comments,
                                               "copyright", copyright_string,
                                               "website", main_url,
                                               "website_label", _("Website"),

                                               "authors", about_authors,
                                               "documenters", about_documenters,
                                               "artists", about_artists,
                                               "translator_credits", about_translators,
                                               "license", about_license,
                                               "license_type", about_license_type,

                                               "help", help_url,
                                               "translate", translate_url,
                                               "bug", bug_url);
        }
    }
}
