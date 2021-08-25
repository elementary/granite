/*
 * Copyright 2011-2017 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class SourceListView : Gtk.Frame {
    construct {
        var music_item = new Granite.Widgets.SourceList.Item ("Music");
        music_item.badge = "1";
        music_item.icon = new GLib.ThemedIcon ("library-music");

        var library_category = new Granite.Widgets.SourceList.ExpandableItem ("Libraries");
        library_category.expand_all ();
        library_category.add (music_item);

        var my_store_podcast_item = new Granite.Widgets.SourceList.Item ("Podcasts");
        my_store_podcast_item.icon = new GLib.ThemedIcon ("library-podcast");

        var my_store_music_item = new Granite.Widgets.SourceList.Item ("Music");
        my_store_music_item.icon = new GLib.ThemedIcon ("library-music");

        var my_store_item = new Granite.Widgets.SourceList.ExpandableItem ("My Store");
        my_store_item.icon = new GLib.ThemedIcon ("system-software-install");
        my_store_item.add (my_store_music_item);
        my_store_item.add (my_store_podcast_item);

        var store_category = new Granite.Widgets.SourceList.ExpandableItem ("Stores");
        store_category.expand_all ();
        store_category.add (my_store_item);

        var player1_item = new Granite.Widgets.SourceList.Item ("Player 1");
        player1_item.icon = new GLib.ThemedIcon ("multimedia-player");
        player1_item.activatable = new GLib.ThemedIcon ("user-available");
        player1_item.activatable_tooltip = "Connected";

        var player2_item = new Granite.Widgets.SourceList.Item ("Player 2");
        player2_item.badge = "3";
        player2_item.icon = new GLib.ThemedIcon ("phone");

        var device_category = new Granite.Widgets.SourceList.ExpandableItem ("Devices");
        device_category.expand_all ();
        device_category.add (player1_item);
        device_category.add (player2_item);

        var source_list = new Granite.Widgets.SourceList ();
        source_list.root.add (library_category);
        source_list.root.add (store_category);
        source_list.root.add (device_category);

        var label = new Gtk.Label ("No selected item");

        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
        paned.position = 130;
        paned.pack1 (source_list, false, false);
        paned.add2 (label);

        margin = 48;
        add (paned);

        source_list.item_selected.connect ((item) => {
            if (item == null) {
                label.label = "No selected item";
                return;
            }

            if (item.badge != "" && item.badge != null) {
                item.badge = "";
            }

            label.label = "%s - %s".printf (item.parent.name, item.name);
        });
    }
}
