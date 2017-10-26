/*
* Copyright (c) 2017 elementary LLC. (https://elementary.io)
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU Lesser General Public License as published by
* the Free Software Foundation, either version 2.1 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU Library General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

private class Granite.SettingsSidebarRow : Gtk.ListBoxRow {
    public SettingsPage.StatusType status_type {
        set {
            switch (value) {
                case SettingsPage.StatusType.ERROR:
                    status_icon.icon_name = "user-busy";
                    break;
                case SettingsPage.StatusType.OFFLINE:
                    status_icon.icon_name = "user-offline";
                    break;
                case SettingsPage.StatusType.SUCCESS:
                    status_icon.icon_name = "user-available";
                    break;
                case SettingsPage.StatusType.WARNING:
                    status_icon.icon_name = "user-away";
                    break;
            }
        }
    }

    public Gtk.Widget display_widget { get; construct; }

    public string? header { get; set; }

    public string icon_name {
        get {
            return _icon_name;
        }
        set {
            _icon_name = value;
            if (display_widget is Gtk.Image) {
                ((Gtk.Image) display_widget).icon_name = value;
                ((Gtk.Image) display_widget).pixel_size = 32;
            }
        } 
    }

    public string status {
        set {
            status_label.label = "<span font_size='small'>%s</span>".printf (value);
            status_label.no_show_all = false;
            status_label.show ();
        }
    }

    public string title {
        get {
            return _title;
        }
        set {
            _title = value;
            title_label.label = value;
        }
    }

    private Gtk.Image status_icon;
    private Gtk.Label status_label;
    private Gtk.Label title_label;
    private string _icon_name;
    private string _title;

    public SettingsSidebarRow (Gtk.Widget display_widget, string title) {
        Object (
            display_widget: display_widget,
            title: title
        );
    }

    public SettingsSidebarRow.from_icon_name (string icon_name, string title) {
        Object (
            display_widget: new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.DND),
            icon_name: icon_name,
            title: title
        );
    }

    construct {
        title_label = new Gtk.Label (title);
        title_label.ellipsize = Pango.EllipsizeMode.END;
        title_label.xalign = 0;
        title_label.get_style_context ().add_class ("h3");

        status_icon = new Gtk.Image ();
        status_icon.halign = Gtk.Align.END;
        status_icon.valign = Gtk.Align.END;

        status_label = new Gtk.Label (null);
        status_label.no_show_all = true;
        status_label.use_markup = true;
        status_label.ellipsize = Pango.EllipsizeMode.END;
        status_label.xalign = 0;

        var overlay = new Gtk.Overlay ();
        overlay.width_request = 38;
        overlay.add (display_widget);
        overlay.add_overlay (status_icon);

        var grid = new Gtk.Grid ();
        grid.margin = 6;
        grid.column_spacing = 6;
        grid.attach (overlay, 0, 0, 1, 2);
        grid.attach (title_label, 1, 0, 1, 1);
        grid.attach (status_label, 1, 1, 1, 1);

        add (grid);
    }
}
