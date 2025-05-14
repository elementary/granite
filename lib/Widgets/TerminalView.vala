/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

[Version (since = "7.7.0")]
public class Granite.TerminalView : Gtk.ScrolledWindow {

    public TerminalView () {
        this.add_css_class (Granite.CssClass.TERMINAL);
    }
    
    public TerminalView.with_textview (
        Gtk.TextView view = new Gtk.TextView () {
            cursor_visible = true,
            margin_end = 6,
            editable = false,
            margin_start = 6,
            monospace = true,
            pixels_below_lines = 3,
            wrap_mode = Gtk.WrapMode.WORD
        }
    ) {
        this.child = view;
    }
    
    // We may not need this, as we could use an un-editable TextView and
    // simplify the API
    public TerminalView.with_label (Gtk.Label label) {
        this.child = label;
    }
}
