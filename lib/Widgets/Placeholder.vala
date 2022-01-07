/*
 * Copyright 2022 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

/**
 * Placeholder is used to provide further information in an empty view such as a {@link Gtk.ListBox} or when onboarding.
 *
 * ''Example''<<BR>>
 * {{{
 *   var alert = new Granite.Placeholder ("Panic! At the Button") {
 *       description = "Maybe you can <b>do something</b> to hide it but <i>otherwise</i> it will stay here",
 *       icon = new ThemedIcon ("dialog-warning")
 *   };
 *
 *   var alert_action = alert.append_button (
 *       new ThemedIcon ("edit-delete"),
 *       "Hide This Button",
 *       "Click here to hide this"
 *   );
 * }}}
 */
public class Granite.Placeholder : Gtk.Widget {
    /**
     * The {@link string} to use for the primary text
     */
    public string title { get; construct set; }

    /**
     * The {@link string} to use for description text
     */
    public string description { get; set; }

    /**
     * The {@link GLib.Icon} to use as the primary icon
     */
    public Icon icon { get; set; }

    private Gtk.Box buttonbox;

    /**
     * Constructs a new {@link Granite.Placeholder} with title text only.
     *
     * @param title The {@link string} to use for the primary text
     */
    public Placeholder (string title) {
        Object (title: title);
    }

    class construct {
        set_css_name ("placeholder");
        set_layout_manager_type (typeof (Gtk.BinLayout));
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
        grid.set_parent (this);

        halign = Gtk.Align.CENTER;
        valign = Gtk.Align.CENTER;
        hexpand = true;

        bind_property ("title", title_label, "label");
        bind_property ("description", description_label, "label");
        bind_property (
            "description", description_label, "visible", BindingFlags.SYNC_CREATE | BindingFlags.DEFAULT,
            (binding, srcval, ref targetval) => {
                targetval.set_boolean ((string) srcval != null && (string) srcval != "");
                return true;
            },
            null
        );

        bind_property ("icon", image, "gicon");
        bind_property (
            "icon", image, "visible", BindingFlags.SYNC_CREATE | BindingFlags.DEFAULT,
            (binding, srcval, ref targetval) => {
                targetval.set_boolean ((Icon) srcval != null);
                return true;
            },
            null
        );
    }

    ~Placeholder () {
        get_first_child ().unparent ();
    }

    /**
     * Appends new {@link Gtk.Button} to the placeholder's action area
     *
     * @param icon the {@link GLib.Icon} that describes this action
     * @param label a {@link string} to use as the title for this action. It should use Title Case.
     * @param description a {@link string} to use as a description for this action. It should use sentence case.
     * @return a {@link Gtk.Button} representing this action
     */
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
