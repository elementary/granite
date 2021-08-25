/*
 * Copyright 2011–2019 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
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
