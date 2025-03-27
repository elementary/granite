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

        var lock_button = new Gtk.Button ();
        lock_button.child = new Granite.AccelLabel ("Lock", "<Super>L");
        lock_button.add_css_class (Granite.STYLE_CLASS_MENUITEM);

        var logout_button = new Gtk.Button ();
        logout_button.child = new Granite.AccelLabel ("Log Out…", "<Ctrl><Alt>Delete");
        logout_button.add_css_class (Granite.STYLE_CLASS_MENUITEM);

        var popover_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        popover_box.append (lock_button);
        popover_box.append (logout_button);

        var popover = new Gtk.Popover () {
            child = popover_box,
            has_arrow = false
        };
        popover.add_css_class (Granite.STYLE_CLASS_MENU);

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
