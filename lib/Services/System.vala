/*
 *  Copyright (C) 2011-2013 Robert Dyer
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

namespace Granite.Services {

    /**
     * Utility class for frequently-used system-related functions, such as opening files, launching
     * applications, or executing terminal commands.
     */
    public class System : GLib.Object {
    
        /**
         * Opens the specified URI with the default application.  This can be used for opening websites
         * with the default browser, etc.
         *
         * @param uri the URI to open
         */
        public static void open_uri (string uri) {
            open (File.new_for_uri (uri));
        }
        
        /**
         * Opens the specified file with the default application.
         *
         * @param file the {@link GLib.File} to open
         */
        public static void open (File file) {
            launch_with_files (null, { file });
        }
        
        /**
         * Opens the specified files with the default application.
         *
         * @param files an array of {@link GLib.File} to open
         */
        public static void open_files (File[] files) {
            launch_with_files (null, files);
        }
        
        /**
         * Launches the specified application.
         *
         * @param app the {@link GLib.File} representing the application to launch
         */
        public static void launch (File app) {
            launch_with_files (app, new File[] {});
        }
        
        /**
         * Executes the specified command.
         *
         * @param command the command to execute
         */
        public static bool execute_command (string command) {
        
            try {
                var info = AppInfo.create_from_commandline (command, "", 0);
                if (info.launch (null, null))
                    return true;
            } catch (GLib.Error e) {
                warning ("Failed to execute external '%s' command", command);
            }
            
            return true;
        }
        
        /**
         * Launches the supplied files with the specified application.
         *
         * @param app the {@link GLib.File} representing the application to launch
         * @param files an array of {@link GLib.File} to open
         */
        public static void launch_with_files (File? app, File[] files) {
        
            if (app != null && !app.query_exists ()) {
                warning ("Application '%s' doesn't exist", app.get_path ());
                return;
            }
            
            var mounted_files = new GLib.List<File> ();
            
            // make sure all files are mounted
            foreach (var f in files) {
                if (f.get_path () != null && f.get_path () != "" && (f.is_native () || path_is_mounted (f.get_path ()))) {
                    mounted_files.append (f);
                    continue;
                }
                
                try {
                    AppInfo.launch_default_for_uri (f.get_uri (), null);
                } catch {
                    f.mount_enclosing_volume.begin (0, null);
                    mounted_files.append (f);
                }
            }
            
            if (mounted_files.length () > 0 || files.length == 0)
                internal_launch (app, mounted_files);
        }
        
        static bool path_is_mounted (string path) {
        
            foreach (var m in VolumeMonitor.get ().get_mounts ())
                if (m.get_root () != null && m.get_root ().get_path () != null && path.contains (m.get_root ().get_path ()))
                    return true;
            
            return false;
        }
        
        static void internal_launch (File? app, GLib.List<File> files) {
        
            if (app == null && files.length () == 0)
                return;
            
            AppInfo info;
            if (app != null)
                info = new DesktopAppInfo.from_filename (app.get_path ());
            else
                try {
                    info = files.first ().data.query_default_handler ();
                } catch {
                    return;
                }
            
            try {
                if (files.length () == 0) {
                    info.launch (null, null);
                    return;
                }
                
                if (info.supports_files ()) {
                    info.launch (files, null);
                    return;
                }
                
                if (info.supports_uris ()) {
                    var uris = new GLib.List<string> ();
                    foreach (var f in files)
                        uris.append (f.get_uri ());
                    info.launch_uris (uris, new AppLaunchContext ());
                    return;
                }
                
                error ("Error opening files. The application doesn't support files/URIs or wasn't found.");
            } catch (Error e) {
                debug ("Error: " + e.domain.to_string ());
                error (e.message);
            }
        }
        
    }
    
}

