/*
 * Copyright 2017-2022 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

/**
 * SettingsSidebar acts as a controller for a Gtk.Stack; it shows a row of buttons
 * to switch between the various pages of the associated stack widget.
 *
 * All the content for the rows comes from the child properties of a Granite.SettingsPage
 * inside of the Gtk.Stack
 */
[Version (deprecated = true, deprecated_since = "7.5.0", replacement = "Switchboard.SettingsSidebar")]
public class Granite.SettingsSidebar : Gtk.Widget {
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
            weak Gtk.Widget listbox_child = listbox.get_first_child ();
            while (listbox_child != null) {
                if (!(listbox_child is SettingsSidebarRow)) {
                    listbox_child = listbox_child.get_next_sibling ();
                    continue;
                }

                if (((SettingsSidebarRow) listbox_child).page.title == value) {
                    listbox.select_row ((Gtk.ListBoxRow) listbox_child);
                    break;
                }

                listbox_child = listbox_child.get_next_sibling ();
            }
        }
    }

    /**
     * Create a new SettingsSidebar
     */
    public SettingsSidebar (Gtk.Stack stack) {
        Object (stack: stack);
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BinLayout));
    }

    class construct {
        set_css_name ("settingssidebar");
    }

    construct {
        listbox = new Gtk.ListBox () {
            hexpand = true,
            activate_on_single_click = true,
            selection_mode = Gtk.SelectionMode.SINGLE
        };

        var scrolled = new Gtk.ScrolledWindow () {
            hscrollbar_policy = Gtk.PolicyType.NEVER,
            child = listbox
        };
        scrolled.set_parent (this);

        on_sidebar_changed ();
        stack.pages.items_changed.connect (on_sidebar_changed);

        listbox.row_selected.connect ((row) => {
            stack.visible_child = ((SettingsSidebarRow) row).page;
        });

        listbox.set_header_func ((row, before) => {
            var header = ((SettingsSidebarRow) row).header;
            if (header != null) {
                var label = new Gtk.Label (header) {
                    halign = Gtk.Align.START,
                    xalign = 0
                };

                label.add_css_class (Granite.STYLE_CLASS_H4_LABEL);
                row.set_header (label);
            }
        });

        stack.notify["visible-child-name"].connect (() => {
            visible_child_name = stack.visible_child_name;
        });
    }

    ~SettingsSidebar () {
        get_first_child ().unparent ();
    }

    private void on_sidebar_changed () {
        weak Gtk.Widget listbox_child = listbox.get_first_child ();
        while (listbox_child != null) {
            weak Gtk.Widget next_child = listbox_child.get_next_sibling ();
            listbox.remove (listbox_child);
            listbox_child = next_child;
        }

        weak Gtk.Widget child = stack.get_first_child ();
        while (child != null) {
            if (child is SettingsPage) {
                var row = new SettingsSidebarRow ((SettingsPage) child);
                listbox.append (row);
            }

            child = child.get_next_sibling ();
        }
    }
}
