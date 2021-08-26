/*
 * Copyright 2017 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */


/**
 * HeaderLabel is a start-aligned Gtk.Label with the Granite H4 style class
 */
public class Granite.HeaderLabel : Gtk.Label {

    /**
     * Create a new HeaderLabel
     */
    public HeaderLabel (string label) {
        Object (
            label: label
        );
    }

    construct {
        halign = Gtk.Align.START;
        xalign = 0;
        get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
    }
}
