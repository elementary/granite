/*
 * Copyright 2018–2022 elementary, Inc. (https://elementary.io)
 * Copyright 2011–2013 Maxwell Barvian <maxwell@elementaryos.org>
 * Copyright 2011–2013 Corentin Noël <tintou@noel.tf>
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

/**
 * This widget allows users to easily pick a time.
 */
public class Granite.TimePicker : Gtk.Entry {
    /**
     * Sent when the time got changed
     */
    public signal void time_changed ();

    /**
     * Format used in 12h mode
     */
    public string format_12 { get; construct; }

    /**
     * Format used in 24h mode
     */
    public string format_24 { get; construct; }

    private GLib.DateTime _time = null;
    /**
     * Current time
     */
    public GLib.DateTime time {
        get {
            if (_time == null) {
                time = new GLib.DateTime.now_local ();
            }

            return _time;
        }

        set {
            _time = value;
            changing_time = true;

            if (_time.get_hour () >= 12) {
                pm_togglebutton.active = true;
            } else {
                am_togglebutton.active = true;
            }

            update_text (true);
            changing_time = false;
        }

    }

    private bool changing_time = false;
    private string old_string = "";
    private Gtk.Box am_pm_box;
    private Gtk.Popover popover;
    private Gtk.SpinButton hours_spinbutton;
    private Gtk.SpinButton minutes_spinbutton;
    private Gtk.ToggleButton am_togglebutton;
    private Gtk.ToggleButton pm_togglebutton;

    /**
     * Creates a new TimePicker.
     *
     * @param format_12 The desired custom 12h format. For example "%l:%M %p".
     * @param format_24 The desired custom 24h format. For example "%H:%M".
     */
    public TimePicker.with_format (string format_12, string format_24) {
        Object (format_12: format_12, format_24: format_24);
    }

    static construct {
        Granite.init ();
    }

    construct {
        if (format_12 == null) {
            format_12 = Granite.DateTime.get_default_time_format (true);
        }

        if (format_24 == null) {
            format_24 = Granite.DateTime.get_default_time_format (false);
        }

        max_length = 8;
        primary_icon_gicon = new ThemedIcon.with_default_fallbacks ("appointment-symbolic");
        secondary_icon_gicon = new ThemedIcon.with_default_fallbacks ("pan-down-symbolic");
        icon_release.connect (on_icon_press);

        /// TRANSLATORS: this will only show up when 12-hours clock is in use
        am_togglebutton = new Gtk.ToggleButton.with_label (_("AM")) {
            vexpand = true
        };

        /// TRANSLATORS: this will only show up when 12-hours clock is in use
        pm_togglebutton = new Gtk.ToggleButton.with_label (_("PM")) {
            group = am_togglebutton,
            vexpand = true
        };

        am_pm_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        am_pm_box.add_css_class (Granite.STYLE_CLASS_LINKED);
        am_pm_box.append (am_togglebutton);
        am_pm_box.append (pm_togglebutton);

        if (Granite.DateTime.is_clock_format_12h ()) {
            hours_spinbutton = new Gtk.SpinButton.with_range (1, 12, 1);
        } else {
            hours_spinbutton = new Gtk.SpinButton.with_range (0, 23, 1);
        }

        hours_spinbutton.orientation = Gtk.Orientation.VERTICAL;
        hours_spinbutton.wrap = true;
        hours_spinbutton.value_changed.connect (() => update_time (true));

        minutes_spinbutton = new Gtk.SpinButton.with_range (0, 59, 1);
        minutes_spinbutton.orientation = Gtk.Orientation.VERTICAL;
        minutes_spinbutton.wrap = true;
        minutes_spinbutton.value_changed.connect (() => update_time (false));

        // If the spinbutton value is less than 10, append zero in front of value. '6' becomes '06'
        minutes_spinbutton.output.connect (() => {
            var val = minutes_spinbutton.get_value ();
            if (val < 10) {
                minutes_spinbutton.set_text ("0" + val.to_string ());
                return true;
            }

            return false;
        });

        /// TRANSLATORS: separates hours from minutes.
        var separation_label = new Gtk.Label (_(":"));

        var pop_grid = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        pop_grid.append (hours_spinbutton);
        pop_grid.append (separation_label);
        pop_grid.append (minutes_spinbutton);
        pop_grid.append (am_pm_box);

        popover = new Gtk.Popover () {
            halign = Gtk.Align.END,
            autohide = true,
            child = pop_grid,
            has_arrow = false,
            position = Gtk.PositionType.BOTTOM
        };
        popover.set_parent (this);

        add_css_class ("time-picker");

        // Connecting to events allowing manual changes
        var focus_controller = new Gtk.EventControllerFocus ();
        var scroll_controller = new Gtk.EventControllerScroll (
            Gtk.EventControllerScrollFlags.BOTH_AXES |
            Gtk.EventControllerScrollFlags.DISCRETE
        );

        add_controller (focus_controller);
        add_controller (scroll_controller);

        focus_controller.leave.connect (() => {
            is_unfocused ();
        });

        scroll_controller.scroll.connect ((dx, dy) => {
            double largest = dx.abs () > dy.abs () ? dx : dy;
            if (largest < 0) {
                _time = _time.add_minutes (1);
            } else {
                _time = _time.add_minutes (-1);
            }

            update_text ();
            return false;
        });

        activate.connect (is_unfocused);

        am_togglebutton.clicked.connect (() => {
            update_am_pm (-12);
        });

        pm_togglebutton.clicked.connect (() => {
            update_am_pm (12);
        });

        update_text ();
    }

