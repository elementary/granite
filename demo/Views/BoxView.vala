/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class BoxView : DemoPage {
    construct {
        title = "Granite.Box";

        var single_header = new Granite.HeaderLabel ("Single Spaced") {
            secondary_text = "child_spacing = SINGLE"
        };

        var single_box = new Granite.Box (HORIZONTAL);
        single_box.append (new Gtk.Image.from_icon_name ("application-default-icon") { icon_size = LARGE });
        single_box.append (new Gtk.Image.from_icon_name ("application-default-icon") { icon_size = LARGE });

        var single_container = new Granite.Box (VERTICAL);
        single_container.append (single_header);
        single_container.append (single_box);

        var double_header = new Granite.HeaderLabel ("Double Spaced") {
            secondary_text = "child_spacing = DOUBLE"
        };

        var double_box = new Granite.Box (HORIZONTAL, DOUBLE);
        double_box.append (new Gtk.Image.from_icon_name ("application-default-icon") { icon_size = LARGE });
        double_box.append (new Gtk.Image.from_icon_name ("application-default-icon") { icon_size = LARGE });

        var double_container = new Granite.Box (VERTICAL);
        double_container.append (double_header);
        double_container.append (double_box);

        var linked_header = new Granite.HeaderLabel ("Linked") {
            secondary_text = "child_spacing = LINKED"
        };

        var column_button = new Gtk.ToggleButton () { active = true, icon_name = "view-column-symbolic" };

        var linked_image_buttons = new Granite.Box (HORIZONTAL, LINKED);
        linked_image_buttons.append (column_button);
        linked_image_buttons.append (new Gtk.ToggleButton () { group = column_button, icon_name = "view-grid-symbolic" });
        linked_image_buttons.append (new Gtk.ToggleButton () { group = column_button, icon_name = "view-list-symbolic" });

        var linked_text_buttons = new Granite.Box (HORIZONTAL, LINKED);
        linked_text_buttons.append (new Gtk.Button.with_label ("Button") { hexpand = true });
        linked_text_buttons.append (new Gtk.Button.with_label ("Button") { hexpand = true });

        var linked_buttons_box = new Granite.Box (HORIZONTAL);
        linked_buttons_box.append (linked_image_buttons);
        linked_buttons_box.append (linked_text_buttons);

        var linked_entries_box = new Granite.Box (HORIZONTAL, LINKED);
        linked_entries_box.append (new Gtk.Entry () { hexpand = true, placeholder_text = "Entry"});
        linked_entries_box.append (new Gtk.Entry () { hexpand = true, placeholder_text = "Entry"});

        var linked_entry_imagebutton_box = new Granite.Box (HORIZONTAL, LINKED);
        linked_entry_imagebutton_box.append (new Gtk.Entry () { hexpand = true, placeholder_text = "Entry"});
        linked_entry_imagebutton_box.append (new Gtk.ToggleButton () { icon_name = "view-more-symbolic" });

        var linked_vbox = new Granite.Box (VERTICAL);
        linked_vbox.append (linked_buttons_box);
        linked_vbox.append (linked_entries_box);
        linked_vbox.append (linked_entry_imagebutton_box);

        var vertical_imagebuttons = new Granite.Box (VERTICAL, LINKED);
        vertical_imagebuttons.append (new Gtk.Button () { icon_name = "edit-cut" });
        vertical_imagebuttons.append (new Gtk.Button () { icon_name = "edit-copy" });
        vertical_imagebuttons.append (new Gtk.Button () { icon_name = "edit-paste" });
        vertical_imagebuttons.append (new Gtk.Button () { icon_name = "edit-delete" });

        var linked_hbox = new Granite.Box (HORIZONTAL);
        linked_hbox.append (linked_vbox);
        linked_hbox.append (vertical_imagebuttons);

        var linked_box = new Granite.Box (VERTICAL);
        linked_box.append (linked_header);
        linked_box.append (linked_hbox);

        var vbox = new Granite.Box (VERTICAL, DOUBLE) {
            margin_top = 12,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12
        };
        vbox.append (single_container);
        vbox.append (double_container);
        vbox.append (linked_box);

        content = vbox;
    }
}
