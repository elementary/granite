// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
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

public class SettingsView : Granite.SimpleSettingsPage {
    public SettingsView () {
        Object (
            activatable: true,
            description: "This is a demo of Granite's SimpleSettingsPage",
            icon_name: "preferences-system",
            title: "SimpleSettingsPage"
        );

        var label = new Gtk.Label ("This is the content area where settings would go!");
        label.hexpand = true;
        label.vexpand = true;

        content_area.add (label);

        var button = new Gtk.Button.with_label ("Test Button");

        action_area.add (button);
    }
}
