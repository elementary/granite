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
