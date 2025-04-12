/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class ListsView : DemoPage {
    construct {
        title = "Lists";

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

        var scrolled_title = new Granite.HeaderLabel ("Gtk.ListView") {
            secondary_text = "ScrolledWindow with \"has-frame = true\" has a view level background color"
        };

        var reply_menuitem = new GLib.MenuItem ("Reply", null);
        reply_menuitem.set_attribute_value ("verb-icon", "mail-reply-sender-symbolic");

        var reply_all_menuitem = new GLib.MenuItem ("Reply All", null);
        reply_all_menuitem.set_attribute_value ("verb-icon", "mail-reply-all-symbolic");

        var forward_menuitem = new GLib.MenuItem ("Forward", null);
        forward_menuitem.set_attribute_value ("verb-icon", "mail-forward-symbolic");

        var button_menu = new GLib.Menu ();
        button_menu.append_item (reply_menuitem);
        button_menu.append_item (reply_all_menuitem);
        button_menu.append_item (forward_menuitem);

        var button_section = new GLib.MenuItem.section (null, button_menu);
        button_section.set_attribute_value ("display-hint", "circular-buttons");

        var menu_model = new GLib.Menu ();
        menu_model.append_item (button_section);
        menu_model.append ("Move", null);
        menu_model.append ("Delete", null);

        var liststore = new GLib.ListStore (typeof (ListObject));
        liststore.append (new ListObject () {
            text = "Row 1"
        });
        liststore.append (new ListObject () {
            text = "Row 2"
        });
        liststore.append (new ListObject () {
            text = "Row 3"
        });
        liststore.append (new ListObject () {
            text = "Row 4"
        });
        liststore.append (new ListObject () {
            text = "Row 5"
        });

        var selection_model = new Gtk.SingleSelection (liststore);

        var factory = new Gtk.SignalListItemFactory ();
        factory.setup.connect ((obj) => {
            var list_item = (Gtk.ListItem) obj;
            list_item.child = new Granite.ListItem () {
                menu_model = menu_model
            };
        });

        factory.bind.connect ((obj) => {
            var list_item = (Gtk.ListItem) obj;
            var list_object = (ListObject) list_item.item;

            var granite_list_item = ((Granite.ListItem) list_item.child);
            granite_list_item.text = list_object.text;
        });

        var list_view = new Gtk.ListView (selection_model, factory) {
            show_separators = true
        };

        var scrolled_window = new Gtk.ScrolledWindow () {
            child = list_view,
            has_frame = true,
            hscrollbar_policy = NEVER,
            min_content_height = 128
        };

        var vbox = new Granite.Box (VERTICAL, HALF) {
            margin_top = 12,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12
        };
        vbox.append (card_title);
        vbox.append (list_box);
        vbox.append (scrolled_title);
        vbox.append (scrolled_window);

        content = vbox;

        separators_modelbutton.bind_property ("active", list_box, "show-separators", SYNC_CREATE | DEFAULT);
    }

    private class ListObject : Object {
        public string text { get; set; }
    }
}
