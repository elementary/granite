//  
//  Copyright (C) 2011 Robert Dyer, Rico Tzschichholz
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

namespace Granite.Services {

	// This class follows the XDG Base Directory specification:
	//   http://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html
	public class Paths : GLib.Object {
	
		// User's home folder - $HOME
		public static File home_folder { get; protected set; }
		
		// path passed in to initialize method
		// should be Build.PKGDATADIR
		public static File data_folder { get; protected set; }
		
		
		// $XDG_CONFIG_HOME - defaults to $HOME/.config
		public static File xdg_config_home_folder { get; protected set; }
		
		// $XDG_DATA_HOME - defaults to $HOME/.local/share
		public static File xdg_data_home_folder { get; protected set; }
		
		// $XDG_CACHE_HOME - defaults to $HOME/.cache
		public static File xdg_cache_home_folder { get; protected set; }
		
		// $XDG_DATA_DIRS - defaults to /usr/local/share/:/usr/share/
		public static List<File> xdg_data_dir_folders { get; protected owned set; }
		
		
		// defaults to xdg_config_home_folder/app_name
		public static File user_config_folder { get; protected set; }
		
		// defaults to xdg_data_home_folder/app_name
		public static File user_data_folder { get; protected set; }
		
		// defaults to xdg_cache_home_folder/app_name
		public static File user_cache_folder { get; protected set; }
		
		
		public static void initialize (string app_name, string data_folder_path) {
			
			// get environment-based settings
			home_folder = File.new_for_path (Environment.get_home_dir ());
			data_folder = File.new_for_path (data_folder_path);
			
			// get XDG Base Directory settings
			var xdg_config_home = Environment.get_variable ("XDG_CONFIG_HOME");
			var xdg_data_home   = Environment.get_variable ("XDG_DATA_HOME");
			var xdg_cache_home  = Environment.get_variable ("XDG_CACHE_HOME");
			var xdg_data_dirs   = Environment.get_variable ("XDG_DATA_DIRS");
			
			// determine directories based on XDG with fallbacks
			if (xdg_config_home == null || xdg_config_home.length == 0)
				xdg_config_home_folder = home_folder.get_child (".config");
			else
				xdg_config_home_folder = File.new_for_path (xdg_config_home);
			
			if (xdg_data_home == null || xdg_data_home.length == 0)
				xdg_data_home_folder = home_folder.get_child (".local").get_child ("share");
			else
				xdg_data_home_folder = File.new_for_path (xdg_data_home);
			
			if (xdg_cache_home == null || xdg_cache_home.length == 0)
				xdg_cache_home_folder = home_folder.get_child (".cache");
			else
				xdg_cache_home_folder = File.new_for_path (xdg_cache_home);
			
			var dirs = new List<File> ();
			if (xdg_data_dirs == null || xdg_data_dirs.length == 0) {
				dirs.append (File.new_for_path ("/usr/local/share"));
				dirs.append (File.new_for_path ("/usr/share"));
			} else {
				foreach (var path in xdg_data_dirs.split (":"))
					dirs.append (File.new_for_path (path));
			}
			xdg_data_dir_folders = dirs.copy ();			
			
			// set the XDG Base Directory specified directories to use
			user_config_folder = xdg_config_home_folder.get_child (app_name);
			user_data_folder   = xdg_data_home_folder.get_child (app_name);
			user_cache_folder  = xdg_cache_home_folder.get_child (app_name);
			
			// ensure all writable directories exist
			ensure_directory_exists (user_config_folder);
			ensure_directory_exists (user_data_folder);
			ensure_directory_exists (user_cache_folder);
		}
		
		public static bool ensure_directory_exists (File dir) {
			
			if (!dir.query_exists ())
				try {
					dir.make_directory_with_parents ();
					return true;
				} catch {
					error ("Could not access or create the directory '%s'.", dir.get_path ());
				}
			
			return false;
		}
		
	}
	
}

