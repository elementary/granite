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
    construct {
        margin = 24;
        halign = Gtk.Align.CENTER;
        valign = Gtk.Align.CENTER;

        var seek_bar = new Granite.Widgets.SeekBar(100);
        add (seek_bar);

        double progress = 0.0;
        Timeout.add (500, () => {
            if (progress >= 1.0) {
                progress = 0.0;
                seek_bar.set_progress (0.0);
            } else {
                progress += 0.1;
                seek_bar.set_progress (progress);
            }
        });
    }
}
