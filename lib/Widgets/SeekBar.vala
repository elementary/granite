/*-
 * Copyright 2017 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

/**
 * This widget is a playback statusbar that contains a Gtk.Scale widget and
 * two labels displaying the current progression and the total duration.
 *
 * Granite.SeekBar will get the style class .seek-bar
 *
 * {{../doc/images/SeekBar.png}}
 *
 * ''Example''<<BR>>
 * {{{
 * public class SeekBarView : Gtk.Grid {
 *     private Gtk.Popover preview_popover;
 *     private Gtk.Label preview_label;
 *
 *     public SeekBarView () {
 *         Object (valign: Gtk.Align.CENTER,
 *                 margin: 24);
 *     }
 *
 *     construct {
 *         preview_popover = new Gtk.Popover (this);
 *         preview_popover.can_focus = false;
 *         preview_popover.sensitive = false;
 *         preview_popover.modal = false;
 *         preview_popover.valign = Gtk.Align.CENTER;
 *
 *         preview_label = new Gtk.Label ("");
 *         preview_label.margin = 5;
 *         preview_popover.add (preview_label);
 *         preview_popover.show_all ();
 *         preview_popover.set_visible (false);
 *
 *         var seek_bar = new Granite.SeekBar (100);
 *
 *         preview_popover.relative_to = seek_bar.scale;
 *
 *         seek_bar.scale.motion_notify_event.connect ((event) => {
 *             update_pointing ((int) event.x);
 *             if (!seek_bar.is_grabbing) {
 *                 var duration_decimal = (event.x / ((double) event.window.get_width ()));
 *                 var duration_mins = Granite.DateTime.seconds_to_time ((int) (duration_decimal * seek_bar.playback_duration));
 *                 preview_label.label = duration_mins.to_string ();
 *             }
 *             return false;
 *         });
 *
 *         seek_bar.scale.enter_notify_event.connect (() => {
 *             preview_popover.set_visible (true);
 *             return false;
 *         });
 *
 *         seek_bar.scale.leave_notify_event.connect (() => {
 *             preview_popover.set_visible (false);
 *             return false;
 *         });
 *
 *         seek_bar.scale.button_press_event.connect (() => {
 *             preview_label.margin = 10;
 *             return false;
 *         });
 *
 *         seek_bar.scale.button_release_event.connect (() => {
 *             preview_label.margin = 5;
 *             return false;
 *         });
 *
 *         seek_bar.scale.change_value.connect ((scroll, new_value) => {
 *             if (new_value >= 0.0 && new_value <= 1.0) {
 *                 var duration_mins = Granite.DateTime.seconds_to_time ((int) (new_value * seek_bar.playback_duration));
 *                 preview_label.label = duration_mins.to_string ();
 *             }
 *             return false;
 *         });
 *
 *         add (seek_bar);
 *
 *         int progress = 0;
 *         Timeout.add (500, () => {
 *             if (seek_bar.is_grabbing) {
 *                 return true;
 *             }
 *
 *             if (progress >= 10) {
 *                 progress = 0;
 *                 seek_bar.playback_progress = 0.0;
 *             } else {
 *                 progress += 1;
 *                 seek_bar.playback_progress = progress / 10.0;
 *             }
 *             return true;
 *         });
 *     }
 *
 *     private void update_pointing (int x) {
 *         var pointing = preview_popover.pointing_to;
 *         pointing.x = x;
 *
 *         // changing the width properly updates arrow position when popover hits the edge
 *         if (pointing.width == 0) {
 *             pointing.width = 2;
 *             pointing.x -= 1;
 *         } else {
 *             pointing.width = 0;
 *         }
 *
 *         preview_popover.set_pointing_to (pointing);
 *     }
 * }
 * }}}
 */

public class Granite.SeekBar : Gtk.Grid {
    private double _playback_duration;
    private double _playback_progress;

    /*
     * The time of the full duration of the playback.
     */
    public double playback_duration {
        get {
            return _playback_duration;
        }
        set {
            double duration = value;
            if (duration < 0.0) {
                debug ("Duration value less than zero, duration set to 0.0");
                duration = 0.0;
            }

            _playback_duration = duration;
            duration_label.label = DateTime.seconds_to_time ((int) duration);
        }
    }

    /*
     * The progression of the playback as a decimal from 0.0 to 1.0.
     */
    public double playback_progress {
        get {
            return _playback_progress;
        }
        set {
            double progress = value;
            if (progress < 0.0) {
                debug ("Progress value less than 0.0, progress set to 0.0");
                progress = 0.0;
            } else if (progress > 1.0) {
                debug ("Progress value greater than 1.0, progress set to 1.0");
                progress = 1.0;
            }

            _playback_progress = progress;
            scale.set_value (progress);
            progression_label.label = DateTime.seconds_to_time ((int) (progress * playback_duration));
        }
    }

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
    public Gtk.Label duration_label { get; construct set; }

    /*
     * The time of the full duration of the playback.
     */
    public Gtk.Scale scale { get; construct set; }

    /*
     * Creates a new SeekBar with a fixed playback duration.
     * */
    public SeekBar (double playback_duration) {
        Object (playback_duration: playback_duration);
    }

    construct {
        column_spacing = 6;
        get_style_context ().add_class (Granite.STYLE_CLASS_SEEKBAR);

        progression_label = new Gtk.Label (null);
        duration_label = new Gtk.Label (null);
        progression_label.margin_start = duration_label.margin_end = 3;

        scale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 1, 0.1);
        scale.hexpand = true;
        scale.draw_value = false;
        scale.can_focus = false;
        scale.events |= Gdk.EventMask.POINTER_MOTION_MASK;
        scale.events |= Gdk.EventMask.LEAVE_NOTIFY_MASK;
        scale.events |= Gdk.EventMask.ENTER_NOTIFY_MASK;

        /* signal property setting */
        scale.button_press_event.connect (() => {
            is_grabbing = true;
            return false;
        });

        scale.button_release_event.connect (() => {
            is_grabbing = false;
            playback_progress = scale.get_value ();
            return false;
        });

        scale.enter_notify_event.connect (() => {
            is_hovering = true;
            return false;
        });

        scale.leave_notify_event.connect (() => {
            is_hovering = false;
            return false;
        });

        scale.motion_notify_event.connect (() => {
            playback_progress = scale.get_value ();
            return false;
        });

        add (progression_label);
        add (scale);
        add (duration_label);

        playback_progress = 0.0;
    }

    public override void get_preferred_width (out int minimum_width, out int natural_width) {
        base.get_preferred_width (out minimum_width, out natural_width);

        if (parent == null) {
            return;
        }

        var window = parent.get_window ();
        if (window == null) {
            return;
        }

        var width = parent.get_window ().get_width ();
        if (width > 0 && width >= minimum_width) {
            natural_width = width;
        }
    }
}
