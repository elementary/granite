/*
 * Copyright 2019 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

/**
 * AccelLabel is meant to be used as a {@link Gtk.MenuItem} child for displaying
 * a {@link GLib.Action}'s accelerator alongside the Menu Item label.
 *
 * The class itself is similar to it's Gtk equivalent {@link Gtk.AccelLabel}
 * but follows elementary OS design conventions. Specifically, this class uses
 * {@link Granite.accel_to_string} for accelerator string parsing.
 *
 * ''Example''<<BR>>
 * {{{
 *   var copy_menuitem = new Gtk.MenuItem ();
 *   copy_menuitem.set_action_name (ACTION_PREFIX + ACTION_COPY);
 *   copy_menuitem.add (new Granite.AccelLabel.from_action_name (_("Copy"), copy_menuitem.action_name));
 * }}}
 *
 */
public class Granite.AccelLabel : Gtk.Grid {
    /**
     * The name of the {@link GLib.Action} used to retrieve action accelerators
     */
    public string action_name { get; construct set; }

    /**
     * A {@link Gtk.accelerator_parse} style accel string like “<Control>a” or “<Super>Right”
     */
    public string? accel_string { get; construct set; }

    /**
     * The user-facing menu item label
     */
    public string label { get; construct set; }

    /**
     * Creates a new AccelLabel from a label and an accelerator string
     *
     * @param label displayed to the user as the menu item name
     * @param accel an accelerator label like “<Control>a” or “<Super>Right”
     */
    public AccelLabel (string label, string? accel_string = null) {
        Object (
            label: label,
            accel_string: accel_string
        );
    }

    /**
     * Creates a new AccelLabel from a label and an action name
     *
     * @param label displayed to the user as the menu item name
     * @param action_name name of the {@link GLib.Action} used to retrieve action accelerators
     */
    public AccelLabel.from_action_name (string label, string action_name) {
        Object (
            label: label,
            action_name: action_name
        );
    }

    static construct {
        Granite.init ();
    }

    construct {
        var label = new Gtk.Label (label);
        label.hexpand = true;
        label.margin_end = 6;
        label.xalign = 0;

        column_spacing = 3;
        add (label);

        update_accels ();

        notify["accel-string"].connect (update_accels);
        notify["action-name"].connect (update_accels);

        bind_property ("label", label, "label");
    }

    private void update_accels () {
        GLib.List<unowned Gtk.Widget> list = get_children ();
        for (int i = 0; i < list.length () - 1; i++) {
            list.nth_data (i).destroy ();
        }

        string[] accels = {""};
        if (accel_string != null && accel_string != "") {
            accels = Granite.accel_to_string (accel_string).split (" + ");
        } else if (action_name != null && action_name != "") {
            accel_string = ((Gtk.Application) GLib.Application.get_default ()).get_accels_for_action (action_name)[0];
        }

        if (accels[0] != "") {
            foreach (unowned string accel in accels) {
                if (accel == "") {
                    continue;
                }
                var accel_label = new Gtk.Label (accel);

                var accel_label_context = accel_label.get_style_context ();
                accel_label_context.add_class (Granite.STYLE_CLASS_KEYCAP);

                add (accel_label);
            }
        }
        show_all ();
    }
}
