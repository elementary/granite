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

public class MessageDialogView : Gtk.Grid {
    public Gtk.Window window { get; construct; }

    private Granite.Widgets.Toast toast;

    public MessageDialogView (Gtk.Window window) {
        Object (window: window);
    }

    construct {
        var button = new Gtk.Button.with_label ("Show MessageDialog");
        button.halign = Gtk.Align.CENTER;
        button.valign = Gtk.Align.CENTER;
        button.expand = true;

        button.clicked.connect (show_message_dialog);
        
        toast = new Granite.Widgets.Toast ("Did something");

        attach (toast, 0, 0, 1, 1);
        attach (button, 0, 1, 1, 1);
    }

    private void show_message_dialog () {
        var message_dialog = new Granite.MessageDialog.with_image_from_icon_name ("Primary text providing basic information and a suggestion", "Secondary text providing further details. Also includes information that explains any unobvious consequences of actions.", "dialog-warning", Gtk.ButtonsType.CANCEL);
        message_dialog.transient_for = window;
        
        var suggested_button = new Gtk.Button.with_label ("Suggested Action");
        suggested_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
        message_dialog.add_action_widget (suggested_button, Gtk.ResponseType.ACCEPT);

        var custom_widget = new Gtk.CheckButton.with_label ("Custom widget");

        message_dialog.custom_bin.add (custom_widget);
        message_dialog.show_all ();
        if (message_dialog.run () == Gtk.ResponseType.ACCEPT) {
            toast.send_notification ();
        }
        
        message_dialog.destroy ();
    }
}