/*
* Copyright 2021 elementary, Inc. (https://elementary.io)
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
*/

public class Granite.Dialog : Hdy.Window {
    public signal void response (int response_id);

    public Gtk.Grid content_area { get; private set; }

    private Gtk.ButtonBox action_area;

    class construct {
        Hdy.init ();
        set_css_name ("dialog");
    }

    construct {
        content_area = new Gtk.Grid () {
            expand = true
        };

        action_area = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL) {
            layout_style = Gtk.ButtonBoxStyle.END
        };
        action_area.get_style_context ().add_class ("dialog-action-box");

        var layout = new Gtk.Grid () {
            margin = 12,
            row_spacing = 24
        };
        layout.attach (content_area, 0, 0);
        layout.attach (action_area, 0, 1);

        var window_handle = new Hdy.WindowHandle ();
        window_handle.add (layout);

        type_hint = Gdk.WindowTypeHint.DIALOG;
        window_position = Gtk.WindowPosition.CENTER_ON_PARENT;
        add (window_handle);
    }

    public Gtk.Widget add_button (string button_text, int response_id) {
        var button = new Gtk.Button.with_label (button_text);
        button.clicked.connect (() => {
            response (response_id);
        });

        action_area.add (button);

        return button;
    }
}