    private void update_am_pm (int hours) {
        if (changing_time) {
            return;
        }

        time = _time.add_hours (hours);
        time_changed ();

        update_text (true);
    }

    private void update_time (bool is_hour) {
        if (changing_time) {
            return;
        }

        if (is_hour) {
            var new_hour = hours_spinbutton.get_value_as_int () - time.get_hour ();

            if (Granite.DateTime.is_clock_format_12h ()) {
                if (hours_spinbutton.get_value_as_int () == 12 && am_togglebutton.active = true) {
                    _time = _time.add_hours (-_time.get_hour ());
                } else if (hours_spinbutton.get_value_as_int () < 12 && am_togglebutton.active = true) {
                    _time = _time.add_hours (new_hour);
                } else if (hours_spinbutton.get_value_as_int () == 12 && pm_togglebutton.active = true) {
                    _time = _time.add_hours (-_time.get_hour () + 12);
                } else if (hours_spinbutton.get_value_as_int () < 12 && pm_togglebutton.active = true) {
                    _time = _time.add_hours (new_hour + 12);

                    if (time.get_hour () <= 12) {
                        _time = _time.add_hours (12);
                    }
                }
            } else {
                _time = _time.add_hours (new_hour);
            }
        } else {
            _time = time.add_minutes (minutes_spinbutton.get_value_as_int () - time.get_minute ());
        }

        update_text ();
    }

    private void on_icon_press (Gtk.EntryIconPosition position) {
        // If the mode is changed from 12h to 24h or visa versa, the entry updates on icon press
        update_text ();
        changing_time = true;

        if (Granite.DateTime.is_clock_format_12h () && time.get_hour () > 12) {
            hours_spinbutton.set_value (time.get_hour () - 12);
        } else {
            hours_spinbutton.set_value (time.get_hour ());
        }

        if (Granite.DateTime.is_clock_format_12h ()) {
            am_pm_box.show ();

            if (time.get_hour () > 12) {
                hours_spinbutton.set_value (time.get_hour () - 12);
            } else if (time.get_hour () == 0) {
                hours_spinbutton.set_value (12);
            } else {
                hours_spinbutton.set_value (time.get_hour ());
            }

            // Make sure that bounds are set correctly
            hours_spinbutton.set_range (1, 12);
        } else {
            am_pm_box.hide ();
            hours_spinbutton.set_value (time.get_hour ());

            hours_spinbutton.set_range (0, 23);
        }

        minutes_spinbutton.set_value (time.get_minute ());
        changing_time = false;

        popover.popup ();
    }

    private void is_unfocused () {
        if (!popover.visible && old_string.collate (text) != 0) {
            old_string = text;
            parse_time (text.dup ());
        }
    }

    private void parse_time (string timestr) {
        string current = "";
        bool is_hours = true;
        bool is_suffix = false;
        bool has_suffix = false;

        int? hour = null;
        int? minute = null;
        foreach (var c in timestr.down ().to_utf8 ()) {
            if (c.isdigit ()) {
                current = "%s%c".printf (current, c);
            } else {
                if (!is_suffix) {
                    if (current != "") {
                        if (is_hours) {
                            is_hours = false;
                            hour = int.parse (current);
                            current = "";
                        } else {
                            minute = int.parse (current);
                            current = "";
                        }
                    }

                    if (c.to_string ().contains ("a") || c.to_string ().contains ("p")) {
                        is_suffix = true;
                        current = "%s%c".printf (current, c);
                    }
                }

                if (c.to_string ().contains ("m") && is_suffix) {
                    if (hour == null) {
                        return;
                    } else if (minute == null) {
                        minute = 0;
                    }

                    // We can imagine that some will try to set it to "19:00 am"
                    if (current.contains ("a") || hour >= 12) {
                        time = time.add_hours (hour - time.get_hour ());
                    } else {
                        time = time.add_hours (hour + 12 - time.get_hour ());
                    }

                    if (current.contains ("a") && hour == 12) {
                        time = time.add_hours (-12);
                    }

                    time = time.add_minutes (minute - time.get_minute ());
                    has_suffix = true;
                }
            }
        }

        if (is_hours == false && is_suffix == false && current != "") {
            minute = int.parse (current);
        }

        if (hour == null) {
            if (current.length < 3) {
                hour = int.parse (current);
                minute = 0;
            } else if (current.length == 4) {
                hour = int.parse (current.slice (0, 2));
                minute = int.parse (current.slice (2, 4));
                if (hour > 23 || minute > 59) {
                    hour = null;
                    minute = null;
                }
            }
        }

        if (hour == null || minute == null) {
            update_text ();
            return;
        }

        if (has_suffix == false) {
            time = time.add_hours (hour - time.get_hour ());
            time = time.add_minutes (minute - time.get_minute ());
        }

        update_text ();
    }

    private void update_text (bool no_signal = false) {
        if (Granite.DateTime.is_clock_format_12h ()) {
            set_text (time.format (format_12));
        } else {
            set_text (time.format (format_24));
        }

        old_string = text;

        if (no_signal == false) {
            time_changed ();
        }
    }
}
