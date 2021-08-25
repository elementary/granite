/*
 * Copyright 2017 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
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
