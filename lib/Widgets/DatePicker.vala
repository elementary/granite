/*
 * Copyright 2019 elementary, Inc. (https://elementary.io)
 * Copyright 2011–2013 Maxwell Barvian <maxwell@elementaryos.org>
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

namespace Granite.Widgets {

    /**
     * This class allows users to pick dates from a calendar.
     */
    public class DatePicker : Gtk.Entry, Gtk.Buildable {

        const int OFFSET = 15;
        const int MARGIN = 6;
        // Signals
        /**
         * Sent when the date got changed
         */
        public signal void date_changed ();

        /**
         * Desired format of DatePicker
         */
        public string format { get; construct; }

        /**
         * Dropdown of DatePicker
         */
        protected Gtk.EventBox dropdown;
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
                calendar.select_month (value.get_month () - 1, value.get_year ());
                proc_next_day_selected = false;
                calendar.select_day (value.get_day_of_month ());
                date_changed ();
            }
        }

        /**
         * Makes new DatePicker
         */
        construct {
            if (format == null)
                format = Granite.DateTime.get_default_date_format (false, true, true);

            dropdown = new Gtk.EventBox ();
            dropdown.margin = MARGIN;
            popover = new Gtk.Popover (this);
            popover.add (dropdown);
            calendar = new Gtk.Calendar ();
            date = new GLib.DateTime.now_local ();

            // Entry properties
            can_focus = false;
            editable = false; // user can't edit the entry directly
            secondary_icon_gicon = new ThemedIcon.with_default_fallbacks ("office-calendar-symbolic");

            dropdown.add_events (Gdk.EventMask.FOCUS_CHANGE_MASK);
            dropdown.add (calendar);

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

        /**
         * Makes a new DatePicker
         *
         * @param format desired format of new DatePicker
         */
        public DatePicker.with_format (string format) {
            Object (format: format);
        }

        private void on_icon_press (Gtk.EntryIconPosition position) {
            Gdk.Rectangle rect;
            position_dropdown (out rect);
            popover.pointing_to = rect;
            popover.position = Gtk.PositionType.BOTTOM;
            popover.show_all ();
            calendar.grab_focus ();
        }

        protected virtual void position_dropdown (out Gdk.Rectangle rect) {
            Gtk.Allocation size;
            get_allocation (out size);

            rect = Gdk.Rectangle ();
            rect.x = size.width - OFFSET;
            rect.y = size.height;
        }

        private void on_calendar_day_selected () {
            if (proc_next_day_selected) {
                date = new GLib.DateTime.local (calendar.year, calendar.month + 1, calendar.day, 0, 0, 0);
                hide_dropdown ();
            } else {
                proc_next_day_selected = true;
            }
        }

        private void hide_dropdown () {
            popover.hide ();
        }
    }
}
