// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2017 elementary LLC. (https://elementary.io)
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

public class SeekBarView : Gtk.Grid {
    private Gtk.Popover preview_popover;
    private Gtk.Label preview_label;

    public SeekBarView () {
        Object (valign: Gtk.Align.CENTER,
                margin: 24);
    }

    construct {
        preview_popover = new Gtk.Popover (this);
        preview_popover.can_focus = false;
        preview_popover.sensitive = false;
        preview_popover.modal = false;
        preview_popover.valign = Gtk.Align.CENTER;

        preview_label = new Gtk.Label ("");
        preview_label.margin = 5;
        preview_popover.add (preview_label);
        preview_popover.show_all ();
        preview_popover.set_visible (false);

        var seek_bar = new Granite.SeekBar (100);

        preview_popover.relative_to = seek_bar.scale;

        seek_bar.scale.motion_notify_event.connect ((event) => {
            update_pointing ((int) event.x);
            if (!seek_bar.is_grabbing) {
                var duration_decimal = (event.x / ((double) event.window.get_width ()));
                var duration_mins = Granite.DateTime.seconds_to_time ((int) (duration_decimal * seek_bar.playback_duration));
                preview_label.label = duration_mins.to_string ();
            }
            return false;
        });

        seek_bar.scale.enter_notify_event.connect (() => {
            preview_popover.set_visible (true);
            return false;
        });

        seek_bar.scale.leave_notify_event.connect (() => {
            preview_popover.set_visible (false);
            return false;
        });

        seek_bar.scale.button_press_event.connect (() => {
            preview_label.margin = 10;
            return false;
        });

        seek_bar.scale.button_release_event.connect (() => {
            preview_label.margin = 5;
            return false;
        });

        seek_bar.scale.change_value.connect ((scroll, new_value) => {
            if (new_value >= 0.0 && new_value <= 1.0) {
                var duration_mins = Granite.DateTime.seconds_to_time ((int) (new_value * seek_bar.playback_duration));
                preview_label.label = duration_mins.to_string ();
            }
            return false;
        });

        add (seek_bar);

        int progress = 0;
        Timeout.add (500, () => {
            if (seek_bar.is_grabbing) {
                return true;
            }

            if (progress >= 10) {
                progress = 0;
                seek_bar.playback_progress = 0.0;
            } else {
                progress += 1;
                seek_bar.playback_progress = progress / 10.0;
            }
            return true;
        });
    }

    private void update_pointing (int x) {
        var pointing = preview_popover.pointing_to;
        pointing.x = x;

        // changing the width properly updates arrow position when popover hits the edge
        if (pointing.width == 0) {
            pointing.width = 2;
            pointing.x -= 1;
        } else {
            pointing.width = 0;
        }

        preview_popover.set_pointing_to (pointing);
    }
}
