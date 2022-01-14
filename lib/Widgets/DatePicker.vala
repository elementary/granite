/*
 * Copyright 2019-2021 elementary, Inc. (https://elementary.io)
 * Copyright 2011–2013 Maxwell Barvian <maxwell@elementaryos.org>
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */


/**
 * This class allows users to pick dates from a calendar.
 */
public class Granite.DatePicker : Gtk.Entry, Gtk.Buildable {
    /**
     * Sent when the date got changed
     */
    public signal void date_changed ();

    /**
     * Desired format of DatePicker
     */
    public string format { get; construct; }

    /**
     * The Calendar to create the DatePicker
     */
    protected Gtk.Calendar calendar;

    private Gtk.Popover popover;

    private GLib.DateTime _date;

    private bool proc_next_day_selected = true;

    /**
     * Current Date
     */
    public GLib.DateTime date {
        get { return _date; }
        set {
            _date = value;
            text = _date.format (format);
            proc_next_day_selected = false;
            calendar.select_day (value);
            date_changed ();
        }
    }

    /**
     * Makes a new DatePicker
     *
     * @param format desired format of new DatePicker
     */
    public DatePicker.with_format (string format) {
        Object (format: format);
    }

    /**
     * Makes new DatePicker
     */
    construct {
        if (format == null)
            format = Granite.DateTime.get_default_date_format (false, true, true);

        calendar = new Gtk.Calendar ();

        popover = new Gtk.Popover () {
            halign = Gtk.Align.END,
            autohide = true,
            child = calendar,
            has_arrow = false,
            position = Gtk.PositionType.BOTTOM
        };
        popover.set_parent (this);

        date = new GLib.DateTime.now_local ();

        // Entry properties
        editable = false; // user can't edit the entry directly
        primary_icon_gicon = new ThemedIcon.with_default_fallbacks ("office-calendar-symbolic");
        secondary_icon_gicon = new ThemedIcon.with_default_fallbacks ("pan-down-symbolic");

        add_css_class ("date-picker");

        // Signals and callbacks
        icon_release.connect (on_icon_press);
        calendar.day_selected.connect (on_calendar_day_selected);

        /*
         * A next/prev month/year event
         * also triggers a day selected event,
         * so stop the next day selected event
         * from setting the date and closing
         * the calendar.
         */
        calendar.next_month.connect (() => {
            proc_next_day_selected = false;
        });

        calendar.next_year.connect (() => {
            proc_next_day_selected = false;
        });

        calendar.prev_month.connect (() => {
            proc_next_day_selected = false;
        });

        calendar.prev_year.connect (() => {
            proc_next_day_selected = false;
        });
    }

    private void on_icon_press (Gtk.EntryIconPosition position) {
        popover.popup ();

        calendar.grab_focus ();
    }

    private void on_calendar_day_selected () {
        if (proc_next_day_selected) {
            date = new GLib.DateTime.local (calendar.year, calendar.month + 1, calendar.day, 0, 0, 0);
            popover.popdown ();
        } else {
            proc_next_day_selected = true;
        }
    }
}
