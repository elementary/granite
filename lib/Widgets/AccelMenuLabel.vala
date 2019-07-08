/*
* Copyright (c) 2019 elementary, Inc. (https://elementary.io)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

/**
 * AccelMenuLabel is meant to be used as a {@link Gtk.MenuItem} child for displaying
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
 *   copy_menuitem.add (new Granite.AccelMenuLabel (_("Copy"), copy_menuitem.action_name));
 * }}}
 *
 */
public class Granite.AccelMenuLabel : Gtk.Grid {
    /**
     * The name of the {@link GLib.Action} used to retrieve action accelerators
     */
    public string action_name { get; construct; }

    /**
     * The user-facing menu item label
     */
    public string label { get; construct; }

    /**
     * Creates a new AccelMenuLabel from a label and an action name
     *
     * @param label displayed to the user as the menu item name
     * @param action_name name of the {@link GLib.Action} used to retrieve action accelerators
     */
    public AccelMenuLabel (string label, string action_name) {
        Object (
            label: label,
            action_name: action_name
        );
    }

    construct {
        var label = new Gtk.Label (label);
        label.hexpand = true;
        label.xalign = 0;

        column_spacing = 3;
        add (label);

        string[] accels = Granite.accel_to_string (
            ((Gtk.Application) GLib.Application.get_default ()).get_accels_for_action (action_name)[0]
        ).split (" + ");

        if (accels[0] != "") {
            foreach (unowned string accel in accels) {
                if (accel == "") {
                    continue;
                }
                var accel_label = new Gtk.Label (accel);
                accel_label.get_style_context ().add_class ("keycap");
                accel_label.get_style_context ().add_class (Gtk.STYLE_CLASS_ACCELERATOR);
                add (accel_label);
            }
        }
    }
}
