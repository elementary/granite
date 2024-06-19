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
        set_css_name ("modelbutton");
    }

    construct {
        var label = new Gtk.Label (text) {
            ellipsize = Pango.EllipsizeMode.MIDDLE,
            halign = Gtk.Align.START,
            hexpand = true,
            vexpand = true,
            max_width_chars = 25,
            mnemonic_widget = this
        };

        var description_label = new Gtk.Label (null) {
            max_width_chars = 25,
            wrap = true,
            xalign = 0
        };
        description_label.add_css_class (Granite.STYLE_CLASS_SMALL_LABEL);
        description_label.add_css_class (Granite.STYLE_CLASS_DIM_LABEL);

        var description_revealer = new Gtk.Revealer () {
            child = description_label
        };

        layout_manager = new Gtk.BoxLayout (HORIZONTAL);

        var box = new Gtk.Box (VERTICAL, 0);
        box.append (label);
        box.set_parent (this);

        var button_switch = new Gtk.Switch () {
            focusable = false,
            valign = Gtk.Align.START
        };
        button_switch.set_parent (this);

        accessible_role = SWITCH;

        bind_property ("text", label, "label");
        bind_property ("description", description_label, "label");
        bind_property ("active", button_switch, "active", BIDIRECTIONAL | SYNC_CREATE);

        var controller = new Gtk.GestureClick ();
        add_controller (controller);

        // Binding active doesn't trigger the switch animation; we must listen and manually activate
        controller.released.connect (() => {
            button_switch.activate ();
        });

        notify["active"].connect (() => {
            update_state (Gtk.AccessibleState.CHECKED, active, -1);
        });

        notify["description"].connect (() => {
            update_property (Gtk.AccessibleProperty.DESCRIPTION, description, -1);

            if (description == null || description == "") {
                box.remove (description_revealer);
            } else {
                box.append (description_revealer);
                button_switch.bind_property ("active", description_revealer, "reveal-child", GLib.BindingFlags.SYNC_CREATE);
            }
        });
    }

    ~SwitchModelButton () {
        while (get_first_child () != null) {
            get_first_child ().unparent ();
        }
    }
}
