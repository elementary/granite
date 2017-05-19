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
