/*
* Copyright 2020 elementary, Inc. (https://elementary.io)
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

public class FormView : Gtk.Grid {
    construct {
        Regex? username_regex = null;
        try {
            username_regex = new Regex ("^[a-z]+[a-z0-9]*$");
        } catch (Error e) {
            critical (e.message);
        }

        var username_label = new Granite.HeaderLabel ("Username");

        var username_entry = new Granite.ValidatedEntry.from_regex (username_regex);

        var button = new Gtk.Button.with_label ("Submit");

        margin = 12;
        orientation = Gtk.Orientation.VERTICAL;
        row_spacing = 3;
        halign = Gtk.Align.CENTER;
        valign = Gtk.Align.CENTER;
        vexpand = true;
        add (username_label);
        add (username_entry);
        add (button);
        show_all ();

        username_entry.bind_property ("is-valid", button, "sensitive");
    }
}
