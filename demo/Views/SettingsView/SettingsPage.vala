/*
 * Copyright 2017-2021 elementary, Inc. (https://elementary.io)
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
        var title_label = new Gtk.Label ("Title:") {
            xalign = 1
        };

        var title_entry = new Gtk.Entry () {
            hexpand = true,
            placeholder_text = "This page's title"
        };

        var content_area = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
            margin_start = 12,
            margin_end = 12,
            margin_top = 12,
            margin_bottom = 12,
            valign = Gtk.Align.START
        };

        content_area.append (title_label);
        content_area.append (title_entry);

        child = content_area;

        title_entry.changed.connect (() => {
            title = title_entry.text;
        });
    }
}
