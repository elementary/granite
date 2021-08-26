/*
 * Copyright 2011-2013 Mathijs Henquet
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public enum Granite.CollapseMode {
    NONE = 0,
    LEFT = 1,
    TOP = 1,
    FIRST = 1,
    RIGHT = 2,
    BOTTOM = 2,
    LAST = 2
}

namespace Granite.Widgets {

    /**
     * A paned that can be easily collapsed by double-clicking over the pane separator.
     * If it was previously collapsed, it is expanded, and vice-versa.
     */
    [Version (deprecated = true, deprecated_since = "5.5.0", replacement = "Gtk.Paned")]
    public class CollapsiblePaned : Gtk.Paned {
        public CollapseMode collapse_mode { get; set; default = CollapseMode.NONE; }
        //public signal void shrink(); //TODO: Make the default action overwritable
        //public new signal void expand(int saved_state); //TODO same

        private int saved_state = 10;
        private uint last_click_time = 0;

        public CollapsiblePaned (Gtk.Orientation orientation) {
            this.orientation = orientation;
        }

        construct {
            button_press_event.connect (detect_toggle);
        }

        private bool detect_toggle (Gdk.EventButton event) {
            if (collapse_mode == CollapseMode.NONE)
                return false;

            if (event.time < (last_click_time + Gtk.Settings.get_default ().gtk_double_click_time) && event.type != Gdk.EventType.2BUTTON_PRESS)
                return true;

            if (event.type == Gdk.EventType.2BUTTON_PRESS && event.window == get_handle_window ()) {
                accept_position ();

                var current_position = get_position ();

                if (collapse_mode == CollapseMode.LAST)
                    current_position = (max_position - current_position); // change current_position to be relative

                int requested_position;
                if (current_position == 0) {
                    debug ("[CollapsablePaned] expand");

                    requested_position = saved_state;
                } else {
                    saved_state = current_position;
                    debug ("[CollapsablePaned] shrink");

                    requested_position = 0;
                }

                if (collapse_mode == CollapseMode.LAST)
                    requested_position = max_position - requested_position; // change requested_position back to be non-relative

                set_position (requested_position);

                return true;
            }

            last_click_time = event.time;

            return false;
        }
    }
}
