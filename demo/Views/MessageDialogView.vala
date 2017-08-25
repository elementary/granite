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

    public MessageDialogView (Gtk.Window window) {
        Object (window: window);
    }

    construct {
        halign = Gtk.Align.CENTER;
        valign = Gtk.Align.CENTER;

        var button = new Gtk.Button.with_label ("Show MessageDialog");
        button.clicked.connect (show_message_dialog);

        add (button);
    }

    private void show_message_dialog () {
        var message_dialog = new Granite.MessageDialog.from_icon_name ("This is a primary text", "This is a secondary, multiline, long text. This text usually extends the primary text and prints e.g: the details of an error.", "applications-development", Gtk.ButtonsType.CLOSE);
        message_dialog.transient_for = window;

        var custom_widget = new Gtk.CheckButton.with_label ("Custom widget");
        custom_widget.show ();

        message_dialog.message_grid.attach (custom_widget, 1, 2, 1, 1);
        message_dialog.run ();
        message_dialog.destroy ();
    }
}