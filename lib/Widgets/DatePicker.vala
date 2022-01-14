/*
 * Copyright 2019-2022 elementary, Inc. (https://elementary.io)
 * Copyright 2011–2013 Maxwell Barvian <maxwell@elementaryos.org>
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */


/**
 * This class allows users to pick dates from a calendar.
 */
public class Granite.DatePicker : Gtk.Entry, Gtk.Buildable {
    /**
     * Desired format of DatePicker
     */
    public string format { get; construct; }

    /**
     * Current Date
     */
    public GLib.DateTime date { get; set; }

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

        var calendar = new Gtk.Calendar ();

        var popover = new Gtk.Popover () {
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

        icon_release.connect (() => {
            popover.popup ();
        });

        calendar.day_selected.connect (() => {
            date = new GLib.DateTime.local (calendar.year, calendar.month + 1, calendar.day, 0, 0, 0);
        });

        notify["date"].connect (() => {
            text = _date.format (format);
            calendar.select_day (date);
        });
    }
}
