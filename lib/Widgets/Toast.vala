/*-
 * Copyright 2016-2017 elementary, Inc. (https://elementary.io)
 * Copyright 2016-2017 Artem Anufrij <artem.anufrij@live.de>
 * Copyright 2016-2017 Daniel Foré <daniel@elementary.io>
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

namespace Granite.Widgets {
    /**
     * Toasts are small in-app notifications that provide feedback about an operation
     * in a small popup. They only fill the space required to show the message and do
     * not block the UI.
     *
     * Granite.Widgets.Toast will get the style class .app-notification
     *
     * {{../doc/images/Toast.png}}
     */
    public class Toast : Gtk.Revealer {

        /**
         * Emitted when the Toast is closed by activating the close button
         */
        public signal void closed ();

        /**
         * Emitted when the default action button is activated
         */
        public signal void default_action ();

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

        construct {
            margin = 3;
            halign = Gtk.Align.CENTER;
            valign = Gtk.Align.START;

            default_action_button = new Gtk.Button ();
            default_action_button.visible = false;
            default_action_button.no_show_all = true;
            default_action_button.clicked.connect (() => {
                reveal_child = false;
                stop_timeout ();
                default_action ();
            });

            var close_button = new Gtk.Button.from_icon_name ("window-close-symbolic", Gtk.IconSize.MENU);
            close_button.get_style_context ().add_class ("close-button");
            close_button.clicked.connect (() => {
                reveal_child = false;
                stop_timeout ();
                closed ();
            });

            notification_label = new Gtk.Label (title);

            var notification_box = new Gtk.Grid ();
            notification_box.column_spacing = 12;
            notification_box.add (close_button);
            notification_box.add (notification_label);
            notification_box.add (default_action_button);

            var event_box = new Gtk.EventBox ();
            event_box.events |= Gdk.EventMask.ENTER_NOTIFY_MASK;
            event_box.events |= Gdk.EventMask.LEAVE_NOTIFY_MASK;
            event_box.add (notification_box);

            event_box.enter_notify_event.connect (() => {
                stop_timeout ();
            });

            event_box.leave_notify_event.connect (() => {
                start_timeout ();
            });

            var notification_frame = new Gtk.Frame (null);
            notification_frame.get_style_context ().add_class ("app-notification");
            notification_frame.add (event_box);

            add (notification_frame);
        }

        private void start_timeout () {
            uint duration;

            if (default_action_button.visible) {
                duration = 3500;
            } else {
                duration = 2000;
            }

            timeout_id = GLib.Timeout.add (duration, () => {
                reveal_child = false;
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
                default_action_button.no_show_all = true;
                default_action_button.visible = false;
            } else {
                default_action_button.no_show_all = false;
                default_action_button.visible = true;
            }
            default_action_button.label = label;
        }

        /**
         * Sends the Toast on behalf of #this
         */
        public void send_notification () {
            if (!child_revealed) {
                reveal_child = true;
            }

            // Remove any old timeout, including one started by
            // leave_notify_event for the previous notification
            stop_timeout ();
            start_timeout ();
        }
    }
}
