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

public class DynamicNotebookView : Gtk.Grid {
    construct {
        var notebook = new Granite.Widgets.DynamicNotebook ();
        notebook.expand = true;

        int i;

        for (i = 1; i <= 6; i++) {
            var page = new Gtk.Label ("Page %d".printf (i));
            var tab = new Granite.Widgets.Tab ("Tab %d".printf (i), new ThemedIcon ("mail-mark-important-symbolic"), page);
            notebook.insert_tab (tab, i-1);
        }

        notebook.new_tab_requested.connect (() => {
            var page = new Gtk.Label ("Page %d".printf (i));
            var tab = new Granite.Widgets.Tab ("Tab %d".printf (i), new ThemedIcon ("mail-mark-important-symbolic"), page);
            notebook.insert_tab (tab, i-1);
            i++;
        });

        add (notebook);
    }
}
