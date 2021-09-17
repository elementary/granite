/*-
 * Copyright 2021 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

namespace Granite {
    [DBus (name = "io.elementary.pantheon.AccountsService")]
    private interface Pantheon.AccountsService : Object {
        public abstract int prefers_color_scheme { owned get; set; }
    }

    [DBus (name = "org.freedesktop.Accounts")]
    interface FDO.Accounts : Object {
        public abstract string find_user_by_name (string username) throws GLib.Error;
    }
    
    [DBus (name = "org.freedesktop.portal.Settings")]
    private interface FDO.Portal.Settings : Object {
        public abstract Variant read (string @namespace, string key);
        public abstract signal void setting_changed (string @namespace, string key, Variant @value);
    }

    /**
     * Granite.Settings provides a way to share Pantheon desktop settings with applications.
     */
    public class Settings : Object {
    
        private const string GNOME_DESKTOP_INTERFACE = "org.gnome.desktop.interface";
        private const string CLOCK_FORMAT_KEY = "clock-format";
        
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
        
        /**
         * Possible clock format preferences expressed by the user
         */
        public enum ClockFormat {
            /**
             * The user prefers a 12 hour clock
             */
            12H,
            /**
             * The user prefers a 24 hour clock
             */
            24H            
        }
        
        private ClockFormat? _clock_format = null;
        /**
         * Whether the user would prefer a 12 hour or 24 hour clock
         */
        public ClockFormat clock_format {
            get {
                if (_clock_format == null) {
                    setup_clock_format ();
                }
                return _clock_format;
            }
            private set {
                _clock_format = value;
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
        private FDO.Portal.Settings? settings_service = null;

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

        private void setup_prefers_color_scheme () {
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
            } catch (Error e) {
                critical (e.message);
            }
        }
        
        private void setup_clock_format () {
            try {
                settings_service = GLib.Bus.get_proxy_sync (
                    GLib.BusType.SESSION,
                   "org.freedesktop.portal.Desktop",
                   "/org/freedesktop/portal/desktop"
                );
                
                var clock_format_variant = settings_service.read (GNOME_DESKTOP_INTERFACE, CLOCK_FORMAT_KEY).get_variant ();
                var format = clock_format_variant.get_string ();
                
                set_clock_format_from_nick (format);
                
                settings_service.setting_changed.connect((@namespace,key,@value) => {
                    if(@namespace == GNOME_DESKTOP_INTERFACE && key == CLOCK_FORMAT_KEY) {
                        var updated_format = @value.get_string ();
                        set_clock_format_from_nick (updated_format);
                    }
                });
            } catch (Error e) {
                critical (e.message);
            }
        }
        
        private void set_clock_format_from_nick(string format) {
            EnumClass clock_format_enum_class = (EnumClass) typeof (ClockFormat).class_ref ();
            unowned EnumValue? eval = clock_format_enum_class.get_value_by_nick (format);
            
            if(eval == null) {
                _clock_format = null;
            } else {
                clock_format = (ClockFormat) eval.value;
            }
        }
    }
}
