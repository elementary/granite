/*-
 * Copyright (c) 2017 elementary LLC. (https://elementary.io)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the Lesser GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * This widget is a playback statusbar that contains a gtk.scale widget and
 * two labels showing the current time and the time remaining.
 *
 * Granite.SeekBar will get the style class .app-notification
 *
 * {{../../doc/images/SeekBar.png}}
 */

public class Granite.Widgets.SeekBar : Gtk.Grid {
    /*
     * The time of the full duration of the playback.
     */
    public double playback_duration { get; construct set; }

    /*
     * The progression of the playback as a decimal from 0.0 to 1.0.
     */
    public double playback_progress { get; private set; }

    /*
     * If the pointer is grabbing the scale button.
     */
    public bool is_grabbing { get; private set; default = false; }

    /*
     * If the pointer is hovering over the scale.
     */
    public bool is_hovering { get; private set; default = false; }

    /*
     * The left label that displays the time progressed.
     */
    public Gtk.Label progression_label { get; construct set; }

    /*
     * The right label that displays the total duration time.
     */
    public Gtk.Label time_label { get; construct set; }

    /*
     * The time of the full duration of the playback.
     */
    public Gtk.Scale scale { get; construct set; }

    /*
     * Emitted when the scale's window is hovered over.
     */
    public signal void scale_hover (Gdk.EventCrossing event);

    /*
     * Emitted when the pointer leaves the scale's window.
     */
    public signal void scale_leave (Gdk.EventCrossing event);

    /*
     * Emitted when the pointer moves over the scale.
     */
    public signal void scale_motion (Gdk.EventMotion event);

    /*
     * Emitted when the scale button is pressed.
     */
    public signal void scale_button_press (Gdk.EventButton event);

    /*
     * Emitted when the scale button is released.
     */
    public signal void scale_button_release (Gdk.EventButton event);

    /*
     * Emitted when a scroll action is performed on the scale.
     */
    public signal void scroll_action (Gtk.ScrollType scroll, double new_value);

    /*
     * Emitted when the region has been allocated for the scale.
     */
    //public signal void scale_size_allocate (Gtk.Allocation alloc_rect);

    /*
     * Creates a new SeekBar with a fixed playback duration.
     * */
    public SeekBar (double playback_duration) {
        Object (playback_duration: playback_duration);
    }

    construct {
        get_style_context ().add_class ("seek-bar");

        /* GUI */
        orientation = Gtk.Orientation.HORIZONTAL;
        column_spacing = 6;

        progression_label = new Gtk.Label ("");
        time_label = new Gtk.Label ("");
        progression_label.get_style_context ().add_class ("progression-label");
        time_label.get_style_context ().add_class ("time-label");
        progression_label.margin_right = time_label.margin_left = 3;

        scale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 1, 0.1);
        scale.get_style_context ().add_class ("scale");
        scale.hexpand = true;
        scale.draw_value = false;
        scale.can_focus = false;
        scale.events |= Gdk.EventMask.POINTER_MOTION_MASK;
        scale.events |= Gdk.EventMask.LEAVE_NOTIFY_MASK;
        scale.events |= Gdk.EventMask.ENTER_NOTIFY_MASK;

        set_duration (playback_duration);
        set_progress (0);

        /* signals */
        scale.button_press_event.connect ((event) => {
            is_grabbing = true;
            scale_button_press (event);
            return false;
        });

        scale.button_release_event.connect ((event) => {
            is_grabbing = false;
            set_progress (scale.get_value ());
            scale_button_release (event);
            return false;
        });

        scale.enter_notify_event.connect ((event) => {
            is_hovering = true;
            scale_hover (event);
            return false;
        });

        scale.leave_notify_event.connect ((event) => {
            is_hovering = false;
            scale_leave (event);
            return false;
        });

        scale.motion_notify_event.connect ((event) => {
            set_progress (scale.get_value ());
            scale_motion (event);
            return false;
        });

        scale.change_value.connect ((scroll, new_value) => {
            scroll_action (scroll, new_value);
            return false;
        });

        scale.size_allocate.connect ((alloc_rect) => {
            //scale_size_allocate (alloc_rect);
        });

        add (progression_label);
        add (scale);
        add (time_label);
    }

    /*
     * Sets the progress of the SeekBar, with a value between 0.0 and 1.0.
     * */
    public void set_progress (double progress) {
        if (progress < 0.0) {
            warning ("Progress value less than zero, progress set to 0.0");
            progress = 0.0;
        } else if (progress > 1.0) {
            warning ("Progress value greater than zero, progress set to 1.0");
            progress = 1.0;
        }

        this.playback_progress = progress;
        scale.set_value (playback_progress);
        progression_label.label = seconds_to_time ((int) (playback_progress*playback_duration));
    }

    /*
     * Sets the duration of the SeekBar with a value greater than 0.0.
     * */
    private void set_duration (double duration) {
        if (duration < 0.0) {
            warning ("Duration value less than zero, duration set to 0.0");
            duration = 0.0;
        }

        this.playback_duration = duration;
        time_label.label = seconds_to_time ((int) duration);
    }

    public override void get_preferred_width (out int minimum_width, out int natural_width) {
        base.get_preferred_width (out minimum_width, out natural_width);

        if (parent.get_window () == null)
            return;
        var width = parent.get_window ().get_width ();
        if (width > 0 && width >= minimum_width) {
            natural_width = width;
        }
    }

    /*
     * Converts seconds into the ISO 8601 standard date format for minutes (e.g. 100s to 01:40)
     */
    public string seconds_to_time (int seconds) {
        int hours = seconds / 3600;
        string min = normalize_time ((seconds % 3600) / 60);
        string sec = normalize_time (seconds % 60);

        if (hours > 0) {
            return ("%d:%s:%s".printf (hours, min, sec));
        } else {
            return ("%s:%s".printf (min, sec));
        }
    }

    private string normalize_time (int time) {
        if (time < 10) {
            return "0%d".printf (time);
        } else {
            return "%d".printf (time);
        }
    }
}

