/*-
 * Copyright 2021-2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

namespace Granite {
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

        private static GLib.Once<Granite.Settings> instance;
        public static unowned Granite.Settings get_default () {
            return instance.once (() => {
                return new Granite.Settings ();
            });
        }

        private Portal.Settings? portal = null;

        private Settings () {}

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
            } catch (Error e) {
                debug ("cannot use the portal: %s", e.message);
            }

            // Set a default in case we can't get from system
            prefers_color_scheme = ColorScheme.NO_PREFERENCE;
        }
    }
}
