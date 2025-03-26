/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

/**
 *
 *
 * @since 7.7.0
 */
[Version (since = "7.7.0")]
public class Granite.ToolbarView : Gtk.Widget, Gtk.Accessible {
    private Gtk.Widget _content;
    /**
     * The child widget for the content area
     */
    public Gtk.Widget content {
        get {
            return _content;
        }

        set {
            return_if_fail (content == null);
            return_if_fail (content.parent == null);

            _content = value;
            _content.insert_after (this, top_handle);
        }
    }

    private Gtk.Box bottom_box;
    private Gtk.Box top_box;
    private Gtk.WindowHandle top_handle;

    class construct {
        set_css_name ("toolbarview");
        set_accessible_role (GROUP);
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }

    construct {
        var layout_manager = (Gtk.BoxLayout) get_layout_manager ();
        layout_manager.orientation = VERTICAL;

        top_box = new Gtk.Box (VERTICAL, 0);
        top_box.add_css_class ("top");

        top_handle = new Gtk.WindowHandle () {
            child = top_box
        };

        bottom_box = new Gtk.Box (VERTICAL, 0);
        bottom_box.add_css_class ("bottom");

        var bottom_handle = new Gtk.WindowHandle () {
            child = bottom_box
        };

        top_handle.set_parent (this);
        bottom_handle.insert_after (this, top_handle);
    }

    ~ToolbarView () {
        while (get_first_child () != null) {
            get_first_child ().unparent ();
        }
    }

    public void add_top_bar (Gtk.Widget widget) {
        return_if_fail (widget.parent == null);

        top_box.append (widget);
    }

    public void add_bottom_bar (Gtk.Widget widget) {
        return_if_fail (widget.parent == null);

        bottom_box.append (widget);
    }

    public void remove (Gtk.Widget widget) {
        var parent = widget.get_parent ();
        if (parent == top_box || parent == bottom_box) {
            ((Gtk.Box) parent).remove (widget);
            return;
        }

        if (widget == content) {
            widget.unparent ();
        }
    }
}
