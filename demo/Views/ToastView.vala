/*
 * Copyright 2011-2021 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class ToastView : Gtk.Box {
    construct {
        halign = Gtk.Align.CENTER;

        var overlay = new Gtk.Overlay ();

        var toast = new Granite.Toast (_("Button was pressed!"));
        toast.set_default_action (_("Do Things"));

        var button = new Gtk.Button.with_label (_("Press Me"));

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
            margin_start = 24,
            margin_end = 24,
            margin_top = 24,
            margin_bottom = 24,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER
        };
        box.append (button);

        overlay.add_overlay (box);
        overlay.add_overlay (toast);
        overlay.set_measure_overlay (toast, true);

        button.clicked.connect (() => {
            toast.send_notification ();
        });

        toast.default_action.connect (() => {
            var label = new Gtk.Label (_("Did The Thing"));
            toast.title = _("Already did the thing");
            toast.set_default_action (null);
            box.append (label);
        });

        append (overlay);
    }
}
