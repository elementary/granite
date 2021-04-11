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
     * The name of the currently visible Granite.SettingsPage
     */
    public string? visible_child_name {
        get {
            var selected_row = listbox.get_selected_row ();

            if (selected_row == null) {
                return null;
            } else {
                return ((SettingsSidebarRow) selected_row).page.title;
            }
        }
        set {
            foreach (unowned Gtk.Widget listbox_child in listbox.get_children ()) {
                if (((SettingsSidebarRow) listbox_child).page.title == value) {
                    listbox.select_row ((Gtk.ListBoxRow) listbox_child);
                }
            }
        }
    }

    /**
     * Create a new SettingsSidebar
     */
    public SettingsSidebar (Gtk.Stack stack) {
        Object (
            stack: stack
        );
    }

    construct {
        hscrollbar_policy = Gtk.PolicyType.NEVER;
        width_request = 200;
        listbox = new Gtk.ListBox ();
        listbox.activate_on_single_click = true;
        listbox.selection_mode = Gtk.SelectionMode.SINGLE;

        add (listbox);

        on_sidebar_changed ();
        stack.add.connect (on_sidebar_changed);
        stack.remove.connect (on_sidebar_changed);

        listbox.row_selected.connect ((row) => {
            stack.visible_child = ((SettingsSidebarRow) row).page;
        });

        listbox.set_header_func ((row, before) => {
            var header = ((SettingsSidebarRow) row).header;
            if (header != null) {
                row.set_header (new HeaderLabel (header));
            }
        });

        stack.notify["visible-child-name"].connect (() => {
            visible_child_name = stack.visible_child_name;
        });
    }

    private void on_sidebar_changed () {
        listbox.get_children ().foreach ((listbox_child) => {
            listbox_child.destroy ();
        });

        stack.get_children ().foreach ((child) => {
            if (child is SettingsPage) {
                var row = new SettingsSidebarRow ((SettingsPage) child);
                listbox.add (row);
            }
        });

        listbox.show_all ();
    }
}
