/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class DemoPage : Gtk.Box {
    public string title { get; set; }

    public Gtk.Widget content {
        set {
            scrolled_window.child = value;
        }
    }

    private Gtk.ScrolledWindow scrolled_window;

    construct {
        var header_label = new Granite.HeaderLabel ("") {
            hexpand = true,
            size = H2,
            margin_top = 3,
            margin_bottom = 3
        };

        var header_box = new Granite.Box (HORIZONTAL) {
            margin_top = 6,
            margin_end = 6,
            margin_bottom = 6,
            margin_start = 6
        };
        header_box.append (header_label);
        header_box.append (new Gtk.WindowControls (END) { valign = START });

        var window_handle = new Gtk.WindowHandle () {
            child = header_box
        };

        scrolled_window = new Gtk.ScrolledWindow () {
            hscrollbar_policy = NEVER,
            vexpand = true
        };

        orientation = VERTICAL;
        append (window_handle);
        append (scrolled_window);

        bind_property ("title", header_label, "label");
    }
}
