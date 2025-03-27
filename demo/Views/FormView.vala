/*
 * Copyright 2020-2021 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class FormView : DemoPage {
    construct {
        Regex? username_regex = null;
        try {
            username_regex = new Regex ("^[a-z]+[a-z0-9]*$");
        } catch (Error e) {
            critical (e.message);
        }

        var username_entry = new Granite.ValidatedEntry () {
            min_length = 8,
            regex = username_regex
        };

        var username_label = new Granite.HeaderLabel ("Username") {
            mnemonic_widget = username_entry,
            secondary_text = "Must be at least 8 characters long"
        };

        var button = new Gtk.Button.with_label ("Submit");

        var box = new Granite.Box (VERTICAL) {
            halign = CENTER,
            valign = CENTER,
            margin_start = margin_end = margin_top = margin_bottom = 12
        };
        box.append (username_label);
        box.append (username_entry);
        box.append (button);

        content = box;

        username_entry.bind_property ("is-valid", button, "sensitive", SYNC_CREATE);
    }
}
