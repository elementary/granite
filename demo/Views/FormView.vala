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

        var validated_header = new Granite.HeaderLabel ("Granite.ValidatedEntry") {
            secondary_text = "Must be at least 8 characters long"
        };

        var validated_entry = new Granite.ValidatedEntry () {
            min_length = 8,
            regex = username_regex
        };

        var button = new Gtk.Button.with_label ("Submit");

        var success_entry = new Gtk.Entry () {
            placeholder_text = "Granite.CssClass.SUCCESS",
            text = "Success"
        };
        success_entry.add_css_class (Granite.CssClass.SUCCESS);

        var warning_entry = new Gtk.Entry () {
            placeholder_text = "Granite.CssClass.WARNING",
            text = "Warning"
        };
        warning_entry.add_css_class (Granite.CssClass.WARNING);

        var error_entry = new Gtk.Entry () {
            placeholder_text = "Granite.CssClass.ERROR",
            text = "Error"
        };
        error_entry.add_css_class (Granite.CssClass.ERROR);

        var password_entry = new Gtk.PasswordEntry () {
            show_peek_icon = true
        };

        var box = new Granite.Box (VERTICAL, HALF) {
            halign = CENTER,
            valign = CENTER,
            margin_start = margin_end = margin_top = margin_bottom = 12
        };
        box.append (validated_header);
        box.append (validated_entry);
        box.append (button);
        box.append (new Granite.HeaderLabel ("Gtk.Entry"));
        box.append (success_entry);
        box.append (warning_entry);
        box.append (error_entry);
        box.append (new Granite.HeaderLabel ("Gtk.PasswordEntry"));
        box.append (password_entry);

        child = box;

        validated_entry.bind_property ("is-valid", button, "sensitive", SYNC_CREATE);
    }
}
