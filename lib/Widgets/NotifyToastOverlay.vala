/*
 * Copyright 2012–2025 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class Granite.NotifyToastOverlay : Gtk.Widget {
    private Gtk.Overlay overlay;

    private Gtk.Widget? _child;
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
                overlay.child = _child;
            }
        }
    }

    private Gee.HashMap<NotifyToastPosition, Gtk.Box> position_map;

    public NotifyToastOverlay () {
        Object (
            hexpand: true,
            vexpand: true
        );
    }

    class construct {
        set_layout_manager_type (typeof (Gtk.BinLayout));
    }

    construct {
        position_map = new Gee.HashMap<NotifyToastPosition, Gtk.Box> ();

        position_map[NotifyToastPosition.TOP_LEFT] = new Gtk.Box (VERTICAL, 6) {
            halign = START,
            valign = START,
        };

        position_map[NotifyToastPosition.TOP_CENTER] = new Gtk.Box (VERTICAL, 6) {
            halign = CENTER,
            valign = START,
        };

        position_map[NotifyToastPosition.TOP_RIGHT] = new Gtk.Box (VERTICAL, 6) {
            halign = END,
            valign = START,
        };

        position_map[NotifyToastPosition.BOTTOM_LEFT] = new Gtk.Box (VERTICAL, 6) {
            halign = START,
            valign = END,
        };

        position_map[NotifyToastPosition.BOTTOM_CENTER] = new Gtk.Box (VERTICAL, 6) {
            halign = CENTER,
            valign = END,
        };

        position_map[NotifyToastPosition.BOTTOM_RIGHT] = new Gtk.Box (VERTICAL, 6) {
            halign = END,
            valign = END,
        };

        overlay = new Gtk.Overlay ();
        overlay.set_parent (this);
        overlay.add_overlay (position_map[NotifyToastPosition.TOP_LEFT]);
        overlay.add_overlay (position_map[NotifyToastPosition.TOP_CENTER]);
        overlay.add_overlay (position_map[NotifyToastPosition.TOP_RIGHT]);
        overlay.add_overlay (position_map[NotifyToastPosition.BOTTOM_LEFT]);
        overlay.add_overlay (position_map[NotifyToastPosition.BOTTOM_CENTER]);
        overlay.add_overlay (position_map[NotifyToastPosition.BOTTOM_RIGHT]);
    }

    public void add_toast (NotifyToast toast) {
        var notification = new NotifyToastWidget (toast);
        position_map[toast.position].append (notification);
    }

    private class NotifyToastWidget : Granite.Bin {
        public NotifyToast toast { get; construct; }

        private Gtk.Label notification_label;
        private Gtk.Button default_action_button;
        private Gtk.Revealer revealer;

        private uint timeout_id;

        public NotifyToastWidget (NotifyToast toast) {
            Object (
                toast: toast
            );
        }

        construct {
            default_action_button = new Gtk.Button () {
                visible = false
            };
    
            var close_button = new Gtk.Button.from_icon_name ("window-close-symbolic") {
                valign = Gtk.Align.CENTER
            };
            close_button.add_css_class (Granite.STYLE_CLASS_CIRCULAR);
    
            notification_label = new Gtk.Label (toast.title) {
                wrap = true,
                wrap_mode = Pango.WrapMode.WORD,
                natural_wrap_mode = Gtk.NaturalWrapMode.NONE
            };
    
            var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            box.add_css_class (Granite.STYLE_CLASS_OSD);
            box.append (close_button);
            box.append (notification_label);
            box.append (default_action_button);
        
            revealer = new Gtk.Revealer () {
                child = box
            };

            child = revealer;

            Timeout.add (revealer.transition_duration, () => {
                revealer.reveal_child = true;
                //  start_timeout ();
                return GLib.Source.REMOVE;
            });
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
                //  dismissed (DismissReason.EXPIRED);
                timeout_id = 0;
                return GLib.Source.REMOVE;
            });
        }
    }
}