/*
 * Copyright 2017-2022 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */


/**
 * HeaderLabel contains a start-aligned {@link Gtk.Label} with the "heading" style class.
 * Optionally it can contain a secondary {@link Gtk.Label} to provide additional context
 */
public class Granite.HeaderLabel : Gtk.Widget {
    [Version (since = "7.7.0")]
    public enum Size {
        H1,
        H2,
        H3,
        H4;

        public string to_string () {
            switch (this) {
                case H1:
                    return "title-1";
                case H2:
                    return "title-2";
                case H3:
                    return "title-3";
                case H4:
                    return "title-4";
            }

            return "";
        }
    }

    /**
     * The primary header label string
     */
    public string label { get; construct set; }

    /**
     * The widget to be activated when the labels mnemonic key is pressed. Also sets #this as screenreader label.
     */
    [Version (since = "7.4.0")]
    public Gtk.Widget? mnemonic_widget { get; set; }

    /**
     * The size of #this
     * Only use one {@link Size.H1} per page. It represents the main heading/subject for the whole page
     */
    [Version (since = "7.7.0")]
    public Size size { get; set; default = H4; }

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
                secondary_label.add_css_class ("subtitle");

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

        update_size ();
        notify["size"].connect (update_size);
    }

    private void update_size () {
        unowned var enum_class = (EnumClass) typeof (Size).class_peek ();
        foreach (unowned var val in enum_class.values) {
            var css_class = ((Size) val.value).to_string ();
            if (css_class != "" && has_css_class (css_class)) {
                remove_css_class (css_class);
            }
        }

        add_css_class (size.to_string ());
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
