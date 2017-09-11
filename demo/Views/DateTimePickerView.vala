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
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 * Authored by: Lucas Baudin <xapantu@gmail.com>
 *              Jaap Broekhuizen <jaapz.b@gmail.com>
 *              Victor Eduardo <victoreduardm@gmal.com>
 *              Tom Beckmann <tom@elementary.io>
 *              Corentin Noël <corentin@elementary.io>
 */

public class DateTimePickerView : Gtk.Grid {
    construct {
        var date_label = new Gtk.Label ("DatePicker:");
        date_label.halign = Gtk.Align.END;

        var datepicker = new Granite.Widgets.DatePicker ();

        var time_label = new Gtk.Label ("TimePicker:");
        time_label.halign = Gtk.Align.END;

        var timepicker = new Granite.Widgets.TimePicker ();

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

        column_spacing = 12;
        row_spacing = 6;
        halign = Gtk.Align.CENTER;
        valign = Gtk.Align.CENTER;
        attach (date_label, 0, 1, 1, 1);
        attach (datepicker, 1, 1, 1, 1);
        attach (time_label, 0, 2, 1, 1);
        attach (timepicker, 1, 2, 1, 1);
        attach (current_time_label, 0, 3, 1, 1);
        attach (current_time, 1, 3, 1, 1);
        attach (current_date_label, 0, 4, 1, 1);
        attach (current_date, 1, 4, 1, 1);
    }
}
