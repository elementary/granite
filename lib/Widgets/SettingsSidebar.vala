/*
* Copyright (c) 2017 elementary LLC. (https://elementary.io)
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU Lesser General Public License as published by
* the Free Software Foundation, either version 2.1 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU Library General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

/**
 * SettingsSidebar acts as a controller for a Gtk.Stack; it shows a row of buttons
 * to switch between the various pages of the associated stack widget.
 *
 * All the content for the rows comes from the child properties of a Granite.SettingsPage
 * inside of the Gtk.Stack
 */
public class Granite.SettingsSidebar : Gtk.ScrolledWindow {
    private Gtk.ListBox listbox;

    /**
     * The Gtk.Stack to control
     */
    public Gtk.Stack stack { get; construct; }

    /**
     * Create a new SettingsSidebar
     */
    public SettingsSidebar (Gtk.Stack stack) {
        Object (
            hscrollbar_policy: Gtk.PolicyType.NEVER,
            stack: stack,
            width_request: 200
        );
    }

    construct {
        listbox = new Gtk.ListBox ();
        listbox.activate_on_single_click = true;
        listbox.selection_mode = Gtk.SelectionMode.SINGLE;

        add (listbox);

        on_sidebar_changed ();
        stack.add.connect (on_sidebar_changed);
        stack.remove.connect (on_sidebar_changed);

        listbox.row_selected.connect ((row) => {
            stack.visible_child_name = ((SettingsSidebarRow) row).name;
        });

        listbox.set_header_func ((row, before) => {
            var header = ((SettingsSidebarRow) row).header;
            if (header != null) {
                row.set_header (new HeaderLabel (header));
            }
        });
    }

    private void on_sidebar_changed () {
        foreach (unowned Gtk.Widget listbox_child in listbox.get_children ()) {
            listbox_child.destroy ();
        }

        foreach (unowned Gtk.Widget child in stack.get_children ()) {
            string name;

            stack.child_get (child, "name", out name, null);

            if (child is SettingsPage) {
                var page = (SettingsPage) child;

                SettingsSidebarRow row;

                if (page.icon_name != null) {
                    row = new SettingsSidebarRow.from_icon_name (page.icon_name, page.title);
                } else {
                    row = new SettingsSidebarRow (page.display_widget, page.title);
                }

                row.name = name;
                row.header = page.header;

                page.bind_property ("icon-name", row, "icon-name", BindingFlags.DEFAULT);
                page.bind_property ("status", row, "status", BindingFlags.DEFAULT);
                page.bind_property ("status-type", row, "status-type", BindingFlags.DEFAULT);
                page.bind_property ("title", row, "title", BindingFlags.DEFAULT);

                if (page.status != null) {
                    row.status = page.status;
                }

                if (page.status_type != SettingsPage.StatusType.NONE) {
                    row.status_type = page.status_type;
                }

                listbox.add (row);
            }
        }

        listbox.show_all ();
    }
}
