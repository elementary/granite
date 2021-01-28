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

/**
* Granite.Dialog is a styled {@link Gtk.Window} that uses an empty title area,
* action widgets in the bottom/end position, and can be dragged from anywhere.
* Its API is heavily based on {@link Gtk.Dialog}.
*
* ''Example''<<BR>>
* {{{
*   var header = new Granite.HeaderLabel ("Header");
*   var entry = new Gtk.Entry ();
*   var gtk_switch = new Gtk.Switch () {
*       halign = Gtk.Align.START
*   };
*
*   var layout = new Gtk.Grid () {
*       row_spacing = 12
*   };
*   layout.attach (header, 0, 1);
*   layout.attach (entry, 0, 2);
*   layout.attach (gtk_switch, 0, 3);
*
*   var dialog = new Granite.Dialog () {
*       transient_for = window
*   };
*   dialog.content_area.add (layout);
*   dialog.add_button ("Cancel", Gtk.ResponseType.CANCEL);
*
*   var suggested_button = dialog.add_button ("Suggested Action", Gtk.ResponseType.ACCEPT);
*   suggested_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
*
*   dialog.show_all ();
*   dialog.response.connect ((response_id) => {
*       if (response_id == Gtk.ResponseType.ACCEPT) {
*           // Do Something
*       }
*
*       dialog.destroy ();
*   });
* }}}
*/
public class Granite.Dialog : Gtk.Window {
    /**
    * Emitted when an action widget is clicked, the dialog receives a delete event, or the application programmer calls response
    */
    public signal void response (int response_id);
    public new signal void close ();

    /**
    * The content area {@link Gtk.Box}
    */
    public Gtk.Box content_area { get; private set; }

    private Gtk.ButtonBox action_area;
    private HashTable<int, Gtk.Widget> action_widgets;

    /**
     * Constructs a new {@link Granite.Dialog}.
     */
    public Dialog () {

    }

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

        if (action_widgets != null) {
            foreach (unowned Gtk.Widget widget in action_widgets.get_values ()) {
                action_area.add (widget);
            }
        }

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

    public override bool delete_event (Gdk.EventAny event) {
        response (Gtk.ResponseType.DELETE_EVENT);

        // Allow delete handler to run as normal
        return false;
    }

    public override bool key_press_event (Gdk.EventKey event) {
        if (event.keyval == Gdk.Key.Escape) {
            close ();

            ((Gtk.Window)this).close ();
        }

        return base.key_press_event (event);
    }

    /**
    * Adds a button with the given text and sets things up so that clicking the button will emit the response signal with the given response_id.
    *
    * @param button_text text of a button
    * @param response_id response ID for the button
    */
    public unowned Gtk.Widget add_button (string button_text, int response_id) {
        var button = new Gtk.Button.with_label (button_text) {
            use_underline = true
        };

        add_action_widget (button, response_id);

        unowned var button_ref = button;

        return button_ref;
    }

    /**
    * Adds an activatable widget to the action area of {@link Granite.Dialog}, connecting a signal handler that will emit the {@link Granite.Dialog.response} signal on the dialog when the widget is activated.
    *
    * @param widget an activatable widget
    * @param response_id response ID for the widget
    */
    public Gtk.Widget add_action_widget (Gtk.Widget widget, int response_id) {
        widget.button_release_event.connect (() => {
            response (response_id);

            return Gdk.EVENT_STOP;
        });

        if (action_widgets == null) {
            action_widgets = new HashTable<int, Gtk.Widget> (null, null);
        }
        action_widgets[response_id] = widget;

        // It's possible that this is called before action_area is constructed such as in Granite.MessageDialog
        if (action_area != null) {
            action_area.add (widget);
        }

        return widget;
    }

    /**
    * Gets the widget button that uses the given response ID in the action area of a dialog.
    *
    * @param response_id the response ID used by the widget
    */
    public unowned Gtk.Widget? get_widget_for_response (int response_id) {
        if (action_widgets != null) {
            return action_widgets[response_id];
        }

        return null;
    }

    /**
    * Blocks in a recursive main loop until {@link Granite.Dialog} either emits the {@link Granite.Dialog.response} signal, or is destroyed.
    * If the dialog is destroyed during the call to run, run returns {@link Gtk.ResponseType.NONE}. Otherwise, it returns the response ID from the {@link Granite.Dialog.response} signal emission.
    * Before entering the recursive main loop, run calls {@link Gtk.Widget.show_all} on the dialog for you.
    * After run returns, you are responsible for hiding or destroying the dialog if you wish to do so.
    */
    [Version (deprecated = true, deprecated_since = "6.0.0", replacement = "Granite.Dialog.show_all ()")]
    public int run () {
        modal = true;
        show_all ();

        int return_response = Gtk.ResponseType.NONE;
        var loop = new MainLoop ();

        response.connect ((response_id) => {
            return_response = response_id;
            loop.quit ();
        });

        unmap.connect (() => {
            loop.quit ();
        });

        delete_event.connect (() => {
            loop.quit ();

            // Prevent dialog being deleted, so user can handle it
            return true;
        });

        destroy.connect (() => {
            loop.quit ();
        });

        loop.run ();

        return return_response;
    }
}
