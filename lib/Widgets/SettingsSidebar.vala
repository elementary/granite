/*
 * Copyright 2017 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-2.1-or-later
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
