/*
 * Copyright 2017-2021 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class OverlayBarView : DemoPage {
    construct {
        var button = new Gtk.ToggleButton.with_label ("Show Spinner");

        /* This is necessary to workaround an issue in the stylesheet with buttons packed directly into overlays */
        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6) {
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER
        };

        box.append (button);

        var overlay = new Gtk.Overlay () {
            child = box,
            hexpand = true
        };

        var overlaybar = new Granite.OverlayBar (overlay) {
            label = "Hover the OverlayBar to change its position"
        };

        content = overlay;

        button.toggled.connect (() => {
            overlaybar.active = button.active;
        });
    }
}
