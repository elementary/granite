/*-
 * Copyright 2021 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

namespace Granite {
    [DBus (name = "org.freedesktop.Accounts")]
    interface FDO.Accounts : Object {
        public abstract string find_user_by_name (string username) throws GLib.Error;
    }

    /**
     * Granite.Settings provides a way to share Pantheon desktop settings with applications.
     */
    public class Settings : Object {
        private Gdk.RGBA? _accent_color = null;

        /**
         * The theme accent color chosen by the user
         * @since 7.7.0
         */
        [Version (since = "7.7.0")]
        public Gdk.RGBA accent_color {
            get {
                if (_accent_color == null) {
                    setup_accent_color ();
                }
                return (_accent_color);
            }
            private set {
                _accent_color = value;
            }
        }

        private string? _user_path = null;
        private string user_path {
            get {
                if (_user_path == null) {
                    setup_user_path ();
                }
                return _user_path;
            }
            private set {
                _user_path = value;
            }
        }

        private static GLib.Once<Granite.Settings> instance;
        public static unowned Granite.Settings get_default () {
            return instance.once (() => {
                return new Granite.Settings ();
            });
        }

        private FDO.Accounts? accounts_service = null;
        private Portal.Settings? portal = null;

        private Settings () {}

        private void setup_user_path () {
            try {
                accounts_service = GLib.Bus.get_proxy_sync (
                    GLib.BusType.SYSTEM,
                   "org.freedesktop.Accounts",
                   "/org/freedesktop/Accounts"
                );

                _user_path = accounts_service.find_user_by_name (GLib.Environment.get_user_name ());
            } catch (Error e) {
                critical (e.message);
            }
        }

        private void setup_accent_color () {
            try {
                if (portal == null) {
                    portal = Portal.Settings.get ();
                }

                var variant = portal.read (
                    "org.freedesktop.appearance",
                    "accent-color"
                ).get_variant ();

                accent_color = parse_color (variant);

                portal.setting_changed.connect ((scheme, key, value) => {
                    if (scheme == "org.freedesktop.appearance" && key == "accent-color") {
                        accent_color = parse_color (value);
                    }
                });
            } catch (Error e) {
                warning (e.message);

                // Set a default in case we can't get from system
                _accent_color = Gdk.RGBA ();
                _accent_color.parse ("#3689e6");
            }
        }

        private Gdk.RGBA parse_color (GLib.Variant color) {
            double red, green, blue;
            color.get ("(ddd)", out red, out green, out blue);

            Gdk.RGBA rgba = {(float) red, (float) green, (float) blue, 1};

            return rgba;
        }
    }
}
