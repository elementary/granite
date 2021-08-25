/*
 * Copyright 2017 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class OverlayBarView : Gtk.Overlay {
    construct {
        var button = new Gtk.ToggleButton.with_label ("Show Spinner");

        /* This is necessary to workaround an issue in the stylesheet with buttons packed directly into overlays */
        var grid = new Gtk.Grid ();
        grid.halign = Gtk.Align.CENTER;
        grid.valign = Gtk.Align.CENTER;
        grid.add (button);

        var overlaybar = new Granite.Widgets.OverlayBar (this);
        overlaybar.label = "Hover the OverlayBar to change its position";

        add (grid);

        button.toggled.connect (() => {
            overlaybar.active = button.active;
        });
    }
}
