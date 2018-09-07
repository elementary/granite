// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2011-2017 elementary LLC. (https://elementary.io)
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA.
 *
 * Authored by: Lucas Baudin <xapantu@gmail.com>
 *              Jaap Broekhuizen <jaapz.b@gmail.com>
 *              Victor Eduardo <victoreduardm@gmal.com>
 *              Tom Beckmann <tom@elementary.io>
 *              Corentin Noël <corentin@elementary.io>
 */

public class DateTimePickerView : Gtk.Grid {
    private Gtk.Label relative_datetime;
    private Gtk.Label current_time;
    private Granite.Widgets.DatePicker datepicker;
    private Granite.Widgets.TimePicker timepicker;
    private Granite.Widgets.TimePicker timepicker_with_format;
    private string time_format;
    private string date_format;

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

        var time_label_with_format = new Gtk.Label ("TimePicker (with_format):");
        time_label_with_format.halign = Gtk.Align.END;

        timepicker_with_format = new Granite.Widgets.TimePicker.with_format ("%l:%M %p", "%H:%M");
        timepicker_with_format.tooltip_text = "TimePicker Example using %l:%M %p and  %H:%M";

        var formatting_label = new Gtk.Label ("String Formatting");
        formatting_label.margin_top = 6;
        formatting_label.xalign = 0;
        formatting_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);

        var current_time_label = new Gtk.Label ("Localized time:");
        current_time_label.halign = Gtk.Align.END;

        var now = new DateTime.now_local ();
        var settings = new Settings ("org.gnome.desktop.interface");
        time_format = Granite.DateTime.get_default_time_format (settings.get_enum ("clock-format") == 1, false);

        current_time = new Gtk.Label (now.format (time_format));
        current_time.tooltip_text = time_format;
        current_time.xalign = 0;

        var current_date_label = new Gtk.Label ("Localized date:");
        current_date_label.halign = Gtk.Align.END;

        date_format = Granite.DateTime.get_default_date_format (true, true, true);

        var current_date = new Gtk.Label (now.format (date_format));
        current_date.tooltip_text = date_format;
        current_date.xalign = 0;

        var relative_datetime_label = new Gtk.Label ("Relative datetime:");
        relative_datetime_label.halign = Gtk.Align.END;

        relative_datetime = new Gtk.Label ("");
        relative_datetime.xalign = 0;

        set_selected_datetime (timepicker.time);
        datepicker.changed.connect (() => set_selected_datetime (timepicker.time));
        timepicker.changed.connect (() => set_selected_datetime (timepicker.time));
        timepicker_with_format.changed.connect (() => set_selected_datetime (timepicker_with_format.time));

        column_spacing = 12;
        row_spacing = 6;
        halign = Gtk.Align.CENTER;
        valign = Gtk.Align.CENTER;
        attach (pickers_label, 0, 0, 1, 1);
        attach (date_label, 0, 1, 1, 1);
        attach (datepicker, 1, 1, 1, 1);
        attach (time_label, 0, 2, 1, 1);
        attach (timepicker, 1, 2, 1, 1);
        attach (time_label_with_format, 0, 3, 1, 1);
        attach (timepicker_with_format, 1, 3, 1, 1);
        attach (formatting_label, 0, 4, 1, 1);
        attach (current_time_label, 0, 5, 1, 1);
        attach (current_time, 1, 5, 1, 1);
        attach (current_date_label, 0, 6, 1, 1);
        attach (current_date, 1, 6, 1, 1);
        attach (relative_datetime_label, 0, 7, 1, 1);
        attach (relative_datetime, 1, 7, 1, 1);
    }

    private void set_selected_datetime (DateTime timepicker_time) {
        current_time.label = timepicker_time.format (time_format);
        var selected_date_time = datepicker.date;
        selected_date_time = selected_date_time.add_hours (timepicker_time.get_hour ());
        selected_date_time = selected_date_time.add_minutes (timepicker_time.get_minute ());

        relative_datetime.label = Granite.DateTime.get_relative_datetime (selected_date_time);
    }
}
