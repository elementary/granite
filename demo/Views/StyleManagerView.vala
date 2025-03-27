/*
 * Copyright 2024 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class StyleManagerView : DemoPage {
    construct {
        var label = new Granite.HeaderLabel ("Visual Style");

        var dont_button = new Gtk.CheckButton.with_label ("Follow system setting") {
            active = true
        };

        var force_light = new Gtk.CheckButton.with_label ("Light") {
            group = dont_button
        };

        var force_dark = new Gtk.CheckButton.with_label ("Dark") {
            group = force_light
        };

        var box = new Gtk.Box (VERTICAL, 6) {
            halign = CENTER,
            valign = CENTER
        };
        box.append (label);
        box.append (dont_button);
        box.append (force_light);
        box.append (force_dark);

        content = box;

        var style_manager = Granite.StyleManager.get_default ();

        dont_button.toggled.connect (() => {
            if (dont_button.active) {
                style_manager.color_scheme = NO_PREFERENCE;
            }
        });

        force_light.toggled.connect (() => {
            if (force_light.active) {
                style_manager.color_scheme = LIGHT;
            }
        });

        force_dark.toggled.connect (() => {
            if (force_dark.active) {
                style_manager.color_scheme = DARK;
            }
        });
    }
}
