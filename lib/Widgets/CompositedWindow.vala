/*
 *  Copyright (C) 2011-2013 Maxwell Barvian <maxwell@elementaryos.org>
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

using Gtk;
using Gdk;

namespace Granite.Widgets {

    /**
     * A transparent window without decorations and so on. Useful for any kinds of overlays and similar things
     */
    public class CompositedWindow : Gtk.Window, Gtk.Buildable {

        private const string STYLESHEET =
            ".composited { background-color: rgba (0,0,0,0); }";

        construct {
            // Window properties
            app_paintable = true;
            decorated = false;
            resizable = false;

            set_visual (get_screen ().get_rgba_visual());

            // Set up css provider
            Utils.set_theming (this, STYLESHEET, StyleClass.COMPOSITED,
                               Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        }
    }
}

