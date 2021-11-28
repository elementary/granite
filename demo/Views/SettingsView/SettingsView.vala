/*
 * Copyright 2017-2021 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class SettingsView : Gtk.Box {
    construct {
        var paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);

        var settings_page = new SimpleSettingsPage ();

        var settings_page_two = new SettingsPage ();

        var stack = new Gtk.Stack ();
        stack.add_named (settings_page, "settings_page");
        stack.add_named (settings_page_two, "settings_page_two");

        var settings_sidebar = new Granite.SettingsSidebar (stack);

        paned.start_child = settings_sidebar;
        paned.end_child = stack;

        append (paned);
    }
}
