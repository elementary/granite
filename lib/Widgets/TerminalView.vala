/**
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

[Version (since = "7.7.0")]
public class Granite.TerminalView : Granite.Bin {

    public bool autoscroll { get; construct set; default=false; }

    private Gtk.TextBuffer buffer;
    private double prev_upper_adj = 0;
    private Gtk.ScrolledWindow scrolled_window;

    public TerminalView () {
        Gtk.TextView view = new Gtk.TextView () {
            cursor_visible = false,
            editable = false,
            monospace = true,
            pixels_below_lines = 3,
            left_margin = 9,
            right_margin = 9,
            top_margin = 6,
            bottom_margin = 6,
            wrap_mode = Gtk.WrapMode.WORD
        };

        buffer = view.get_buffer ();

        scrolled_window = new Gtk.ScrolledWindow () {
            child = view,
            hexpand = true,
            vexpand = true,
            hscrollbar_policy = NEVER,
        };

        this.child = scrolled_window;

        notify["autoscroll"].connect ((s, p) => {
            if (autoscroll) {
                enable_autoscroll ();
            } else {
                disable_autoscroll ();
            }

        });
    }

    construct {
        this.add_css_class (Granite.CssClass.TERMINAL);
    }

    private void enable_autoscroll () {
        // FIXME: this disjoints the window closing and the application finishing
        Idle.add (() => {
            attempt_scroll ();
            return GLib.Source.CONTINUE;
        });
    }

    private void disable_autoscroll () {
        //TODO: implement
    }

    // TODO: does this need to exist?
    public void append_to_buffer (string text) {
        buffer.insert_at_cursor (text, -1);
    }

    public void attempt_scroll () {
        var adj = scrolled_window.vadjustment;
        var units_from_end = prev_upper_adj - adj.page_size - adj.value;

        if (adj.upper - prev_upper_adj <= 0) {
            return;
        }

        if (prev_upper_adj <= adj.page_size || units_from_end <= 50) {
            adj.value = adj.upper;
        }

        prev_upper_adj = adj.upper;
    }
}
