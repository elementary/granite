/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class ListsView : DemoPage {
    construct {
        title = "Lists & Grids";

        var card_title = new Granite.HeaderLabel ("Gtk.ListBox") {
            secondary_text = "This ListBox has \"Granite.CssClass.CARD\""
        };

        var separators_modelbutton = new Granite.SwitchModelButton ("Show Separators") {
            active = true,
            description = "\"show-separators = true\""
        };

        var list_box = new Gtk.ListBox () {
            show_separators = true
        };
        list_box.add_css_class (Granite.CssClass.CARD);
        list_box.append (
            new Granite.ListItem () {
                text = "This is a \"Granite.ListItem\"",
                description = "\"Granite.ListItem\" has a standardized row height and padding"
            }
        );
        list_box.append (new Granite.ListItem () { child = separators_modelbutton });

        var list_title = new Granite.HeaderLabel ("Gtk.ListView") {
            secondary_text = "ScrolledWindow with \"has-frame = true\" has a view level background color"
        };

        var list_store = new GLib.ListStore (typeof (ListObject));
        list_store.append (new ListObject () {
            text = "Row 1"
        });
        list_store.append (new ListObject () {
            text = "Row 2"
        });
        list_store.append (new ListObject () {
            text = "Row 3"
        });
        list_store.append (new ListObject () {
            text = "Row 4"
        });
        list_store.append (new ListObject () {
            text = "Row 5"
        });

        var list_selection = new Gtk.SingleSelection (list_store);

        var list_factory = new Gtk.SignalListItemFactory ();
        list_factory.setup.connect ((obj) => {
            var list_item = (Gtk.ListItem) obj;
            list_item.child = new Granite.ListItem ();
        });

        list_factory.bind.connect ((obj) => {
            var list_item = (Gtk.ListItem) obj;
            var list_object = (ListObject) list_item.item;

            var mark_menuitem = new GLib.MenuItem ("Star", null);
            mark_menuitem.set_attribute_value ("icon", "non-starred-symbolic");
            mark_menuitem.set_attribute_value ("css-class", "yellow");

            var replyall_menuitem = new GLib.MenuItem ("Reply All", null);
            replyall_menuitem.set_attribute_value ("icon", "mail-reply-all-symbolic");
            replyall_menuitem.set_attribute_value ("css-class", "purple");

            var trash_menuitem = new GLib.MenuItem ("Trash", null);
            trash_menuitem.set_attribute_value ("icon", "edit-delete-symbolic");
            trash_menuitem.set_attribute_value ("css-class", "destructive");

            var granite_list_item = ((Granite.ListItem) list_item.child);
            granite_list_item.text = list_object.text;
            granite_list_item.prepend_swipe_action (replyall_menuitem);
            granite_list_item.prepend_swipe_action (mark_menuitem);
            granite_list_item.append_swipe_action (trash_menuitem);
        });

        var list_view = new Gtk.ListView (list_selection, list_factory) {
            show_separators = true
        };

        var list_scrolled = new Gtk.ScrolledWindow () {
            child = list_view,
            has_frame = true,
            hscrollbar_policy = NEVER,
            min_content_height = 128
        };

        var grid_title = new Granite.HeaderLabel ("Gtk.GridView");

        var grid_store = new GLib.ListStore (typeof (GridObject));
        grid_store.append (new GridObject () {
            icon_name = "folder-documents",
            text = "Documents"
        });
        grid_store.append (new GridObject () {
            icon_name = "folder-download",
            text = "Downloads"
        });
        grid_store.append (new GridObject () {
            icon_name = "folder-music",
            text = "Music"
        });
        grid_store.append (new GridObject () {
            icon_name = "folder-pictures",
            text = "Pictures"
        });
        grid_store.append (new GridObject () {
            icon_name = "folder-publicshare",
            text = "Public"
        });
        grid_store.append (new GridObject () {
            icon_name = "folder-templates",
            text = "Templates"
        });
        grid_store.append (new GridObject () {
            icon_name = "folder-videos",
            text = "Videos"
        });

        var grid_selection = new Gtk.MultiSelection (grid_store);

        var grid_factory = new Gtk.SignalListItemFactory ();
        grid_factory.setup.connect ((obj) => {
            var list_item = (Gtk.ListItem) obj;
            list_item.child = new GridItem ();
        });

        grid_factory.bind.connect ((obj) => {
            var list_item = (Gtk.ListItem) obj;
            var grid_object = (GridObject) list_item.item;

            var grid_item = ((GridItem) list_item.child);
            grid_item.text = grid_object.text;
            grid_item.icon_name = grid_object.icon_name;
        });

        var grid_view = new Gtk.GridView (grid_selection, grid_factory) {
            max_columns = 4,
            enable_rubberband = true
        };

        var grid_scrolled = new Gtk.ScrolledWindow () {
            child = grid_view,
            has_frame = true,
            hscrollbar_policy = NEVER,
            min_content_height = 128,
            propagate_natural_height = true
        };

        var vbox = new Granite.Box (VERTICAL, HALF) {
            margin_top = 12,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12
        };
        vbox.append (card_title);
        vbox.append (list_box);
        vbox.append (list_title);
        vbox.append (list_scrolled);
        vbox.append (grid_title);
        vbox.append (grid_scrolled);

        child = vbox;

        separators_modelbutton.bind_property ("active", list_box, "show-separators", SYNC_CREATE | DEFAULT);
    }

    private class ListObject : Object {
        public string text { get; set; }
    }

    private class GridObject : Object {
        public string text { get; set; }
        public string icon_name { get; set; }
    }

    private class GridItem : Granite.Box {
        public string text { get; set; }
        public string icon_name { get; set; }

        public GridItem () {
            Object (
                orientation: Gtk.Orientation.VERTICAL
            );
        }

        construct {
            var image = new Gtk.Image.from_icon_name (icon_name) {
                pixel_size = 64
            };

            var label = new Gtk.Label (text);

            child_spacing = HALF;
            append (image);
            append (label);

            bind_property ("text", label, "label");
            bind_property ("icon-name", image, "icon-name");
        }
    }
}
