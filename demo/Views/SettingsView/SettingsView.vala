/*
 * Copyright 2017 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class SettingsView : Gtk.Paned {
    construct {
        var settings_page = new SimpleSettingsPage ();

        var settings_page_two = new SettingsPage ();

        var stack = new Gtk.Stack ();
        stack.add_named (settings_page, "settings_page");
        stack.add_named (settings_page_two, "settings_page_two");

        var settings_sidebar = new Granite.SettingsSidebar (stack);

        add (settings_sidebar);
        add (stack);
    }
}
