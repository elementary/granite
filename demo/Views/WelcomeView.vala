/*
 * Copyright 2017-2021 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class WelcomeView : DemoPage {
    construct {
        var welcome = new Granite.Placeholder ("Granite Demo") {
            description = "This is a demo of the Granite library."
        };

        var vala_button = welcome.append_button (
            new ThemedIcon ("text-x-vala"),
            "Visit Valadoc",
            "The canonical source for Vala API references"
        );

        var source_button = welcome.append_button (
            new ThemedIcon ("text-x-source"),
            "Get Granite Source",
            "Granite's source code is hosted on GitHub"
        );

        var alert = new Granite.Placeholder ("Panic! At the Button") {
            description = "Maybe you can <b>do something</b> to hide it but <i>otherwise</i> it will stay here",
            icon = new ThemedIcon ("dialog-warning")
        };
        alert.add_css_class (Granite.CssClass.WARNING);

        var alert_action = alert.append_button (
            new ThemedIcon ("edit-delete"),
            "Hide This Button",
            "Click here to hide this"
        );

        var search_placeholder = new Granite.Placeholder ("No Apps Found") {
            description = "Try changing search terms. You can also sideload Flatpak apps e.g. from <a href='https://flathub.org'>Flathub</a>",
            icon = new ThemedIcon ("edit-find-symbolic")
        };

        var listbox = new Gtk.ListBox () {
            margin_top = 12,
            margin_end = 12,
            margin_bottom = 12,
            margin_start = 12
        };
        listbox.set_placeholder (search_placeholder);
        listbox.add_css_class (Granite.STYLE_CLASS_FRAME);

        var search_entry = new Gtk.SearchEntry () {
            margin_top = 12,
            margin_bottom = 9,
            margin_start = 12,
            margin_end = 12
        };

        var popover_placeholder = new Granite.Placeholder ("No mailboxes found") {
            description = "Try changing search terms",
            halign = FILL,
            icon = new ThemedIcon ("edit-find-symbolic")
        };

        var popover_list = new Gtk.ListBox ();
        popover_list.set_placeholder (popover_placeholder);

        var box = new Gtk.Box (VERTICAL, 0);
        box.append (search_entry);
        box.append (popover_list);

        var popover = new Gtk.Popover () {
            autohide = true,
            child = box
        };

        var menubutton = new Gtk.MenuButton () {
            halign = CENTER,
            valign = CENTER,
            label = "Listbox in a Popover",
            popover = popover
        };

        var stack = new Gtk.Stack () {
            vexpand = true
        };
        stack.add_titled (welcome, "Welcome", "Welcome");
        stack.add_titled (alert, "Alert", "Alert");
        stack.add_titled (listbox, "ListBox", "ListBox");
        stack.add_titled (menubutton, "Popover", "Popover");

        var stack_switcher = new Gtk.StackSwitcher () {
            stack = stack
        };

        var main_box = new Granite.Box (VERTICAL, SINGLE) {
            margin_top = 12,
            margin_start = 12,
            margin_end = 12,
            margin_bottom = 12
        };
        main_box.append (stack_switcher);
        main_box.append (stack);

        content = main_box;

        vala_button.clicked.connect (() => {
            var uri_launcher = new Gtk.UriLauncher ("https://valadoc.org/granite/Granite.html");
            uri_launcher.launch.begin ((Gtk.Window) get_root (), null);
        });

        source_button.clicked.connect (() => {
            var uri_launcher = new Gtk.UriLauncher ("https://github.com/elementary/granite");
            uri_launcher.launch.begin ((Gtk.Window) get_root (), null);
        });

        alert_action.clicked.connect (() => {
            alert_action.hide ();
        });
    }
}
