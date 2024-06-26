/*
 * Copyright 2017-2022 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */


/**
 * HeaderLabel contains a start-aligned {@link Gtk.Label} with the "heading" style class.
 * Optionally it can contain a secondary {@link Gtk.Label} to provide additional context
 */
public class Granite.HeaderLabel : Gtk.Widget {
    /**
     * The primary header label string
     */
    public string label { get; construct set; }

    /**
     * The widget to be activated when the labels mnemonic key is pressed. Also sets #this as screenreader label.
     */
    [Version (since = "7.4.0")]
    public Gtk.Widget? mnemonic_widget { get; set; }

    private Gtk.Label? secondary_label = null;
    /**
     * Optional secondary label string displayed below the header
     */
    [Version (since = "7.1.0")]
    public string? secondary_text {
        get {
            return secondary_label != null ? secondary_label.label : null;
        }
        set {
            if (secondary_label != null) {
                if (value == null || value == "") {
                    secondary_label.unparent ();
                    secondary_label = null;
                } else {
                    secondary_label.label = value;
                }
            } else if (value != null) {
                secondary_label = new Gtk.Label (value) {
                    use_markup = true,
                    wrap = true,
                    xalign = 0
                };
                secondary_label.add_css_class (Granite.STYLE_CLASS_DIM_LABEL);
                secondary_label.add_css_class (Granite.STYLE_CLASS_SMALL_LABEL);

                secondary_label.set_parent (this);
            }

            update_accessible_description (value);
        }
    }

    /**
     * Create a new HeaderLabel
     */
    public HeaderLabel (string label) {
        Object (label: label);
    }

    class construct {
        set_css_name ("header");
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }

    construct {
        var label_widget = new Gtk.Label (label) {
            wrap = true,
            xalign = 0
        };
        label_widget.add_css_class ("heading");
        label_widget.set_parent (this);

        ((Gtk.BoxLayout) get_layout_manager ()).orientation = Gtk.Orientation.VERTICAL;

        bind_property ("label", label_widget, "label");
        bind_property ("mnemonic-widget", label_widget, "mnemonic-widget");

        notify["mnemonic-widget"].connect (() => {
            update_accessible_description (secondary_text);
        });
    }

    private void update_accessible_description (string? description) {
        if (mnemonic_widget != null) {
            mnemonic_widget.update_property (Gtk.AccessibleProperty.DESCRIPTION, description, -1);
        }
    }

    ~HeaderLabel () {
        while (get_first_child () != null) {
            get_first_child ().unparent ();
        }
    }
}
