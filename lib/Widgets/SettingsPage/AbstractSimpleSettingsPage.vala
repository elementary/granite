/*
* Copyright (c) 2017 elementary LLC. (http://launchpad.net/switchboard-plug-security-privacy)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
*/

public abstract class Granite.SimpleSettingsPage : Granite.SettingsPage {
    public Gtk.ButtonBox action_area;
    public Gtk.Grid content_area;
    public Gtk.Switch? status_switch;

    public bool activatable { get; construct; }
    public string description { get; construct; }

    public SimpleSettingsPage () {
        Object (activatable: activatable,
                icon_name: icon_name,
                description: description,
                title: title);
    }

    construct {
        var header_icon = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.DIALOG);

        var header_label = new Gtk.Label (title);
        header_label.get_style_context ().add_class ("h2");

        var header_area = new Gtk.Grid ();
        header_area.column_spacing = 12;
        header_area.add (header_icon);
        header_area.add (header_label);

        if (description != null) {
            var description_icon = new Gtk.Image.from_icon_name ("help-info-symbolic", Gtk.IconSize.MENU);
            description_icon.xalign = 0;
            description_icon.tooltip_text = description;

            header_area.add (description_icon);
        }

        if (activatable) {
            status_switch = new Gtk.Switch ();
            status_switch.hexpand = true;
            status_switch.halign = Gtk.Align.END;
            status_switch.valign = Gtk.Align.CENTER;
            header_area.add (status_switch);
        }

        content_area = new Gtk.Grid ();
        content_area.column_spacing = 12;
        content_area.row_spacing = 12;
        content_area.vexpand = true;

        action_area = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL);
        action_area.set_layout (Gtk.ButtonBoxStyle.END);
        action_area.set_spacing (6);

        var grid = new Gtk.Grid ();
        grid.margin = 12;
        grid.orientation = Gtk.Orientation.VERTICAL;
        grid.row_spacing = 24;
        grid.add (header_area);
        grid.add (content_area);
        grid.add (action_area);

        add (grid);
    }
}
