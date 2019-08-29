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
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA.
 */

public class SplitWindowView : Gtk.Grid {
    construct {
        var button = new Gtk.Button.with_label ("Show SplitWindow");
        button.halign = Gtk.Align.CENTER;
        button.valign = Gtk.Align.CENTER;
        button.expand = true;

        button.clicked.connect (show_split_dialog);

        attach (button, 0, 1, 1, 1);
    }

    private void show_split_dialog () {
        var welcome = new Granite.Widgets.Welcome ("Split Window demo", "Show yourself around");
        welcome.append ("text-x-vala", "Read the code", "Read the code of this demo on GitHub");
        welcome.set_size_request (450, 400);

        var provider = new Gtk.CssProvider ();
        try {
            provider.load_from_data ("""
                .normal-bg {
                    background-color: @bg-color;
                }
            """);
        } catch (Error e) {
            assert_not_reached ();
        }

        var welcome_style = welcome.get_style_context ();
        welcome_style.add_class ("normal-bg");
        welcome_style.add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        var locations_category = new Granite.Widgets.SourceList.ExpandableItem ("Locations");
        for (var i=0; i<10; i++) {
            var item = new Granite.Widgets.SourceList.Item (@"Location $i");
            locations_category.add (item);
        }
        locations_category.expanded = true;

        var source_list = new Granite.Widgets.SourceList ();
        source_list.set_size_request (150, -1);

        var root = source_list.root;
        root.add (locations_category);

        var main_window = new Granite.Widgets.SplitWindow ();
        main_window.main_add (welcome);
        main_window.sidebar_add (source_list);
        main_window.has_main_separator = true;

        var hb_main_button = new Gtk.Button.with_label ("Show main separator");
        hb_main_button.margin = 6;
        hb_main_button.margin_end = 0;
        hb_main_button.clicked.connect (() => {
            main_window.has_main_separator = ! main_window.has_main_separator;
        });

        var hb_sidebar_button = new Gtk.Button.with_label ("Show sidebar separator");
        hb_sidebar_button.margin = 6;
        hb_sidebar_button.margin_end = 0;
        hb_sidebar_button.clicked.connect (() => {
            main_window.has_sidebar_separator = ! main_window.has_sidebar_separator;
        });

        var main_hb = main_window.main_headerbar;
        main_hb.pack_start (hb_main_button);
        main_hb.pack_start (hb_sidebar_button);

        var sidebar_hb = main_window.sidebar_headerbar;
        sidebar_hb.title = "Example";

        main_window.set_size_request (600, 400);
        main_window.set_default_size (600, 400);
        main_window.show_all ();

        main_window.show_all ();
    }
}
