/*
 * Copyright 2026 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class Granite.Avatar : Gtk.Widget {
    // The text used for accessibility and to generate the fallback initials and color
    public string text { get; construct set; }

    // Whether the avatar has a frame.
    public bool has_frame { get; set; default = false; }

    // The paintable to use as the avatar image
    public Gdk.Paintable paintable { get; set; default = null; }

    // The name of an icon to use as a fallback.
    public string fallback_icon { get; set; default = "avatar-default-symbolic";}

    // The size of the avatar in pixels
    public int pixel_size { get; set; default = 32; }

    private Gtk.Image image;
    private Gtk.Label label;
    private const int NUMBER_OF_COLORS = 11;

    public Avatar (string text) {
        Object (text: text);
    }

    class construct {
        set_css_name ("avatar");
        set_layout_manager_type (typeof (Gtk.BinLayout));
    }

    construct {
        image = new Gtk.Image ();

        label = new Gtk.Label ("");

        var stack = new Gtk.Stack () {
            transition_type = CROSSFADE
        };
        stack.add_child (image);
        stack.add_child (label);

        stack.set_parent (this);

        halign = CENTER;
        valign = CENTER;

        bind_property ("paintable", stack, "visible-child", SYNC_CREATE, paintable_to_stack_child);

        bind_property ("pixel-size", this, "height-request", SYNC_CREATE);
        bind_property ("pixel-size", this, "width-request", SYNC_CREATE);

        bind_property ("text", this, "tooltip-text", SYNC_CREATE);
        bind_property ("text", label, "label", SYNC_CREATE, text_to_initials);

        update_a11y ();
        update_css_classes ();
        notify["text"].connect (() => {
            update_css_classes ();
            update_a11y ();
        });

        notify["has-frame"].connect (update_css_classes);
    }

    ~Avatar () {
        if (get_first_child () != null) {
            get_first_child ().unparent ();
        }

        paintable = null;
    }

    private bool paintable_to_stack_child (Binding binding, Value from_value, ref Value to_value) {
        if ((Gdk.Paintable) from_value != null) {
            to_value.set_object (image);
        } else {
            to_value.set_object (label);
        }

        return true;
    }

    private bool text_to_initials (Binding binding, Value from_value, ref Value to_value) {
        if ((string) from_value == "") {
            to_value.set_string ("");
            return true;
        }

        var names = ((string) from_value).split (" ");

        string initials;
        if (names[0].length > 1) {
            initials = names[0].substring (0, 1).up ();
        } else {
            initials = names[0];
        }

        if (names.length > 1) {
            initials += names[names.length - 1].substring (0, 1).up ();
        }

        to_value.set_string (initials);

        return true;
    }

    private void update_css_classes () {
        css_classes = {""};

        if (has_frame) {
            add_css_class ("frame");
        }

        var accent_color = Granite.AccentColor.AUTOMATIC;
        if (text != "") {
            accent_color = (Granite.AccentColor) ((GLib.str_hash (text) % NUMBER_OF_COLORS) + 1);
        }

        add_css_class (accent_color.to_css_class ());
    }

    private void update_a11y () {
        if (text != "") {
            update_property (
                Gtk.AccessibleProperty.LABEL,
                /// TRANSLATORS: accessible label for an avatar. The variable is a name of the person the avatar refers to
                _("Avatar for %s").printf (text),
                -1
            );
        } else {
            update_property (Gtk.AccessibleProperty.LABEL, null, -1);
        }
    }
}
