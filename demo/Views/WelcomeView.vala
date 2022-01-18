/*
 * Copyright 2017-2021 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class WelcomeView : Gtk.Box {
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
        alert.add_css_class (Granite.STYLE_CLASS_WARNING);

        var alert_action = alert.append_button (
            new ThemedIcon ("edit-delete"),
            "Hide This Button",
            "Click here to hide this"
        );

        var search_placeholder = new Granite.Placeholder ("No Apps Found") {
            description = "Try changing search terms. You can also sideload Flatpak apps e.g. from <a href='https://flathub.org'>Flathub</a>",
            icon = new ThemedIcon ("edit-find-symbolic")
        };

        var stack = new Gtk.Stack () {
            vexpand = true
        };
        stack.add_titled (welcome, "Welcome", "Welcome");
        stack.add_titled (alert, "Alert", "Alert");
        stack.add_titled (search_placeholder, "Search", "Search");

        var stack_switcher = new Gtk.StackSwitcher () {
            margin_top = 24,
            margin_end = 24,
            margin_start = 24,
            stack = stack
        };

        orientation = Gtk.Orientation.VERTICAL;
        append (stack_switcher);
        append (stack);

        vala_button.clicked.connect (() => {
            Gtk.show_uri (null, "https://valadoc.org/granite/Granite.html", Gdk.CURRENT_TIME);
        });

        source_button.clicked.connect (() => {
            Gtk.show_uri (null, "https://github.com/elementary/granite", Gdk.CURRENT_TIME);
        });

        alert_action.clicked.connect (() => {
            alert_action.hide ();
        });
    }
}
