/*-
 * Copyright 2021 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

namespace Granite {
    [DBus (name = "io.elementary.pantheon.AccountsService")]
    private interface Pantheon.AccountsService : Object {
        public abstract int prefers_color_scheme { get; set; }
    }

    [DBus (name = "org.freedesktop.Accounts")]
    interface FDO.Accounts : Object {
        public abstract string find_user_by_name (string username) throws GLib.Error;
    }

    /**
     * Granite.Settings provides a way to share Pantheon desktop settings with applications.
     */
    public class Settings : Object {
        /**
         * Possible color scheme preferences expressed by the user
         */
        public enum ColorScheme {
            /**
             * The user has not expressed a color scheme preference. Apps should decide on a color scheme on their own.
             */
            NO_PREFERENCE,
            /**
             * The user prefers apps to use a dark color scheme.
             */
            DARK,
            /**
             * The user prefers a light color scheme.
             */
            LIGHT
        }

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

        private ColorScheme? _prefers_color_scheme = null;

        /**
         * Whether the user would prefer if apps use a dark or light color scheme or if the user has expressed no preference.
         *
         * To access this from a Flatpak application, add an entry with the value `'--system-talk-name=org.freedesktop.Accounts'`
         * in the `finish-args` array of your Flatpak manifest.
         */
        public ColorScheme prefers_color_scheme {
            get {
                if (_prefers_color_scheme == null) {
                    setup_prefers_color_scheme ();
                }
                return _prefers_color_scheme;
            }
            private set {
                _prefers_color_scheme = value;
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
        private Pantheon.AccountsService? pantheon_act = null;
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
                accent_color = Gdk.RGBA ();
                accent_color.parse ("#3689e6");
            }
        }

        private Gdk.RGBA parse_color (GLib.Variant color) {
            double red, green, blue;
            color.get ("(ddd)", out red, out green, out blue);

            Gdk.RGBA rgba = {(float) red, (float) green, (float) blue, 1};

            return rgba;
        }

        private void setup_prefers_color_scheme () {
            try {
                if (portal == null) {
                    portal = Portal.Settings.get ();
                }

                prefers_color_scheme = (ColorScheme) portal.read (
                    "org.freedesktop.appearance",
                    "color-scheme"
                ).get_variant ().get_uint32 ();

                portal.setting_changed.connect ((scheme, key, value) => {
                    if (scheme == "org.freedesktop.appearance" && key == "color-scheme") {
                        prefers_color_scheme = (ColorScheme) value.get_uint32 ();
                    }
                });
                return;
            } catch (Error e) {
                debug ("cannot use the portal, using the AccountsService: %s", e.message);
            }

            try {
                pantheon_act = GLib.Bus.get_proxy_sync (
                    GLib.BusType.SYSTEM,
                    "org.freedesktop.Accounts",
                    user_path,
                    GLib.DBusProxyFlags.GET_INVALIDATED_PROPERTIES
                );

                prefers_color_scheme = (ColorScheme) pantheon_act.prefers_color_scheme;

                ((GLib.DBusProxy) pantheon_act).g_properties_changed.connect ((changed, invalid) => {
                    var color_scheme = changed.lookup_value ("PrefersColorScheme", new VariantType ("i"));
                    if (color_scheme != null) {
                        prefers_color_scheme = (ColorScheme) color_scheme.get_int32 ();
                    }
                });
                return;
            } catch (Error e) {
                critical (e.message);
            }

            // Set a default in case we can't get from system
            prefers_color_scheme = ColorScheme.NO_PREFERENCE;
        }
    }
}
