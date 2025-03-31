/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class ListsView : DemoPage {
    construct {
        var title_label = new Granite.HeaderLabel ("Lists") {
            size = H1
        };

        var separators_modelbutton = new Granite.SwitchModelButton ("Show Separators") {
            active = true,
            description = "\"show-separators = true\""
        };

        var rich_listbox = new Gtk.ListBox () {
            hexpand = true,
            show_separators = true
        };
        rich_listbox.add_css_class (Granite.CssClass.RICH_LIST);
        rich_listbox.append (new Granite.HeaderLabel ("This ListBox has \"Granite.CssClass.RICH_LIST\"") {
            secondary_text = "Rich lists have a standardized row height and padding"
        });
        rich_listbox.append (
            new Gtk.Label ("ListBoxes in a ScrolledWindow with \"has-frame = true\" have a view level background color") {
                halign = START,
                wrap = true
            }
        );
        rich_listbox.append (new Gtk.Label ("Row 3"));
        rich_listbox.append (new Gtk.Label ("Row 4"));

        var scrolled_window = new Gtk.ScrolledWindow () {
            child = rich_listbox,
            has_frame = true,
            hscrollbar_policy = NEVER
        };

        var card_listbox = new Gtk.ListBox () {
            hexpand = true,
            show_separators = true
        };
        card_listbox.add_css_class (Granite.CssClass.CARD);
        card_listbox.append (new Granite.HeaderLabel ("This ListBox has \"Granite.CssClass.CARD\"") {
            secondary_text = "Card listboxes are also always rich lists"
        });
        card_listbox.append (separators_modelbutton);

        var lists_box = new Granite.Box (HORIZONTAL, DOUBLE);
        lists_box.append (scrolled_window);
        lists_box.append (card_listbox);

        separators_modelbutton.bind_property ("active", card_listbox, "show-separators", SYNC_CREATE | DEFAULT);

        var vbox = new Granite.Box (VERTICAL, DOUBLE) {
            margin_top = 12,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12
        };
        vbox.append (title_label);
        vbox.append (lists_box);

        content = vbox;
    }
}
