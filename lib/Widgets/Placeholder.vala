/*
 * Copyright 2022 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class Granite.Placeholder : Gtk.Box {
    /**
     * The primary text for the placeholder
     */
    public string title { get; construct set; }

    /**
     * The description text for the placeholder
     */
    public string description { get; set; }

    /**
     * The icon for the placeholder
     */
    public Icon icon { get; set; }

    private Gtk.Box buttonbox;

    public Placeholder (string title) {
        Object (title: title);
    }

    class construct {
        set_css_name ("placeholder");
    }

    construct {
        var image = new Gtk.Image () {
            icon_size = Gtk.IconSize.LARGE,
            valign = Gtk.Align.START
        };

        var title_label = new Gtk.Label (title) {
            max_width_chars = 30,
            wrap = true,
            xalign = 0
        };
        title_label.add_css_class (Granite.STYLE_CLASS_H1_LABEL);

        var description_label = new Gtk.Label ("") {
            max_width_chars = 45,
            wrap = true,
            use_markup = true,
            xalign = 0
        };
        description_label.add_css_class (Granite.STYLE_CLASS_H2_LABEL);

        buttonbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
            visible = false
        };

        var grid = new Gtk.Grid ();
        grid.attach (image, 0, 0, 1, 2);
        grid.attach (title_label, 1, 0);
        grid.attach (description_label, 1, 1);
        grid.attach (buttonbox, 1, 2);

        halign = Gtk.Align.CENTER;
        valign = Gtk.Align.CENTER;
        hexpand = true;
        append (grid);

        bind_property ("title", title_label, "label");
        bind_property ("description", description_label, "label");
        bind_property (
            "description", description_label, "visible", BindingFlags.SYNC_CREATE | BindingFlags.DEFAULT,
            (binding, srcval, ref targetval) => {
                var label = (string) srcval;
                if (label != null) {
                    targetval.set_boolean (true);
                } else {
                    targetval.set_boolean (false);
                }

                return true;
            },
            null
        );

        bind_property ("icon", image, "gicon");
        bind_property (
            "icon", image, "visible", BindingFlags.SYNC_CREATE | BindingFlags.DEFAULT,
            (binding, srcval, ref targetval) => {
                var gicon = (Icon) srcval;
                if (gicon != null) {
                    targetval.set_boolean (true);
                } else {
                    targetval.set_boolean (false);
                }

                return true;
            },
            null
        );
    }

    public Gtk.Button append_button (Icon icon, string label, string description) {
        var image = new Gtk.Image.from_gicon (icon) {
            icon_size = Gtk.IconSize.LARGE
        };

        var label_widget = new Gtk.Label (label) {
            wrap = true,
            xalign = 0
        };
        label_widget.add_css_class (Granite.STYLE_CLASS_H3_LABEL);

        var description_widget = new Gtk.Label (description) {
            wrap = true,
            xalign = 0
        };

        var grid = new Gtk.Grid ();
        grid.attach (image, 0, 0, 1, 2);
        grid.attach (label_widget, 1, 0);
        grid.attach (description_widget, 1, 1);

        var button = new Gtk.Button () {
            child = grid
        };

        buttonbox.append (button);
        buttonbox.show ();

        return button;
    }
}
