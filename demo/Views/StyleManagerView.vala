/*
 * Copyright 2024 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class StyleManagerView : Gtk.Box {
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

        halign = CENTER;
        valign = CENTER;
        orientation = VERTICAL;
        spacing = 6;
        append (label);
        append (dont_button);
        append (force_light);
        append (force_dark);

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
