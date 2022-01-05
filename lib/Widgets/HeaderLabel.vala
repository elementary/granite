/*
 * Copyright 2017-2022 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */


/**
 * HeaderLabel is a start-aligned {@link Gtk.Label} with the Granite H4 style class
 */
public class Granite.HeaderLabel : Gtk.Box {
    public string label { get; construct set; }

    /**
     * Create a new HeaderLabel
     */
    public HeaderLabel (string label) {
        Object (label: label);
    }

    construct {
        var label_widget = new Gtk.Label (label) {
            xalign = 0
        };
        label_widget.add_css_class (Granite.STYLE_CLASS_H4_LABEL);

        append (label_widget);
        halign = Gtk.Align.START;

        bind_property ("label", label_widget, "label");
    }
}
