/*
* Copyright (c) 2016 elementary LLC (https://launchpad.net/granite)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 59 Temple Place - Suite 330,
* Boston, MA 02111-1307, USA.
*
*/

namespace Granite.Widgets {
    private class IndicatorBar : Gtk.DrawingArea {
        private uint MARGIN = 4;
        private int HEIGHT = 4;

        private double _fill = 0;
        public double fill {
            get {
                return _fill;
            }

            set {
                _fill = value;

                queue_draw ();
            }
        }

        public IndicatorBar () {
            Object ();
        }

        construct {
            hexpand = true;

            set_size_request (-1, HEIGHT);
        }

        public override bool draw (Cairo.Context context) {
            var width = get_allocated_width () - 2*MARGIN;
            var fill_width = fill * width;
            var height = get_allocated_height ();
            var x = MARGIN;
            var y = 0;

            var style_context = get_style_context ();
            style_context.render_background (context, x, y, width, height);
            style_context.add_class ("fill");
            style_context.render_background (context, x, y, fill_width, height);
            style_context.remove_class ("fill");
            style_context.render_frame (context,  x, y, width, height);

            return Gdk.EVENT_STOP;
        }        
    }
}