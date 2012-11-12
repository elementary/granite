//  
//  Copyright (C) 2011 Maxwell Barvian
// 
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
// 
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
// 
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
// 

using Gtk;

using Granite.Services;
using Granite.Widgets;

namespace Granite {

    /**
     * Global deprecated object..
     *
     */
    [Deprecated (since = "granite-0.1")]
    public static Granite.Application app;

    /**
     * This is the base class for all Granite-based apps. It has methods to help create a great deal of an app's functionality.
     */
    public abstract class Application : Gtk.Application {

        public string build_data_dir;
        public string build_pkg_data_dir;
        public string build_release_name;
        public string build_version;
        public string build_version_info;

        public string program_name;
        public string exec_name;

        public string app_copyright;
        public string app_years;
        public string app_icon;
        public string app_launcher;

        public string main_url;
        public string bug_url;
        public string help_url;
        public string translate_url;

        public string[] about_authors;
        public string[] about_documenters;
        public string[] about_artists;
        public string about_comments;
        public string about_translators;
        public string about_license;
        public License about_license_type;

        /**
         * This creates a new Application class
         */
        public Application () {


            Granite.init ();
            // set program name
            prctl (15, exec_name, 0, 0, 0);
            Environment.set_prgname (exec_name);

            Logger.initialize (program_name);
            Logger.DisplayLevel = LogLevel.INFO;
            message ("%s version: %s", program_name, build_version);
            var un = Posix.utsname ();
            message ("Kernel version: %s", (string) un.release);
            Logger.DisplayLevel = LogLevel.WARN;

            Intl.bindtextdomain (exec_name, build_data_dir + "/locale");

            // Deprecated
            Granite.app = this;

        }

        [CCode (cheader_filename = "sys/prctl.h", cname = "prctl")]
            protected extern static int prctl (int option, string arg2, ulong arg3, ulong arg4, ulong arg5);

        /**
         * This method runs the application
         * 
         * @param args array of arguments
         */
        public new int run (string[] args) {

            // parse commandline options
            var context = new OptionContext ("");

            context.add_main_entries (options, null);
            context.add_group (Gtk.get_option_group (false));

            try {
                context.parse (ref args);
            } catch { }

            set_options ();

            return base.run (args);
        }

        protected static bool DEBUG = false;

        protected const OptionEntry[] options = {
            { "debug", 'd', 0, OptionArg.NONE, out DEBUG, "Enable debug logging", null },
            { null }
        };

        protected virtual void set_options () {

            if (DEBUG)
                Logger.DisplayLevel = LogLevel.DEBUG;
        }

        /**
         * This methods creates a new App Menu
         * 
         * @param menu the menu to create the App Menu for
         * 
         * @return app_menu
         */
        public AppMenu create_appmenu (Gtk.Menu menu) {

            AppMenu app_menu = new AppMenu.with_app (this, menu);
            app_menu.show_about.connect (show_about);

            return app_menu;
        }

        protected Granite.Widgets.AboutDialog about_dlg;

        /**
         * This method shows the about dialog of this app.
         * 
         * @param parent This widget is the window that is calling the about page being created. 
         */
        public virtual void show_about (Gtk.Widget parent) {

            assert (parent is Gtk.Window);
            
            Granite.Widgets.AboutDialog dialog;

            if (parent != null)
                dialog = parent.get_data ("gtk-about-dialog");
            else
                dialog = about_dlg;

            if (dialog == null) {
                dialog = new Granite.Widgets.AboutDialog ();

                dialog.program_name = program_name;
                dialog.version = build_version;
                dialog.logo_icon_name = app_icon;

                dialog.comments = about_comments;
                dialog.copyright = "%s %s Developers".printf (app_years, program_name);
                dialog.website = main_url;
                dialog.website_label = "Website";

                dialog.authors = about_authors;
                dialog.documenters = about_documenters;
                dialog.artists = about_artists;
                dialog.translator_credits = about_translators;
                dialog.license = about_license;
                dialog.license_type = about_license_type;

                dialog.help = help_url;
                dialog.translate = translate_url;
                dialog.bug = bug_url;

                dialog.delete_event.connect (dialog.hide_on_delete);
                dialog.response.connect (() => { dialog.hide (); });

                if (parent != null) {
                    dialog.set_modal (true);
                    dialog.set_transient_for (parent as Gtk.Window);
                    dialog.set_destroy_with_parent (true);
                    parent.set_data_full ("gtk-about-dialog", dialog, Object.unref);
                } else {
                    about_dlg = dialog;
                }
            }

            dialog.present ();
        }
    }
}

