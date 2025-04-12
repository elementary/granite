/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

/**
 * A standard list item widget for use in {@link Gtk.ListBox} and {@link Gtk.ListView}
 *
 * @since 7.7.0
 */
[Version (since = "7.7.0")]
public class Granite.ListItem : Granite.Bin {
    /**
     * The main label for #this
     */
    public string text { get; set; }

    /**
     * Small, dim description text
     */
    public string? description { get; set; }

    /**
     * Context menu model
     * When a menu is shown with secondary click or long press will be constructed from the provided menu model
     */
    public GLib.Menu? menu_model { get; set; }

    private Gtk.GestureClick? click_controller;
    private Gtk.GestureLongPress? long_press_controller;
    private Gtk.EventControllerKey menu_key_controller;
    private Gtk.PopoverMenu? context_menu;

    class construct {
        set_css_name ("granite-listitem");
    }

    construct {
        var label = new Gtk.Label ("") {
            hexpand = true,
            vexpand = true,
            wrap = true,
            xalign = 0,
            mnemonic_widget = this
        };

        var description_label = new Gtk.Label ("") {
            wrap = true,
            xalign = 0
        };
        description_label.add_css_class (Granite.STYLE_CLASS_SMALL_LABEL);
        description_label.add_css_class (Granite.STYLE_CLASS_DIM_LABEL);

        var text_box = new Granite.Box (VERTICAL, NONE);
        text_box.append (label);
        text_box.add_css_class ("text-box");

        child = text_box;

        bind_property ("text", label, "label");
        bind_property ("description", description_label, "label");

        notify["description"].connect (() => {
            update_property (Gtk.AccessibleProperty.DESCRIPTION, description, -1);

            if (description == null || description == "") {
                text_box.remove (description_label);
            } else {
                text_box.append (description_label);
            }
        });

        notify["menu-model"].connect (construct_menu);
    }

    private void construct_menu () {
        if (menu_model == null) {
            remove_controller (click_controller);
            remove_controller (long_press_controller);
            parent.remove_controller (menu_key_controller);

            click_controller = null;
            long_press_controller = null;
            menu_key_controller = null;

            context_menu.unparent ();
            context_menu = null;

            return;
        }

        if (context_menu != null) {
            context_menu.menu_model = menu_model;
            return;
        }

        context_menu = new Gtk.PopoverMenu.from_model (menu_model) {
            has_arrow = false,
            position = BOTTOM
        };
        context_menu.set_parent (this);

        click_controller = new Gtk.GestureClick () {
            button = 0,
            exclusive = true
        };
        click_controller.pressed.connect ((n_press, x, y) => {
            var sequence = click_controller.get_current_sequence ();
            var event = click_controller.get_last_event (sequence);

            if (event.triggers_context_menu ()) {
                context_menu.halign = START;
                menu_popup_at_pointer (context_menu, x, y);

                click_controller.set_state (CLAIMED);
                click_controller.reset ();
            }
        });

        long_press_controller = new Gtk.GestureLongPress ();
        long_press_controller.pressed.connect ((x, y) => {
            // Try to keep menu from under your hand
            if (x > get_root ().get_width () / 2) {
                context_menu.halign = END;
            } else {
                context_menu.halign = START;
            }

            menu_popup_at_pointer (context_menu, x, y);
        });

        menu_key_controller = new Gtk.EventControllerKey ();
        menu_key_controller.key_released.connect ((keyval, keycode, state) => {
            var mods = state & Gtk.accelerator_get_default_mod_mask ();
            switch (keyval) {
                case Gdk.Key.F10:
                    if (mods == Gdk.ModifierType.SHIFT_MASK) {
                        menu_popup_on_keypress (context_menu);
                    }
                    break;
                case Gdk.Key.Menu:
                case Gdk.Key.MenuKB:
                    menu_popup_on_keypress (context_menu);
                    break;
                default:
                    return;
            }
        });

        add_controller (click_controller);
        add_controller (long_press_controller);

        // We don't get key events on the child list item widget
        if (parent != null) {
            parent.add_controller (menu_key_controller);
        } else {
            notify["parent"].connect (() => {
                parent.add_controller (menu_key_controller);
            });
        }
    }

    private void menu_popup_on_keypress (Gtk.PopoverMenu popover) {
        popover.halign = END;
        popover.set_pointing_to (null);
        popover.popup ();
    }

    private void menu_popup_at_pointer (Gtk.PopoverMenu popover, double x, double y) {
        var rect = Gdk.Rectangle () {
            x = (int) x,
            y = (int) y
        };
        popover.pointing_to = rect;
        popover.popup ();
    }
}
