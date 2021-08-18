/*
 * Copyright 2019 elementary, Inc. (https://elementary.io)
 * Copyright 2011-2013 Maxwell Barvian <maxwell@elementaryos.org>
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

using Gtk;
using Gdk;

namespace Granite.Widgets {

    /**
     * CompositedWindow is an invisible window without decorations or background.
     *
     * It is useful for handling different situations where the user has to
     * "pick" something or select an area on the screen, although it can be used in other scenarios too.
     * Most of the times the window will act as a surface to receive mouse / key press events from the user.
     *
     * CompositedWindow does not and will not try to set any default size. You are responsible to
     * set it's size to e.g: the window's //screen// size to have the window cover the enire //screen// area.
     *
     * Note that you should provide a way for the user to exit the window since it's invisible.
     * You can do that by connecting to {@link Gtk.Widget.key_press_event} signal and seeing if
     * e.g: the user pressed an Escape key. You should always {@link Gtk.Widget.destroy} the window after
     * it's not needed.
     *
     * Do not forget to call {@link Gtk.Widget.show_all} to actually start receiving events.
     */
    [Version (deprecated = true, deprecated_since = "5.5.0", replacement = "Gtk.Window")]
    public class CompositedWindow : Gtk.Window, Gtk.Buildable {

        private const string STYLESHEET = ".composited { background-color: rgba (0,0,0,0); }";

        construct {
            // Window properties
            app_paintable = true;
            decorated = false;
            resizable = false;

            set_visual (get_screen ().get_rgba_visual ());

            // Set up css provider
            Utils.set_theming (
                this,
                STYLESHEET,
                StyleClass.COMPOSITED,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            );
        }
    }
}
