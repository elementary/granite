/*
 * Copyright 2011-2017 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class ToastView : Gtk.Overlay {
    construct {
        var toast = new Granite.Widgets.Toast (_("Button was pressed!"));
        toast.set_default_action (_("Do Things"));

        var button = new Gtk.Button.with_label (_("Press Me"));

        var grid = new Gtk.Grid ();
        grid.orientation = Gtk.Orientation.VERTICAL;
        grid.margin = 24;
        grid.halign = Gtk.Align.CENTER;
        grid.valign = Gtk.Align.CENTER;
        grid.row_spacing = 6;
        grid.add (button);

        add_overlay (grid);
        add_overlay (toast);

        button.clicked.connect (() => {
            toast.send_notification ();
        });

        toast.default_action.connect (() => {
            var label = new Gtk.Label (_("Did The Thing"));
            toast.title = _("Already did the thing");
            toast.set_default_action (null);
            grid.add (label);
            grid.show_all ();
        });
    }
}
