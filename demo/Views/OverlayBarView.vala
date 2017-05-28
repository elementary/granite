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
