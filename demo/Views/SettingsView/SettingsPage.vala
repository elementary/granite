/*
 * Copyright (c) 2017 elementary LLC. (https://elementary.io)
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
 */

public class SettingsPage : Granite.SettingsPage {
    public SettingsPage () {
        var display_widget = new Gtk.Spinner () {
            height_request = 32
        };
        display_widget.start ();

        Object (
            display_widget: display_widget,
            status: "Spinning",
            header: "Manual Pages",
            title: "Custom Display Widget Page"
        );
    }

    construct {
        var title_label = new Gtk.Label ("Title:");
        title_label.xalign = 1;

        var title_entry = new Gtk.Entry ();
        title_entry.hexpand = true;
        title_entry.placeholder_text = "This page's title";

        var content_area = new Gtk.Grid ();
        content_area.column_spacing = 12;
        content_area.row_spacing = 12;
        content_area.margin = 12;
        content_area.attach (title_label, 0, 1, 1, 1);
        content_area.attach (title_entry, 1, 1, 1, 1);

        add (content_area);

        title_entry.changed.connect (() => {
            title = title_entry.text;
        });
    }
}
