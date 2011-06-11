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

namespace Granite {
	
	public struct utsname {
	
		char sysname [65];
		char nodename [65];
		char release [65];
		char version [65];
		char machine [65];
		char domainname [65];
	}
	
	public abstract class Application : Gtk.Application {
	
		public string build_data_dir;
		public string build_pkg_data_dir;
		public string build_release_name;
		public string build_version;
		public string build_version_info;
		
		public string program_name;
		public string exec_name;
		
		public string app_copyright;
		public string app_icon;
		public string app_launcher;

		public string main_url;
		public string bug_url;
		public string help_url;
		public string translate_url;
		
		public string[] about_authors;
		public string[] about_documenters;
		public string[] about_artists;
		public string about_translators;
		
		public Application () {
		
			// set program name
			prctl (15, exec_name, 0, 0, 0);
			Environment.set_prgname (exec_name);
			
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
		}
		
		[CCode (cheader_filename = "sys/prctl.h", cname = "prctl")]
		protected extern static int prctl (int option, string arg2, ulong arg3, ulong arg4, ulong arg5);
		
		[CCode (cheader_filename = "sys/utsname.h", cname = "uname")]
		protected extern static int uname (utsname buf);
		
		protected AboutDialog about_dlg;
		
		public virtual void show_about () {
		
			if (about_dlg != null) {
				about_dlg.get_window ().raise ();
				return;
			}
			
			about_dlg = new AboutDialog ();
			
			about_dlg.set_program_name (exec_name);
			about_dlg.set_version (build_version + "\n" + build_version_info);
			about_dlg.set_logo_icon_name (app_icon);
			
			about_dlg.set_comments (program_name + ". " + build_release_name);
			about_dlg.set_copyright ("Copyright © %s %s Developers".printf (app_copyright, program_name));
			about_dlg.set_website (main_url);
			about_dlg.set_website_label ("Website");
			
			about_dlg.set_authors (about_authors);
			about_dlg.set_documenters (about_documenters);
			about_dlg.set_artists (about_artists);
			about_dlg.set_translator_credits (about_translators);
			
			about_dlg.response.connect (() => {
				about_dlg.hide ();
			});
			about_dlg.hide.connect (() => {
				about_dlg.destroy ();
				about_dlg = null;
			});
			
			about_dlg.show_all ();
		}
		
	}
	
}

