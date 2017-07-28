/*
 *  Copyright (C) 2011-2013 ammonkey <am.monkeyd@gmail.com>,
 *                          Mario Guerriero <mario@elementaryos.org>
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

    public static IconFactory? icon_factory = null;

    /**
     * This class provides an easy way to access symbolic icons.
     */
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
        public Gdk.Pixbuf? load_symbolic_icon (Gtk.StyleContext style, string iconname, int size) {
            ThemedIcon themed_icon = new ThemedIcon.with_default_fallbacks (iconname);
            
            return load_symbolic_icon_from_gicon (style, (GLib.Icon) themed_icon, size);
        }
    
    }
}
