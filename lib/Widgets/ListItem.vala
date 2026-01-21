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
