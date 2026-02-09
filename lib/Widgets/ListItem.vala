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
public class Granite.ListItem : Gtk.Widget {
    // https://www.w3.org/WAI/WCAG21/Understanding/target-size.html
    private const int TOUCH_TARGET_WIDTH = 44;

    /**
     * The main label for #this
     */
    public string text { get; set; }

    /**
     * Small, dim description text
     */
    public string? description { get; set; }

    private Gtk.Widget? _child;
    /**
     * The child widget of #this
     */
    public Gtk.Widget? child {
        get {
            return _child;
        }

        set {
            if (value != null && value.get_parent () != null) {
                critical ("Tried to set a widget as child that already has a parent.");
                return;
            }

            if (_child != null) {
                _child.unparent ();
            }

            _child = value;

            if (_child != null) {
                _child.set_parent (this);
                _child.hexpand = true;
            }
        }
    }

    /**
     * Context menu model
     * When a menu is shown with secondary click or long press will be constructed from the provided menu model
     *
     * @since 7.8.0
     */
    [Version (since = "7.8.0")]
    public GLib.MenuModel? menu_model { get; set; }

    private Gtk.GestureClick? click_controller;
    private Gtk.GestureLongPress? long_press_controller;
    private Gtk.EventControllerKey menu_key_controller;
    private Gtk.PopoverMenu? context_menu;

    class construct {
        set_css_name ("granite-listitem");
        set_layout_manager_type (typeof (Gtk.BoxLayout));
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

        // So we can receive key events
        focusable = true;
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
            // Menu model is being set null for the first time
            if (context_menu != null) {
                remove_controller (click_controller);
                remove_controller (long_press_controller);
                remove_controller (menu_key_controller);

                click_controller = null;
                long_press_controller = null;
                menu_key_controller = null;

                context_menu.unparent ();
                context_menu = null;
            }

            return;
        }

        // New menu model, recycling popover and controllers
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
        click_controller.pressed.connect (on_click);

        long_press_controller = new Gtk.GestureLongPress () {
            touch_only = true
        };
        long_press_controller.pressed.connect (on_long_press);

        menu_key_controller = new Gtk.EventControllerKey ();
        menu_key_controller.key_released.connect (on_key_released);

        add_controller (click_controller);
        add_controller (long_press_controller);
        add_controller (menu_key_controller);
    }

    private void on_click (Gtk.GestureClick gesture, int n_press, double x, double y) {
        var sequence = gesture.get_current_sequence ();
        var event = gesture.get_last_event (sequence);

        if (event.triggers_context_menu ()) {
            context_menu.halign = START;
            menu_popup_at_pointer (context_menu, x, y);

            gesture.set_state (CLAIMED);
            gesture.reset ();
        }
    }

    private void on_long_press (double x, double y) {
        // Try to keep menu from under your hand
        if (x > get_root ().get_width () / 2) {
            context_menu.halign = END;
            x -= TOUCH_TARGET_WIDTH;
        } else {
            context_menu.halign = START;
            x += TOUCH_TARGET_WIDTH;
        }

        menu_popup_at_pointer (context_menu, x, y - (TOUCH_TARGET_WIDTH * 0.75));
    }

    private void on_key_released (uint keyval, uint keycode, Gdk.ModifierType state) {
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
    }

    private void menu_popup_on_keypress (Gtk.PopoverMenu popover) {
        popover.halign = END;
        popover.set_pointing_to (Gdk.Rectangle () {
            x = (int) get_width (),
            y = (int) get_height () / 2
        });
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

    ~ListItem () {
        if (child != null) {
            child.unparent ();
        }
    }

    /**
     * The following attributes are used when constructing menu items:
     *
     * - "label": a user-visible string to display
     * - "action": the prefixed name of the action to trigger
     * - "target": the parameter to use when activating the action
     * - "icon" and "verb-icon": names of icons that may be displayed or a question mark by default
     * - "css-class": a css style class for assigning a color or user accent colored by default
     *
     * The following style class values are supported:
     *
     * - "red" or "destructive"
     * - "orange"
     * - "yellow" or "banana"
     * - "green" or "lime"
     * - "blue" or "blueberry"
     * - "teal" or "mint"
     * - "purple" or "grape"
     * - "pink" or "bubblegum"
     */
    public void prepend_swipe_action (GLib.MenuItem menu_item) {
        new SwipeButton (menu_item).insert_before (this, child);
    }

    /**
    * See prepend_swipe_action for menu item attribute details
    */
    public void append_swipe_action (GLib.MenuItem menu_item) {
        new SwipeButton (menu_item).insert_after (this, child);
    }

    private class SwipeButton : Gtk.Button {
        public SwipeButton (GLib.MenuItem menu_item) {
            var icon_name = menu_item.get_attribute_value ("icon", VariantType.STRING).get_string ();
            if (icon_name == "") {
                icon_name = menu_item.get_attribute_value ("verb-icon", VariantType.STRING).get_string ();
                if (icon_name == "") {
                    icon_name = "dialog-question-symbolic";
                }
            }

            var image = new Gtk.Image.from_icon_name (icon_name);

            var label = new Gtk.Label (
                menu_item.get_attribute_value ("label", VariantType.STRING).get_string ()
            ) {
                ellipsize = END,
                justify = CENTER,
                lines = 2,
                max_width_chars = 10
            };
            label.add_css_class (Granite.CssClass.SMALL);

            var box = new Gtk.Box (VERTICAL, 0) {
                valign = CENTER
            };
            box.append (image);
            box.append (label);

            child = box;

            var css_class = menu_item.get_attribute_value ("css-class", VariantType.STRING);
            if (css_class != null) {
                add_css_class (css_class.get_string ());
            }
        }

        construct {
            add_css_class ("swipe-button");
        }
    }
}
