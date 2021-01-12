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

public class Granite.Dialog : Gtk.Window {
    public signal void response (int response_id);

    public Gtk.Box content_area { get; private set; }

    private Gtk.ButtonBox action_area;

    class construct {
        set_css_name ("dialog");
    }

    construct {
        content_area = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
            expand = true
        };

        action_area = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL) {
            layout_style = Gtk.ButtonBoxStyle.END,
            spacing = 6
        };
        action_area.get_style_context ().add_class ("dialog-action-box");

        var layout = new Gtk.Grid () {
            margin = 12,
            row_spacing = 24
        };
        layout.attach (content_area, 0, 0);
        layout.attach (action_area, 0, 1);

        var event_box = new Gtk.EventBox ();
        event_box.add (layout);

        deletable = false;
        type_hint = Gdk.WindowTypeHint.DIALOG;
        window_position = Gtk.WindowPosition.CENTER_ON_PARENT;

        add (event_box);

        event_box.button_press_event.connect ((event) => {
        if (event.button == Gdk.BUTTON_PRIMARY) {
            begin_move_drag ((int) event.button, (int) event.x_root, (int) event.y_root, event.time);
                return Gdk.EVENT_STOP;
            }

            return Gdk.EVENT_PROPAGATE;
        });
    }

    /**
    * Adds a button with the given text and sets things up so that clicking the button will emit the response signal with the given response_id.
    */
    public Gtk.Widget add_button (string button_text, int response_id) {
        var button = new Gtk.Button.with_label (button_text);
        button.clicked.connect (() => {
            response (response_id);
        });

        action_area.add (button);

        return button;
    }

    /**
    * Adds an activatable widget to the action area of a Granite.Dialog, connecting a signal handler that will emit the response signal on the dialog when the widget is activated.
    */
    public Gtk.Widget add_action_widget (Gtk.Widget widget, int response_id) {
        widget.button_release_event.connect (() => {
            response (response_id);

            return Gdk.EVENT_STOP;
        });

        action_area.add (widget);

        return widget;
    }

    public int run () {
        modal = true;
        show_all ();

        return 0;
        // response.connect ((response_id) => {
        //     return response_id;
        // });
    }
}
