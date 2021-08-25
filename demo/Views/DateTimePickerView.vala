/*
 * Copyright 2011-2017 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class DateTimePickerView : Gtk.Grid {
    private Gtk.Label relative_datetime;
    private Granite.Widgets.DatePicker datepicker;
    private Granite.Widgets.TimePicker timepicker;

    construct {
        var pickers_label = new Gtk.Label ("Picker Widgets");
        pickers_label.xalign = 0;
        pickers_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);

        var date_label = new Gtk.Label ("DatePicker:");
        date_label.halign = Gtk.Align.END;

        datepicker = new Granite.Widgets.DatePicker ();

        var time_label = new Gtk.Label ("TimePicker:");
        time_label.halign = Gtk.Align.END;

        timepicker = new Granite.Widgets.TimePicker ();

        var formatting_label = new Gtk.Label ("String Formatting");
        formatting_label.margin_top = 6;
        formatting_label.xalign = 0;
        formatting_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);

        var current_time_label = new Gtk.Label ("Localized time:");
        current_time_label.halign = Gtk.Align.END;

        var now = new DateTime.now_local ();
        var settings = new Settings ("org.gnome.desktop.interface");
        var time_format = Granite.DateTime.get_default_time_format (settings.get_enum ("clock-format") == 1, false);

        var current_time = new Gtk.Label (now.format (time_format));
        current_time.tooltip_text = time_format;
        current_time.xalign = 0;

        var current_date_label = new Gtk.Label ("Localized date:");
        current_date_label.halign = Gtk.Align.END;

        var date_format = Granite.DateTime.get_default_date_format (true, true, true);

        var current_date = new Gtk.Label (now.format (date_format));
        current_date.tooltip_text = date_format;
        current_date.xalign = 0;

        var relative_datetime_label = new Gtk.Label ("Relative datetime:");
        relative_datetime_label.halign = Gtk.Align.END;

        relative_datetime = new Gtk.Label ("");
        relative_datetime.xalign = 0;

        set_selected_datetime ();
        datepicker.changed.connect (() => set_selected_datetime ());
        timepicker.changed.connect (() => set_selected_datetime ());

        column_spacing = 12;
        row_spacing = 6;
        halign = Gtk.Align.CENTER;
        valign = Gtk.Align.CENTER;
        attach (pickers_label, 0, 0, 1, 1);
        attach (date_label, 0, 1, 1, 1);
        attach (datepicker, 1, 1, 1, 1);
        attach (time_label, 0, 2, 1, 1);
        attach (timepicker, 1, 2, 1, 1);
        attach (formatting_label, 0, 3, 1, 1);
        attach (current_time_label, 0, 4, 1, 1);
        attach (current_time, 1, 4, 1, 1);
        attach (current_date_label, 0, 5, 1, 1);
        attach (current_date, 1, 5, 1, 1);
        attach (relative_datetime_label, 0, 6, 1, 1);
        attach (relative_datetime, 1, 6, 1, 1);
    }

    private void set_selected_datetime () {
        var selected_date_time = datepicker.date;
        selected_date_time = selected_date_time.add_hours (timepicker.time.get_hour ());
        selected_date_time = selected_date_time.add_minutes (timepicker.time.get_minute ());

        relative_datetime.label = Granite.DateTime.get_relative_datetime (selected_date_time);
    }
}
