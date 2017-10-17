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
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

public class SimpleSettingsPage : Granite.SimpleSettingsPage {
    public SimpleSettingsPage () {
        Object (
            activatable: true,
            description: "This is a demo of Granite's SimpleSettingsPage",
            header: "Simple Pages",
            icon_name: "preferences-system",
            title: "First Test Page"
        );
    }

    construct {
        var icon_label = new Gtk.Label ("Icon Name:");
        icon_label.xalign = 1;

        var icon_entry = new Gtk.Entry ();
        icon_entry.hexpand = true;
        icon_entry.placeholder_text = "This page's icon name";
        icon_entry.text = icon_name;

        var title_label = new Gtk.Label ("Title:");
        title_label.xalign = 1;

        var title_entry = new Gtk.Entry ();
        title_entry.hexpand = true;
        title_entry.placeholder_text = "This page's title";

        var description_label = new Gtk.Label ("Description:");
        description_label.xalign = 1;

        var description_entry = new Gtk.Entry ();
        description_entry.hexpand = true;
        description_entry.placeholder_text = "This page's description";

        content_area.attach (icon_label, 0, 0, 1, 1);
        content_area.attach (icon_entry, 1, 0, 1, 1);
        content_area.attach (title_label, 0, 1, 1, 1);
        content_area.attach (title_entry, 1, 1, 1, 1);
        content_area.attach (description_label, 0, 2, 1, 1);
        content_area.attach (description_entry, 1, 2, 1, 1);

        var button = new Gtk.Button.with_label ("Test Button");

        update_status ();

        description_entry.changed.connect (() => {
            description = description_entry.text;
        });

        icon_entry.changed.connect (() => {
            icon_name = icon_entry.text;
        });

        status_switch.notify["active"].connect (update_status);

        title_entry.changed.connect (() => {
            title = title_entry.text;
        });

        action_area.add (button);
    }

    private void update_status () {
        if (status_switch.active) {
            status_type = Granite.SettingsPage.StatusType.SUCCESS;
            status = _("Enabled");
        } else {
            status_type = Granite.SettingsPage.StatusType.OFFLINE;
            status = _("Disabled");
        }
    }
}
