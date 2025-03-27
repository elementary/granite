/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class DemoPage : Gtk.Box {
    public Gtk.Widget content {
        set {
            scrolled_window.child = value;
        }
    }

    private Gtk.ScrolledWindow scrolled_window;

    construct {
        var header = new Gtk.HeaderBar () {
            show_title_buttons = false,
        };
        header.add_css_class (Granite.STYLE_CLASS_FLAT);
        header.pack_end (new Gtk.WindowControls (END) { valign = START });

        scrolled_window = new Gtk.ScrolledWindow () {
            hscrollbar_policy = NEVER,
            vexpand = true
        };

        orientation = VERTICAL;
        append (header);
        append (scrolled_window);
    }
}
