/*
 * Copyright 2024 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

/**
 * BackButton is meant to be used in hearders to navigate in
 * {@link Adw.NavigationView}s. It will automatically detect when under a
 * {@link Adw.NavigationView} and label itself with the title of the preceding page.
 */
 public class Granite.BackButton : Gtk.Button {
    construct {
        add_css_class (Granite.STYLE_CLASS_BACK_BUTTON);

        map.connect (on_map);
        clicked.connect (on_click);
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
            label = previous_page.title;
        }
    }

    private void on_click () {
        var navigation_view = (Adw.NavigationView) get_ancestor (typeof (Adw.NavigationView));

        if (navigation_view != null) {
            navigation_view.pop ();
        }
    }
}
