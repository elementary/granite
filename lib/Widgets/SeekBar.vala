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

namespace Granite.Widgets {

    public class SeekBar : Gtk.Grid {
        private Gtk.Label progression_label;
        private Gtk.Label time_label;
        private Gtk.Scale scale;

        public double playback_duration { get; private set; }
        public double playback_progress { get; private set; }
        private const double step = 0.1;

        public bool released { get; private set; }

        public signal void scale_hover (Gdk.EventCrossing event);
        public signal void scale_press (Gdk.EventButton event);
        public signal void scale_leave (Gdk.EventCrossing event);
        public signal void scale_motion (Gdk.EventMotion event);
        public signal void scale_release (Gdk.EventButton event);
        public signal void range_values_changed ();
        public signal void scroll_action (Gtk.ScrollType scroll, double new_value);
        //public signal void scale_size_allocate (Gtk.Allocation alloc_rect);

        /*
         * Creates a new SeekBar with a fixed playback duration
         * */
        public SeekBar (double playback_duration) {
            this.get_style_context ().add_class ("seek-bar");

            set_duration (playback_duration);
            set_progress (0);
        }

        construct {
            /* GUI */
            orientation = Gtk.Orientation.HORIZONTAL;
            column_spacing = 6;
            halign = Gtk.Align.CENTER;
            progression_label = new Gtk.Label ("");
            time_label = new Gtk.Label ("");
            set_label_scale_margin (3);

            scale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 1, step);
            scale.hexpand = true;
            scale.draw_value = false;
            scale.can_focus = false;
            scale.events |= Gdk.EventMask.POINTER_MOTION_MASK;
            scale.events |= Gdk.EventMask.LEAVE_NOTIFY_MASK;
            scale.events |= Gdk.EventMask.ENTER_NOTIFY_MASK;

            released = true;

            /* signals */
            scale.button_press_event.connect ((event) => {
                released = false;
                scale_press (event);
                return false;
            });

            scale.button_release_event.connect ((event) => {
                released = true;
                set_progress (scale.get_value ());
                scale_release (event);
                return false;
            });

            scale.enter_notify_event.connect ((event) => {
                scale_hover (event);
                return false;
            });

            scale.leave_notify_event.connect ((event) => {
                scale_leave (event);
                return false;
            });

            scale.motion_notify_event.connect ((event) => {
                set_progress (scale.get_value ());
                scale_motion (event);
                return false;
            });

            scale.value_changed.connect (() => {
                range_values_changed ();
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
         * Sets the progress of the SeekBar, with a value between 0.0 and 1.0
         * */
        public void set_progress (double progress) {
            if (progress < 0.0) {
                warning ("Progress value less than zero, progress set to 0.0");
                progress = 0.0;
            }
            else if (progress > 1.0) {
                warning ("Progress value greater than zero, progress set to 1.0");
                progress = 1.0;
            }

            this.playback_progress = progress;
            scale.set_value (playback_progress);
            progression_label.label = seconds_to_time ((int) (playback_progress*playback_duration));
        }

        /*
         * Sets the margins between the labels and the gtk.scale
         * */
        public void set_label_scale_margin (int margin) {
            progression_label.margin_right = time_label.margin_left = margin;
        }

        /*
         * Sets the duration of the SeekBar with a value greater than 0.0
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
            minimum_width = 200;
            if (natural_width < 600)
                natural_width = 600;
        }

        private string seconds_to_time (int seconds) {
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

}
