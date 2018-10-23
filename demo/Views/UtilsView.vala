/*
* Copyright (c) 2018 elementary, Inc. (https://elementary.io)
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

public class UtilsView : Gtk.Grid {
    construct {
        var tooltip_markup_label = new Gtk.Label ("Markup Accel Tooltips:");
        tooltip_markup_label.halign = Gtk.Align.END;

        var button_one = new Gtk.Button.from_icon_name ("mail-reply-all", Gtk.IconSize.LARGE_TOOLBAR);
        button_one.tooltip_markup = Granite.markup_accel_tooltip ("Reply All", {"<Ctrl><Shift>R"});

        var button_two = new Gtk.Button.from_icon_name ("color-fill", Gtk.IconSize.LARGE_TOOLBAR);
        button_two.tooltip_markup = Granite.markup_accel_tooltip ("Spill color bucket", {"<Super>R", "<Ctrl><Shift>Up"});

        halign = valign = Gtk.Align.CENTER;
        column_spacing = 12;
        add (tooltip_markup_label);
        add (button_one);
        add (button_two);
    }
}
