/*
 * Copyright 2019 elementary, Inc. (https://elementary.io)
 * Copyright 2011-2013 ammonkey <am.monkeyd@gmail.com>
 * Copyright 2011-2013 Mario Guerriero <mario@elementaryos.org>
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

namespace Granite.Services {
    public static IconFactory? icon_factory = null;

    /**
     * This class provides an easy way to access symbolic icons.
     */
    [Version (deprecated = true, deprecated_since = "5.2.4", replacement = "")]
    public class IconFactory : GLib.Object {

        private Gtk.IconTheme icon_theme;

        public class IconFactory () {
            icon_theme = Gtk.IconTheme.get_default ();
        }

        public static IconFactory get_default () {
            if (icon_factory != null)
                return icon_factory;

            icon_factory = new IconFactory ();
            return icon_factory;
        }

        /**
         * Attempts to load a symbolic icon for the given {@link GLib.Icon}
         * with graceful fallback on the non-symbolic variant if the symbolic one
         * does not exist.
         *
         * Note that the resulting pixbuf may not be exactly the requested size;
         * an icon theme may have icons that differ slightly from their nominal sizes,
         * and in addition GTK+ will avoid scaling icons that it considers sufficiently close
         * to the requested size or for which the source image would have to be scaled up too far
         * (this maintains sharpness).
         *
         * @return a {@link Gdk.Pixbuf} with the rendered icon; this may be a newly created icon
         * or a new reference to an internal icon, so you must not modify the icon.
         * Returns null if the icon was not found in the theme hierarchy.
         */
        [Version (deprecated = true, deprecated_since = "5.2.4", replacement = "")]
        public Gdk.Pixbuf? load_symbolic_icon_from_gicon (Gtk.StyleContext style, GLib.Icon gicon, int size) {
            Gdk.Pixbuf px = null;

            Gtk.IconInfo icon_info = icon_theme.lookup_by_gicon (gicon, size, Gtk.IconLookupFlags.GENERIC_FALLBACK);
            if (icon_info == null)
                return null;

            try {
                px = icon_info.load_symbolic_for_context (style);
            } catch (Error err) {
                stderr.printf ("Unable to load symbolic icon: %s", err.message);
            }

            return px;
        }

        /**
         * Loads a symbolic icon for the given icon name with a better chance
         * for loading a symbolic icon in case of fallback than with {@link Gtk.IconTheme.load_icon}
         *
         * Note that the resulting pixbuf may not be exactly the requested size;
         * an icon theme may have icons that differ slightly from their nominal sizes,
         * and in addition GTK+ will avoid scaling icons that it considers sufficiently close
         * to the requested size or for which the source image would have to be scaled up too far
         * (this maintains sharpness).
         *
         * Due to the way {@link Gtk.IconLookupFlags.GENERIC_FALLBACK} works, Gtk readily
         * falls back to the non-symbolic icon if the exact match for the provided name is not found,
         * and only after that fails tries to look up alternative names of the icon itself.
         * This function uses the same mechanism, but looks up the symbolic icon for the
         * name chosen after all the fallbacks, and returns the symbolic one if it's present.
         * This gives a better chance of getting a symbolic icon in case of fallbacks than
         * when using {@link Gtk.IconTheme.load_icon}
         *
         * @return a {@link Gdk.Pixbuf} with the rendered icon; this may be a newly created icon
         * or a new reference to an internal icon, so you must not modify the icon.
         * Returns null if the icon was not found in the theme hierarchy.
         */
        [Version (deprecated = true, deprecated_since = "5.2.4", replacement = "")]
        public Gdk.Pixbuf? load_symbolic_icon (Gtk.StyleContext style, string iconname, int size) {
            ThemedIcon themed_icon = new ThemedIcon.with_default_fallbacks (iconname);

            return load_symbolic_icon_from_gicon (style, (GLib.Icon) themed_icon, size);
        }

    }
}
