/*
 * Copyright 2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

/**
 * A {@link Gtk.Box} subclass that has built-in properties for child spacing
 *
 * @since 7.7.0
 */
[Version (since = "7.7.0")]
public class Granite.Box : Gtk.Box {
    public enum ChildSpacing {
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
     * How far apart to space children of #this
     */
    public ChildSpacing child_spacing { get; construct set; }

    /**
     * Constructs a new {@link Granite.Box}
     */
    public Box (Gtk.Orientation orientation, ChildSpacing child_spacing = SINGLE) {
        Object (
            orientation: orientation,
            child_spacing: child_spacing
        );
    }

    construct {
        update_child_spacing ();
        notify["child-spacing"].connect (update_child_spacing);
    }

    private void update_child_spacing () {
        string[] css_classes = {
            ChildSpacing.SINGLE.to_string (),
            ChildSpacing.DOUBLE.to_string (),
            ChildSpacing.LINKED.to_string (),
        };

        foreach (unowned var css_class in css_classes) {
            if (has_css_class (css_class)) {
                remove_css_class (css_class);
            }
        }

        add_css_class (child_spacing.to_string ());
    }
}
