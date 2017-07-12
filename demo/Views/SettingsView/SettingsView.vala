/*
 * Copyright (c) 2017 elementary LLC. (https://elementary.io)
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
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
