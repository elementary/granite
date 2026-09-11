/*
 * Copyright 2020-2021 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class FormView : DemoPage {
    private Gtk.Label current_date;
    private Gtk.Label relative_datetime;

    construct {
        Regex? username_regex = null;
        try {
            username_regex = new Regex ("^[a-z]+[a-z0-9]*$");
        } catch (Error e) {
            critical (e.message);
        }

        var validated_entry = new Granite.ValidatedEntry () {
            min_length = 8,
            regex = username_regex
        };

        var validated_header = new Granite.HeaderLabel ("Granite.ValidatedEntry") {
            mnemonic_widget = validated_entry,
            secondary_text = "Must be at least 8 characters long"
        };

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

        var button = new Gtk.Button.with_label ("Submit");

        var datepicker = new Granite.DatePicker ();
        var timepicker = new Granite.TimePicker ();

        current_date = new Gtk.Label ("") {
            xalign = 0
        };

        relative_datetime = new Gtk.Label ("") {
            xalign = 0
        };

        var datetime_grid = new Gtk.Grid () {
            column_spacing = 12,
            row_spacing = 6
        };
        datetime_grid.attach (datepicker, 0, 0);
        datetime_grid.attach (timepicker, 0, 1);
        datetime_grid.attach (current_date, 1, 0);
        datetime_grid.attach (relative_datetime, 1, 1);

        var box = new Granite.Box (VERTICAL) {
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
        box.append (new Granite.HeaderLabel ("Date & Time"));
        box.append (datetime_grid);

        child = box;

        validated_entry.bind_property ("is-valid", button, "sensitive", SYNC_CREATE);

        set_selected_datetime (datepicker.date, timepicker.time);
        datepicker.changed.connect (() => set_selected_datetime (datepicker.date, timepicker.time));
        timepicker.changed.connect (() => set_selected_datetime (datepicker.date, timepicker.time));
    }

    private void set_selected_datetime (DateTime date, GLib.DateTime time) {
        var date_time = date;
        date_time = date_time.add_hours (time.get_hour ());
        date_time = date_time.add_minutes (time.get_minute ());

        var settings = new Settings ("org.gnome.desktop.interface");

        relative_datetime.label = Granite.DateTime.get_relative_datetime (date_time);
        current_date.label = date_time.format (
            Granite.DateTime.get_default_date_format (true, true, true)
        );
    }
}
