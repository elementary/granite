/*-
 * Copyright 2016-2022 elementary, Inc. (https://elementary.io)
 * Copyright 2016-2017 Artem Anufrij <artem.anufrij@live.de>
 * Copyright 2016-2017 Daniel Foré <daniel@elementary.io>
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */


/**
 * Toasts are small in-app notifications that provide feedback about an operation
 * in a small popup. They only fill the space required to show the message and do
 * not block the UI.
 *
 * Granite.Widgets.Toast will get the style class .app-notification
 *
 * {{../doc/images/Toast.png}}
 */
public class Granite.Toast : Gtk.Widget {

    /**
     * Emitted when the Toast is closed by activating the close button
     */
    public signal void closed ();

    /**
     * Emitted when the default action button is activated
     */
    public signal void default_action ();

    private Gtk.Revealer revealer;
    private Gtk.Label notification_label;
    private Gtk.Button default_action_button;
    private string _title;
    private uint timeout_id;

    /**
     * The notification text label to be displayed inside of #this
     */
    public string title {
        get {
            return _title;
        }
        construct set {
            if (notification_label != null) {
                notification_label.label = value;
            }
            _title = value;
        }
    }

    /**
     * Creates a new Toast with #title as its title
     */
    public Toast (string title) {
        Object (title: title);
    }

    static construct {
        set_layout_manager_type (typeof (Gtk.BinLayout));
    }

    class construct {
        set_css_name ("toast");
    }

    construct {
        halign = Gtk.Align.CENTER;
        valign = Gtk.Align.START;

        default_action_button = new Gtk.Button () {
            visible = false
        };

        var close_button = new Gtk.Button.from_icon_name ("window-close-symbolic") {
            valign = Gtk.Align.CENTER
        };
        close_button.add_css_class (Granite.STYLE_CLASS_CIRCULAR);

        notification_label = new Gtk.Label (title) {
            wrap = true,
            wrap_mode = Pango.WrapMode.WORD,
            natural_wrap_mode = Gtk.NaturalWrapMode.NONE
        };

        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        box.add_css_class (Granite.STYLE_CLASS_OSD);
        box.append (close_button);
        box.append (notification_label);
        box.append (default_action_button);

        var motion_controller = new Gtk.EventControllerMotion ();

        revealer = new Gtk.Revealer () {
            child = box
        };
        revealer.set_parent (this);

        add_controller (motion_controller);

        close_button.clicked.connect (() => {
            revealer.reveal_child = false;
            stop_timeout ();
            closed ();
        });

        default_action_button.clicked.connect (() => {
            revealer.reveal_child = false;
            stop_timeout ();
            default_action ();
        });

        motion_controller.enter.connect (() => {
            stop_timeout ();
        });

        motion_controller.leave.connect (() => {
            start_timeout ();
        });
    }

    ~Toast () {
        get_first_child ().unparent ();
    }

    private void start_timeout () {
        uint duration;

        if (default_action_button.visible) {
            duration = 3500;
        } else {
            duration = 2000;
        }

        timeout_id = GLib.Timeout.add (duration, () => {
            revealer.reveal_child = false;
            timeout_id = 0;
            return GLib.Source.REMOVE;
        });
    }

    private void stop_timeout () {
        if (timeout_id != 0) {
            Source.remove (timeout_id);
            timeout_id = 0;
        }
    }

    /**
     * Sets the default action button label of #this to #label and hides the
     * button if #label is #null.
     */
    public void set_default_action (string? label) {
        if (label == "" || label == null) {
            default_action_button.visible = false;
        } else {
            default_action_button.visible = true;
        }
        default_action_button.label = label;
    }

    /**
     * Sends the Toast on behalf of #this
     */
    public void send_notification () {
        if (!revealer.child_revealed) {
            revealer.reveal_child = true;
        }

        // Remove any old timeout, including one started by
        // leave_notify_event for the previous notification
        stop_timeout ();
        start_timeout ();
    }

    /**
     * Withdraws the currently displayed Toast
     * @since 7.4.0
     */
    [Version (since = "7.4.0")]
    public void withdraw () {
        stop_timeout ();
        revealer.reveal_child = false;
    }
}
