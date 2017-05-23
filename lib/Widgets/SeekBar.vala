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
 * The SeekBar is a widget for viewing and setting media playback position.
 *
 * Granite.SeekBar will get the style class .app-notification
 *
 * {{../../doc/images/Toast.png}}
 */

public class Granite.Widgets.SeekBar : Gtk.Grid {

    /**
     * Creates a new SeekBar
     */
    public SeekBar () {
    }

    construct {
        var progression_label = new Gtk.Label ("0:00");

        var scale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 1, 0.1);
        scale.draw_value = false;
        scale.hexpand = true;

        var time_label = new Gtk.Label ("0:00");

        column_spacing = 12;
        add (progression_label);
        add (scale);
        add (time_label);
    }

}
