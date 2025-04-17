/*
 * Copyright 2019-2021 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class AccelLabelView : DemoPage {
    construct {
        var accellabel_label = new Gtk.Label ("AccelLabel:");
        accellabel_label.halign = Gtk.Align.END;

        var copy_label = new Granite.AccelLabel ("Copy", "<Ctrl>C");

        var popover_label = new Gtk.Label ("In a Popover:");
        popover_label.halign = Gtk.Align.END;

        var lock_button = new Gtk.Button () {
            child = new Granite.AccelLabel ("Lock", "<Super>L")
        };
        lock_button.add_css_class ("model");

        var logout_button = new Gtk.Button () {
            child = new Granite.AccelLabel ("Log Out…", "<Ctrl><Alt>Delete")
        };
        logout_button.add_css_class ("model");

        var lock_item = new GLib.MenuItem (null, null);
        lock_item.set_attribute_value ("custom", "lock");

        var logout_item = new GLib.MenuItem (null, null);
        logout_item.set_attribute_value ("custom", "logout");

        var menu_model = new GLib.Menu ();
        menu_model.append_item (lock_item);
        menu_model.append_item (logout_item);

        var popover = new Gtk.PopoverMenu.from_model (menu_model) {
            has_arrow = false
        };
        popover.add_child (lock_button, "lock");
        popover.add_child (logout_button, "logout");

        var popover_button = new Gtk.MenuButton ();
        popover_button.popover = popover;

        var grid = new Gtk.Grid () {
            column_spacing = 12,
            row_spacing = 12,
            halign = CENTER,
            valign = CENTER
        };
        grid.attach (accellabel_label, 0, 0);
        grid.attach (copy_label, 1, 0);
        grid.attach (popover_label, 0, 1);
        grid.attach (popover_button, 1, 1);

        content = grid;
    }
}
