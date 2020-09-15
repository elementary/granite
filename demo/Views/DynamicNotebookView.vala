/*
 * Copyright (c) 2011–2019 elementary, Inc. (https://elementary.io)
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
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA.
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
        notebook.allow_restoring = true;

        int i;

        for (i = 1; i <= 6; i++) {
            var page = new Gtk.Label ("Page %d".printf (i));
            var tab = new Granite.Widgets.Tab (
                "Tab %d".printf (i),
                new ThemedIcon ("mail-mark-important-symbolic"),
                page
            );
            tab.tooltip = "Customizable tooltip %d".printf (i);
            notebook.insert_tab (tab, i - 1);
        }

        notebook.new_tab_requested.connect (() => {
            var page = new Gtk.Label ("Page %d".printf (i));
            var tab = new Granite.Widgets.Tab (
                "Tab %d".printf (i), new ThemedIcon ("mail-mark-important-symbolic"), page
            );
            tab.tooltip = "Customizable tooltip %d".printf (i);
            notebook.insert_tab (tab, i - 1);
            i++;
        });

        notebook.close_tab_requested.connect ((tab) => {
            tab.restore_data = ((Gtk.Label)(tab.page)).label;
            return true;
        });

        notebook.tab_restored.connect ((label, data, icon) => {
            var page = new Gtk.Label (data);
            var tab = new Granite.Widgets.Tab (label, icon, page);
            notebook.insert_tab (tab, i - 1);
        });

        add (notebook);
    }
}
