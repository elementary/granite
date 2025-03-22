/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

/**
 * A {@link Gtk.BoxLayout} that has built-in properties for child spacing
 *
 * @since 7.7.0
 */
[Version (since = "7.7.0")]
public class Granite.Box : Gtk.Widget, Gtk.Accessible, Gtk.Buildable, Gtk.ConstraintTarget, Gtk.Orientable {
    public enum Spacing {
        NONE,
        SINGLE,
        DOUBLE,
        LINKED;

        public string to_string () {
            switch (this) {
                case SINGLE:
                    return "border-spacing-single";
                case DOUBLE:
                    return "border-spacing-double";
                case LINKED:
                    return "linked";
                default:
                    return "";
            }
        }
    }

    /**
     * The baseline child of a box.
     *
     * This only affects vertical boxes.
     */
    public int baseline_child {
        get {
            return  layout_manager.baseline_child;
        }

        set {
            layout_manager.baseline_child = value;
        }
    }

    /**
     * Sets the baseline position of a box.
     *
     * This only affects horizontal boxes with at least one baseline
     * aligned child. If there is more vertical space available than
     * requested, and the baseline is not allocated by the parent then
     * @position is used to allocate the baseline with respect to the
     * extra space available.
     */
    public Gtk.BaselinePosition baseline_position {
        get {
            return  layout_manager.baseline_position;
        }

        set {
            layout_manager.baseline_position = value;
        }
    }

    /**
     * How far apart to space children of #this
     */
    public Spacing child_spacing { get; construct set; }

    /**
     * Whether or not all children are given equal space
     * in the box.
     */
    public bool homogeneous {
        get {
            return  layout_manager.homogeneous;
        }

        set {
            layout_manager.homogeneous = value;
        }
    }

    /**
     * Whether the box is a row or a column
     */
    public Gtk.Orientation orientation {
        get {
            return  layout_manager.orientation;
        }

        set {
            layout_manager.orientation = value;
        }
    }

    private Gtk.BoxLayout layout_manager;

    /**
     * Constructs a new {@link Granite.Box}
     */
    public Box (Gtk.Orientation orientation, Spacing child_spacing = SINGLE) {
        Object (
            orientation: orientation,
            child_spacing: child_spacing
        );
    }

    class construct {
        set_css_name ("box");
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }

    construct {
        layout_manager = (Gtk.BoxLayout) get_layout_manager ();
        update_child_spacing ();
        notify["child-spacing"].connect (update_child_spacing);
    }

    ~Box () {
        while (get_first_child () != null) {
            get_first_child ().unparent ();
        }
    }

    /**
     * Adds a child at the end.
     */
    public void append (Gtk.Widget widget) {
        return_if_fail (widget.parent == null);

        insert_before (widget, null);
    }

    /**
     * Adds a child at the beginning.
     */
    public void prepend (Gtk.Widget widget) {
        return_if_fail (widget.parent == null);

        insert_after (widget, null);
    }

    /**
     * Removes a child widget from the box.
     */
    public void remove (Gtk.Widget widget) {
        return_if_fail (widget.parent == this);

        widget.unparent ();
    }

    private void update_child_spacing () {
        unowned var enum_class = (EnumClass) typeof (Spacing).class_peek ();
        foreach (unowned var val in enum_class.values) {
            var css_class = ((Spacing) val.value).to_string ();
            if (css_class != "" && has_css_class (css_class)) {
                remove_css_class (css_class);
            }
        }

        add_css_class (child_spacing.to_string ());
    }
}
