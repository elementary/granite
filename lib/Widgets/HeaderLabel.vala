/*
 * Copyright 2017-2022 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */


/**
 * HeaderLabel is a start-aligned {@link Gtk.Label} with the Granite H4 style class
 */
public class Granite.HeaderLabel : Gtk.Widget {

    public string label { get; construct set; }

    public string? body {
        get; construct set; default = null; 
    }

    /**
     * Create a new HeaderLabel
     */
    public HeaderLabel (string label, string? body = null) {
        Object (
            body: body,
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
        label_widget.add_css_class (Granite.STYLE_CLASS_H4_LABEL);
        label_widget.set_parent (this);

        var body_label = new Gtk.Label (body) {
            wrap = true,
            xalign = 0
        };
        body_label.add_css_class (Granite.STYLE_CLASS_DIM_LABEL);
        body_label.add_css_class (Granite.STYLE_CLASS_SMALL_LABEL);

        halign = Gtk.Align.START;
        ((Gtk.BoxLayout) get_layout_manager ()).orientation = Gtk.Orientation.VERTICAL;

        bind_property ("label", label_widget, "label");

        notify["body"].connect (() => {
            body_label.label = body;

            if (body == null || body == "") {
                body_label.unparent ();
            } else if (body_label.parent == null) {
                body_label.set_parent (this);
            }
        });
    }

    ~HeaderLabel () {
        while (get_first_child () != null) {
            get_first_child ().unparent ();
        }
    }
}
