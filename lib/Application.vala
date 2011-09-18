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
	
	public struct utsname {
	
		char sysname [65];
		char nodename [65];
		char release [65];
		char version [65];
		char machine [65];
		char domainname [65];
	}

    /**
     * Global deprecated object..
     *
     * @deprecated
     **/
	public static Granite.Application app;
	
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
		
		public Application () {
		
			// set program name
			prctl (15, exec_name, 0, 0, 0);
			Environment.set_prgname (exec_name);
			
			Posix.signal (Posix.SIGINT, sig_handler);
			Posix.signal (Posix.SIGTERM, sig_handler);
			
			Logger.initialize (program_name);
			Logger.DisplayLevel = LogLevel.INFO;
			message ("%s version: %s", program_name, build_version);
			var un = utsname ();
			uname (un);
			message ("Kernel version: %s", (string) un.release);
			Logger.DisplayLevel = LogLevel.WARN;
			
			Intl.bindtextdomain (exec_name, build_data_dir + "/locale");
			
			if (!Thread.supported ())
				error ("Problem initializing thread support.");
			Gdk.threads_init ();
						
			// Deprecated
			Granite.app = this;
			
		}
		
		[CCode (cheader_filename = "sys/prctl.h", cname = "prctl")]
		protected extern static int prctl (int option, string arg2, ulong arg3, ulong arg4, ulong arg5);
		
		[CCode (cheader_filename = "sys/utsname.h", cname = "uname")]
		protected extern static int uname (utsname buf);
		
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
		
		protected static void sig_handler (int sig) {
			warning ("Caught signal (%d), exiting", sig);
			Granite.app.quit_mainloop ();
		}
		
		protected virtual void set_options () {
			
			if (DEBUG)
				Logger.DisplayLevel = LogLevel.DEBUG;
		}
		
		public AppMenu create_appmenu (Menu menu) {
		
		    AppMenu app_menu = new AppMenu.with_app (this, menu);
		    app_menu.show_about.connect (show_about);
		    
		    return app_menu;
		}
		
		protected Granite.Widgets.AboutDialog about_dlg;
			
		public virtual void show_about (Gtk.Widget parent) {
	
            assert(parent is Gtk.Window);
			about_dlg = new Granite.Widgets.AboutDialog ();
			
			about_dlg.modal = true;
			about_dlg.set_transient_for((Gtk.Window) parent);
                			
			about_dlg.program_name = program_name;
			about_dlg.version = build_version;
			about_dlg.logo_icon_name = app_icon;
			
			about_dlg.comments = about_comments;
			about_dlg.copyright = "%s %s Developers".printf (app_years, program_name);
			about_dlg.website = main_url;
			about_dlg.website_label = "Website";
			
			about_dlg.authors = about_authors;
			about_dlg.documenters = about_documenters;
			about_dlg.artists = about_artists;
			about_dlg.translator_credits = about_translators;
			about_dlg.license  = about_license;
			about_dlg.license_type  = about_license_type;
			
			about_dlg.help = help_url;
			about_dlg.translate = translate_url;
			about_dlg.bug = bug_url;
			
			about_dlg.response.connect (() => {
				about_dlg.hide ();
			});
			about_dlg.hide.connect (() => {
				about_dlg.destroy ();
				about_dlg = null;
			});
			
			about_dlg.show ();
		}
		
	}
	
}

