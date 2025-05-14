/*
 * Copyright 2024 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

/**
 * This widget is a simple container that can hold a single child widget.
 * It is mostly useful for deriving subclasses.
 *
 * @since 7.6.0
 */
[Version (since = "7.6.0")]
public class Granite.Bin : Gtk.Widget {
    class construct {
        set_layout_manager_type (typeof (Gtk.BinLayout));
    }

    private Gtk.Widget? _child;
    /**
     * The child widget of the bin.
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

    ~Bin () {
        if (child != null) {
            child.unparent ();
        }
    }
}
