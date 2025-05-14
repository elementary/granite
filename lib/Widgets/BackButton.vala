/*
 * Copyright 2024 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

/**
 * BackButton is meant to be used in headers to navigate in
 * {@link Adw.NavigationView}.
 *
 * By default `action_name` is set to `navigation.pop`
 */
[Version (since = "7.7.0")]
public class Granite.BackButton : Gtk.Button {
    /**
     * Text of the label inside of #this
     */
    public new string label { get; set; }


    construct {
        var image = new Gtk.Image.from_icon_name ("go-previous-symbolic");

        var label_widget = new Gtk.Label ("");

        var box = new Gtk.Box (HORIZONTAL, 0);
        box.append (image);
        box.append (label_widget);

        action_name = "navigation.pop";
        child = box;
        tooltip_markup = Granite.markup_accel_tooltip ({"<alt>Left"});
    }
}
