/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class ListsView : DemoPage {
    construct {
        var title_label = new Granite.HeaderLabel ("Lists") {
            size = H1
        };

        var rich_listbox = new Gtk.ListBox () {
            hexpand = true,
            show_separators = true
        };
        rich_listbox.append (
            new Granite.ListItem () {
                child = new Granite.HeaderLabel ("This is a \"Granite.ListItem\"") {
                    secondary_text = "\"Granite.ListItem\" has a standardized row height and padding"
                }
            }
        );
        rich_listbox.append (
            new Granite.ListItem () {
                child = new Gtk.Label ("ScrolledWindow with \"has-frame = true\" has a view level background color") {
                    halign = START,
                    wrap = true
                }
            }

        );
        rich_listbox.append (
            new Granite.ListItem () {
                child = new Gtk.Label ("Row 3") {
                    halign = START,
                    wrap = true
                }
            }

        );
        rich_listbox.append (
            new Granite.ListItem () {
                child = new Gtk.Label ("Row 4") {
                    halign = START,
                    wrap = true
                }
            }

        );

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
            hexpand = true,
            show_separators = true
        };
        card_listbox.add_css_class (Granite.CssClass.CARD);
        card_listbox.append (
            new Granite.ListItem () { child = new Gtk.Label ("This ListBox has \"Granite.CssClass.CARD\"") }
        );
        card_listbox.append (new Granite.ListItem () { child = separators_modelbutton });

        var vbox = new Granite.Box (VERTICAL, DOUBLE) {
            margin_top = 12,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12
        };
        vbox.append (title_label);
        vbox.append (scrolled_window);
        vbox.append (card_listbox);

        content = vbox;

        separators_modelbutton.bind_property ("active", card_listbox, "show-separators", SYNC_CREATE | DEFAULT);
    }
}
