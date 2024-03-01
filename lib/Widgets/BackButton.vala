/*
 * Copyright 2024 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

/**
 * BackButton is meant to be used in headers to navigate in
 * {@link Adw.NavigationView}s. It will automatically detect when under a
 * {@link Adw.NavigationView} and label itself with the title of the preceding page.
 */
[Version (since = "7.5.0")]
public class Granite.BackButton : Gtk.Button {
    /**
     * A manually set label when used outside of {@link Adw.NavigationView}
     */
    public new string label { get; set; }

    construct {
        var image = new Gtk.Image.from_icon_name ("go-previous-symbolic");

        var label_widget = new Gtk.Label ("");

        var box = new Gtk.Box (HORIZONTAL, 0);
        box.append (image);
        box.append (label_widget);

        child = box;

        map.connect (on_map);
        clicked.connect (on_click);

        bind_property ("label", label_widget, "label");
    }

    private void on_map () {
        var navigation_view = (Adw.NavigationView) get_ancestor (typeof (Adw.NavigationView));

        if (navigation_view == null) {
            warning ("Granite.BackButton used outside of Adw.NavigationView");
            return;
        }

        var navigation_page = (Adw.NavigationPage) get_ancestor (typeof (Adw.NavigationPage));

        if (navigation_view == null) {
            warning ("Granite.BackButton used outside of Adw.NavigationPage");
            return;
        }

        var previous_page = navigation_view.get_previous_page (navigation_page);

        if (previous_page != null) {
            visible = true;
            label = previous_page.title;
        } else {
            visible = false;
        }
    }

    private void on_click () {
        var navigation_view = (Adw.NavigationView) get_ancestor (typeof (Adw.NavigationView));

        if (navigation_view != null) {
            navigation_view.pop ();
        }
    }
}