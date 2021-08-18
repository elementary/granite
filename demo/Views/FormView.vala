/*
 * Copyright 2020 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class FormView : Gtk.Grid {
    construct {
        Regex? username_regex = null;
        try {
            username_regex = new Regex ("^[a-z]+[a-z0-9]*$");
        } catch (Error e) {
            critical (e.message);
        }

        var username_label = new Granite.HeaderLabel ("Username");

        var username_entry = new Granite.ValidatedEntry.from_regex (username_regex);

        var button = new Gtk.Button.with_label ("Submit");

        margin = 12;
        orientation = Gtk.Orientation.VERTICAL;
        row_spacing = 3;
        halign = Gtk.Align.CENTER;
        valign = Gtk.Align.CENTER;
        vexpand = true;
        add (username_label);
        add (username_entry);
        add (button);
        show_all ();

        username_entry.bind_property ("is-valid", button, "sensitive");
    }
}
