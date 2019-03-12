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
        button_one.tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl><Shift>R"}, "Reply All");

        var button_two = new Gtk.Button.with_label ("Label Buttons");
        button_two.tooltip_markup = Granite.markup_accel_tooltip ({"<Super>R", "<Ctrl><Shift>Up", "<Ctrl>Return"});

        var prefer_dark_label = new Gtk.Label ("Prefer Style:");
        prefer_dark_label.halign = Gtk.Align.END;

        string prefer_dark_string;
        if (Granite.Services.System.prefer_dark == true) {
            prefer_dark_string = "Dark";
        } else {
            prefer_dark_string = "Default";
        }

        var prefer_dark_result = new Gtk.Label (prefer_dark_string);

        halign = valign = Gtk.Align.CENTER;
        column_spacing = 12;
        row_spacing = 12;

        attach (tooltip_markup_label, 0, 0);
        attach (button_one, 1, 0);
        attach (button_two, 2, 0);
        attach (prefer_dark_label, 0, 1);
        attach (prefer_dark_result, 1, 1);
    }
}
