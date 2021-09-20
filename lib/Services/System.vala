/*
 * Copyright 2011-2013 Robert Dyer
 * SPDX-License-Identifier: LGPL-3.0-or-later
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
        [Version (deprecated = true, deprecated_since = "5.2.4", replacement = "GLib.AppInfo.launch_default_for_uri")]
        public static void open_uri (string uri) {
            try {
                GLib.AppInfo.launch_default_for_uri (uri, null);
            } catch (Error e) {
                critical ("Failed to open uri: %s", e.message);
            }
        }

        /**
         * Opens the specified file with the default application.
         *
         * @param file the {@link GLib.File} to open
         */
        [Version (deprecated = true, deprecated_since = "5.2.4", replacement = "GLib.AppInfo.launch_default_for_uri")]
        public static void open (File file) {
            try {
                GLib.AppInfo.launch_default_for_uri (file.get_uri (), null);
            } catch (Error e) {
                critical ("Failed to open file: %s", e.message);
            }
        }

        /**
         * Opens the specified files with the default application.
         *
         * @param files an array of {@link GLib.File} to open
         */
        [Version (deprecated = true, deprecated_since = "5.2.4", replacement = "GLib.AppInfo.launch_default_for_uri")]
        public static void open_files (File[] files) {
            foreach (unowned GLib.File file in files) {
                try {
                    GLib.AppInfo.launch_default_for_uri (file.get_uri (), null);
                } catch (Error e) {
                    critical ("Failed to open file: %s", e.message);
                }
            }
        }

        /**
         * Launches the specified application.
         *
         * @param app the {@link GLib.File} representing the application to launch
         */
        [Version (deprecated = true, deprecated_since = "5.2.4", replacement = "GLib.AppInfo.launch")]
        public static void launch (File app) {
            launch_with_files (app, new File[] {});
        }

        /**
         * Executes the specified command.
         *
         * @param command the command to execute
         */
        [Version (deprecated = true, deprecated_since = "5.2.4", replacement = "AppInfo.create_from_commandline")]
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
        [Version (deprecated = true, deprecated_since = "5.2.4", replacement = "GLib.AppInfo.launch")]
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

#if !WINDOWS
            if (app != null)
                info = new DesktopAppInfo.from_filename (app.get_path ());
            else
#endif
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

        private static GLib.SettingsSchema? privacy_settings_schema = null;
        private static GLib.Settings? privacy_settings = null;
        private static Portal.Settings? portal = null;

        /**
         * Returns whether history is enabled within the Security and Privacy system settings or not. A value of true
         * means that you should store information such as the last opened file or a history within the app.
         *
         * Checks the "remember_recent_files" key in "org.gnome.desktop.privacy", returning true if the schema does not exist.
         */
        public static bool history_is_enabled () {
            try {
                if (portal == null) {
                    portal = Portal.Settings.get ();
                }

                var schemes = portal.read_all ({ "org.gnome.desktop.privacy" });
                if (schemes.length > 0 && "remember-recent-files" in schemes["org.gnome.desktop.privacy"]) {
                    return schemes["org.gnome.desktop.privacy"]["remember-recent-files"].get_boolean ();
                }
            } catch (Error e) {
                debug ("cannot use portal, using GSettings: %s", e.message);
            }

            if (privacy_settings_schema == null) {
                privacy_settings_schema = SettingsSchemaSource.get_default ().lookup ("org.gnome.desktop.privacy", true);
            }

            if (privacy_settings_schema != null && privacy_settings_schema.has_key ("remember-recent-files")) {
                if (privacy_settings == null) {
                    privacy_settings = new GLib.Settings ("org.gnome.desktop.privacy");
                }

                return privacy_settings.get_boolean ("remember-recent-files");
            }

            return true;
        }
    }
}
