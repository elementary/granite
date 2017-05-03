// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2011-2017 elementary LLC. (https://elementary.io)
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
 *
 * Authored by: Lucas Baudin <xapantu@gmail.com>
 *              Jaap Broekhuizen <jaapz.b@gmail.com>
 *              Victor Eduardo <victoreduardm@gmal.com>
 *              Tom Beckmann <tom@elementary.io>
 *              Corentin Noël <corentin@elementary.io>
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
