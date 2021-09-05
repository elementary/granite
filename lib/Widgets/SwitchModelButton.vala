/*
 * Copyright 2021 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

/**
 * SwitchModelButton is a {@link Gtk.ToggleButton} containing a {@link Gtk.Label}
 * and a {@link Gtk.Switch} and using the menuitem css name. It can optionally
 * show description text when activated.
 *
 * ''Example''<<BR>>
 * {{{
 *   var switchmodelbutton = new Granite.SwitchModelButton ("With Description") {
 *       active = true,
 *       description = "A description of additional affects related to the activation state of this switch"
 *   };
 * }}}
 */
public class Granite.SwitchModelButton : Gtk.ToggleButton {
    /**
     * The label for the button.
     */
    public string text { get; construct set; }

    /**
     * Small, dim description text shown when active.
     */
    public string? description { get; set; }

    public SwitchModelButton (string text) {
        Object (text: text);
    }

    class construct {
        set_css_name (Gtk.STYLE_CLASS_MENUITEM);
    }

    construct {
        var label = new Gtk.Label (text) {
            halign = Gtk.Align.START,
            hexpand = true,
            vexpand = true
        };

        var description_label = new Gtk.Label (null) {
            max_width_chars = 25,
            wrap = true,
            xalign = 0
        };

        unowned var description_style_context = description_label.get_style_context ();
        description_style_context.add_class (Granite.STYLE_CLASS_SMALL_LABEL);
        description_style_context.add_class (Gtk.STYLE_CLASS_DIM_LABEL);

        var description_revealer = new Gtk.Revealer ();
        description_revealer.add (description_label);

        var button_switch = new Gtk.Switch () {
            valign = Gtk.Align.START
        };

        var grid = new Gtk.Grid () {
            column_spacing = 12
        };
        grid.attach (label, 0, 0);
        grid.attach (button_switch, 1, 0, 1, 2);

        add (grid);

        bind_property ("text", label, "label");
        bind_property ("description", description_label, "label");
        bind_property ("active", button_switch, "active", GLib.BindingFlags.BIDIRECTIONAL);

        // Binding active doesn't trigger the switch animation; we must listen and manually activate
        button_release_event.connect (() => {
            button_switch.activate ();
            return Gdk.EVENT_STOP;
        });

        notify["description"].connect (() => {
            if (description == null || description == "") {
                grid.remove (description_revealer);
            } else {
                grid.attach (description_revealer, 0, 1);
                button_switch.bind_property ("active", description_revealer, "reveal-child", GLib.BindingFlags.SYNC_CREATE);
            }
        });
    }
}
