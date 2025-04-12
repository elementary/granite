/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

/**
 * 
 *
 * @since 7.7.0
 */
[Version (since = "7.7.0")]
public class Granite.ActionSheet : Gtk.Popover {
    public Gtk.ApplicationWindow application_window { get; construct; }

    private const string ACTION_GROUP = "action-sheet";
    private const string ACTION_PRESENT = "present";

    public ActionSheet (Gtk.ApplicationWindow application_window) {
        Object (application_window: application_window);
    }

    class construct {
        set_css_name ("action-sheet");
    }

    construct {
        var search_entry = new Gtk.SearchEntry ();

        var selection_model = new Gtk.NoSelection (null);

        var factory = new Gtk.SignalListItemFactory ();

        var list_view = new Gtk.ListView (selection_model, factory);

        var scrolled_window = new Gtk.ScrolledWindow () {
            child = list_view,
            overflow = HIDDEN,
            propagate_natural_height = true
        };

        var box = new Granite.Box (VERTICAL);
        box.append (search_entry);
        box.append (scrolled_window);

        position = TOP;
        child = box;
        autohide = true;
        has_arrow = false;

        set_parent (application_window);

        var present_action = new GLib.SimpleAction (ACTION_PRESENT, null);
        present_action.activate.connect (() => {
            set_pointing_to (Gdk.Rectangle () {
                x = (int) application_window.get_width () / 2,
                y = (int) application_window.get_height () / 2
            });

            scrolled_window.max_content_height = application_window.get_height () / 2;

            popup ();
        });

        var action_group = new GLib.SimpleActionGroup ();
        action_group.add_action (present_action);

        ((Gtk.Application) Application.get_default ()).set_accels_for_action (ACTION_GROUP + "." + ACTION_PRESENT, {"<Ctrl><Shift>P"});

        application_window.insert_action_group (ACTION_GROUP, action_group);
    }
}
