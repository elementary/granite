/*
 * Copyright 2017 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class DialogsView : Gtk.Overlay {
    public Gtk.Window window { get; construct; }

    private Granite.Widgets.Toast toast;

    public DialogsView (Gtk.Window window) {
        Object (window: window);
    }

    construct {
        var dialog_button = new Gtk.Button.with_label ("Show Dialog");

        var message_button = new Gtk.Button.with_label ("Show MessageDialog");

        toast = new Granite.Widgets.Toast ("Did something");

        var grid = new Gtk.Grid () {
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER,
            row_spacing = 12
        };
        grid.attach (dialog_button, 0, 1);
        grid.attach (message_button, 0, 2);

        add (grid);
        add_overlay (toast);

        dialog_button.clicked.connect (show_dialog);
        message_button.clicked.connect (show_message_dialog);
    }

    private void show_dialog () {
        var header = new Granite.HeaderLabel ("Header");
        var entry = new Gtk.Entry ();
        var gtk_switch = new Gtk.Switch () {
            halign = Gtk.Align.START
        };

        var layout = new Gtk.Grid () {
            margin = 12,
            margin_top = 0,
            row_spacing = 12
        };
        layout.attach (header, 0, 1);
        layout.attach (entry, 0, 2);
        layout.attach (gtk_switch, 0, 3);

        var dialog = new Granite.Dialog () {
            transient_for = window
        };
        dialog.get_content_area ().add (layout);
        dialog.add_button ("Cancel", Gtk.ResponseType.CANCEL);

        var suggested_button = dialog.add_button ("Suggested Action", Gtk.ResponseType.ACCEPT);
        suggested_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

        dialog.show_all ();
        dialog.response.connect ((response_id) => {
           if (response_id == Gtk.ResponseType.ACCEPT) {
               toast.send_notification ();
           }

           dialog.destroy ();
        });
    }

    private void show_message_dialog () {
        var message_dialog = new Granite.MessageDialog.with_image_from_icon_name (
            "Basic information and a suggestion",
            "Further details, including information that explains any unobvious consequences of actions.",
            "phone",
            Gtk.ButtonsType.CANCEL
        );
        message_dialog.badge_icon = new ThemedIcon ("dialog-information");
        message_dialog.transient_for = window;

        var suggested_button = new Gtk.Button.with_label ("Suggested Action");
        suggested_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
        message_dialog.add_action_widget (suggested_button, Gtk.ResponseType.ACCEPT);

        var custom_widget = new Gtk.CheckButton.with_label ("Custom widget");

        message_dialog.show_error_details ("The details of a possible error.");
        message_dialog.custom_bin.add (custom_widget);

        message_dialog.show_all ();
        message_dialog.response.connect ((response_id) => {
           if (response_id == Gtk.ResponseType.ACCEPT) {
               toast.send_notification ();
           }

           message_dialog.destroy ();
        });
    }
}
