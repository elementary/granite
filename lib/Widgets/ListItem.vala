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
            }
        }
    }

    class construct {
        set_css_name ("granite-listitem");
        set_layout_manager_type (typeof (Gtk.BinLayout));
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
}
