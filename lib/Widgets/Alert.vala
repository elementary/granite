/*
 * Copyright 2026 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

/**
 * Provide contextual feedback messages and actions
 *
 * @since 9.0.0
 */
[Version (since = "9.0.0")]
public class Granite.Alert : Gtk.Widget {
    /**
     * The type of message being displayed
     */
    public enum MessageType {
        INFO,
        WARNING,
        ERROR,
        OTHER;

        public string to_css_class () {
            switch (this) {
                case INFO:
                    return "info";
                case WARNING:
                    return CssClass.WARNING;
                case ERROR:
                    return CssClass.ERROR;
                default:
                    return "";
            }
        }

        public string to_icon_name () {
            switch (this) {
                case INFO:
                    return "dialog-information";
                case WARNING:
                    return "dialog-warning";
                case ERROR:
                    return "dialog-error";
                default:
                    return "image-missing";
            }
        }
    }

    /**
     * The primary label string
     */
    public string label { get; construct set; }

    /**
     * Optional secondary label string displayed below the label
     */
    public string? description { get; set; }

    /**
     * The icon name used by the image in #this
     */
    public string icon_name { get; set; }

    /**
     * Whether #this is currently revealed
     */
    public bool revealed { get; set; }

    private MessageType _message_type = INFO;
    /**
     * The type of message being displayed in #this
     *
     * When MessageType is OTHER, add_css_class with Granite.AccentColor
     */
    public MessageType message_type {
        get {
            return _message_type;
        }
        set {
            if (has_css_class (_message_type.to_css_class ())) {
                remove_css_class (_message_type.to_css_class ());
            }

            _message_type = value;

            if (value.to_css_class () != "") {
                add_css_class (value.to_css_class ());
            }
        }
    }

    private Gtk.Image image;

    /**
     * Constructs a new {@link Granite.Alert}
     */
    public Alert (string label) {
        Object (label: label);
    }

    class construct {
        set_accessible_role (BANNER);
        set_css_name ("granite-alert");
        set_layout_manager_type (typeof (Gtk.BoxLayout));
    }

    construct {
        ((Gtk.BoxLayout) get_layout_manager ()).orientation = Gtk.Orientation.HORIZONTAL;

        image = new Gtk.Image ();
        image.set_parent (this);

        var label_widget = new Granite.HeaderLabel (label) {
            mnemonic_widget = this
        };
        label_widget.set_parent (this);

        focusable = true;

        bind_property ("description", label_widget, "secondary-text");
        bind_property ("label", label_widget, "label");
        bind_property ("message-type", image, "icon-name", SYNC_CREATE, messagetype_to_iconname);
        bind_property ("icon-name", image, "icon-name", BIDIRECTIONAL);
    }

    private bool messagetype_to_iconname (Binding binding, Value from_value, ref Value to_value) {
        var icon_name = ((MessageType) from_value).to_icon_name ();
        if (icon_name != "") {
            to_value.set_string (icon_name);
            return true;
        }

        return false;
    }
}
