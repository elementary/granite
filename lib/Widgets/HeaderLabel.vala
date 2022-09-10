/*
 * Copyright 2017-2022 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */


/**
 * HeaderLabel is a start-aligned {@link Gtk.Label} with the Granite H4 style class
 */
public class Granite.HeaderLabel : Gtk.Widget {
    /**
     * The primary header label string
     */
    public string label { get; construct set; }

    /**
     * Optional secondary label string displayed below the header
     */
    public string? secondary_text {
        get; construct set; default = null; 
    }

    /**
     * Create a new HeaderLabel
     */
    public HeaderLabel (string label, string? secondary_text = null) {
        Object (
            secondary_text: secondary_text,
            label: label
        );
    }

    class construct {
        set_css_name ("header");
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }

    construct {
        var label_widget = new Gtk.Label (label) {
            xalign = 0
        };
        label_widget.add_css_class ("heading");
        label_widget.set_parent (this);

        var secondary_label = new Gtk.Label (secondary_text) {
            wrap = true,
            xalign = 0
        };
        secondary_label.add_css_class (Granite.STYLE_CLASS_DIM_LABEL);
        secondary_label.add_css_class (Granite.STYLE_CLASS_SMALL_LABEL);

        halign = Gtk.Align.START;
        ((Gtk.BoxLayout) get_layout_manager ()).orientation = Gtk.Orientation.VERTICAL;

        bind_property ("label", label_widget, "label");

        notify["secondary-text"].connect (() => {
            secondary_label.label = secondary_text;

            if (secondary_text == null || secondary_text == "") {
                secondary_label.unparent ();
            } else if (secondary_label.parent == null) {
                secondary_label.set_parent (this);
            }
        });
    }

    ~HeaderLabel () {
        while (get_first_child () != null) {
            get_first_child ().unparent ();
        }
    }
}
