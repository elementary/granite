/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class ListsView : DemoPage {
    construct {
        var title_label = new Granite.HeaderLabel ("Lists") {
            size = H1
        };

        var scrolled_title = new Granite.HeaderLabel ("Scrolled List") {
            secondary_text = "ScrolledWindow with \"has-frame = true\" has a view level background color"
        };

        var rich_listbox = new Gtk.ListBox () {
            show_separators = true
        };
        rich_listbox.append (
            new Granite.ListItem () {
                text = "This is a \"Granite.ListItem\"",
                description = "\"Granite.ListItem\" has a standardized row height and padding"
            }
        );
        rich_listbox.append (
            new Granite.ListItem () {
                text = "Row 3"
            }

        );
        rich_listbox.append (
            new Granite.ListItem () {
                text = "Row 4"
            }
        );

        var card_title = new Granite.HeaderLabel ("Gtk.ListBox") {
            secondary_text = "This ListBox has \"Granite.CssClass.CARD\""
        };

        var scrolled_window = new Gtk.ScrolledWindow () {
            child = rich_listbox,
            has_frame = true,
            hscrollbar_policy = NEVER,
            min_content_height = 128
        };

        var separators_modelbutton = new Granite.SwitchModelButton ("Show Separators") {
            active = true,
            description = "\"show-separators = true\""
        };

        var card_listbox = new Gtk.ListBox () {
            show_separators = true
        };
        card_listbox.add_css_class (Granite.CssClass.CARD);
        card_listbox.append (
            new Granite.ListItem () {
                text = "This is a \"Granite.ListItem\"",
                description = "\"Granite.ListItem\" has a standardized row height and padding"
            }
        );
        card_listbox.append (new Granite.ListItem () { child = separators_modelbutton });

        var vbox = new Granite.Box (VERTICAL, HALF) {
            margin_top = 12,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12
        };
        vbox.append (title_label);
        vbox.append (scrolled_title);
        vbox.append (scrolled_window);
        vbox.append (card_title);
        vbox.append (card_listbox);

        content = vbox;

        separators_modelbutton.bind_property ("active", card_listbox, "show-separators", SYNC_CREATE | DEFAULT);
    }
}
