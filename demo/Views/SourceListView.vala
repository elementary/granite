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

public class SourceListView : Gtk.Paned {
    public SourceListView () {
        Object (orientation: Gtk.Orientation.HORIZONTAL);
    }

    construct {
        var label = new Gtk.Label ("No selected item");
        var source_list = new Granite.Widgets.SourceList ();

        position = 150;
        pack1 (source_list, false, false);
        add2 (label);

        var rand = new GLib.Rand ();

        for (int letter = 'A'; letter <= 'Z'; letter++) {
            var expandable_letter = new Granite.Widgets.SourceList.ExpandableItem ("Item %c".printf (letter));
            source_list.root.add (expandable_letter);

            for (int number = 1; number <= 10; number++) {
                var number_item = new Granite.Widgets.SourceList.Item ("Subitem %d".printf (number));
                var val = rand.next_int ();

                if (val % 7 == 0) {
                    number_item.badge = "1";
                }

                expandable_letter.add (number_item);
            }
        }

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
