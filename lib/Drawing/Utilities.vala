/*
 *  Copyright (C) 2011-2013 Maxwell Barvian <maxwell@elementaryos.org>,
 *                          Robert Dyer
 *
 *  This program or library is free software; you can redistribute it
 *  and/or modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation; either
 *  version 3 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 *  Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General
 *  Public License along with this library; if not, write to the
 *  Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 *  Boston, MA 02110-1301 USA.
 */

using Cairo;
using Gdk;
using Gtk;

using Granite.Services;

namespace Granite.Drawing {

    /**
     * A utility class for frequently-performed drawing operations.
     */
    public class Utilities : GLib.Object {
    
        /**
         * Adds a closed sub-path rounded rectangle of the given size and border radius to the current path
         * at position (x, y) in user-space coordinates.
         *
         * @param cr a {@link Cairo.Context}
         * @param x the X coordinate of the top left corner of the rounded rectangle
         * @param y the Y coordinate to the top left corner of the rounded rectangle
         * @param width the width of the rounded rectangle
         * @param height the height of the rounded rectangle
         * @param radius the border radius of the rounded rectangle
         */
        public static void cairo_rounded_rectangle (Cairo.Context cr, double x, double y, double width, double height, double radius) {
        
            cr.move_to (x + radius, y);
            cr.arc (x + width - radius, y + radius, radius, Math.PI * 1.5, Math.PI * 2);
            cr.arc (x + width - radius, y + height - radius, radius, 0, Math.PI * 0.5);
            cr.arc (x + radius, y + height - radius, radius, Math.PI * 0.5, Math.PI);
            cr.arc (x + radius, y + radius, radius, Math.PI, Math.PI * 1.5);
            cr.close_path ();
        }
        
        /**
         * Averages the colors in the {@link Gdk.Pixbuf} and returns it.
         *
         * @param source the {@link Gdk.Pixbuf}
         * 
         * @return the {@link Granite.Drawing.Color} containing the averaged color
         */
        public static Drawing.Color average_color (Pixbuf source) {
        
            var rTotal = 0.0;
            var gTotal = 0.0;
            var bTotal = 0.0;
            
            uint8* dataPtr = source.get_pixels ();
            double pixels = source.height * source.rowstride / source.n_channels;
            
            for (var i = 0; i < pixels; i++) {
                var r = dataPtr [0];
                var g = dataPtr [1];
                var b = dataPtr [2];
                
                var max = (uint8) double.max (r, double.max (g, b));
                var min = (uint8) double.min (r, double.min (g, b));
                double delta = max - min;
                
                var sat = delta == 0 ? 0.0 : delta / max;
                var score = 0.2 + 0.8 * sat;
                
                rTotal += r * score;
                gTotal += g * score;
                bTotal += b * score;
                
                dataPtr += source.n_channels;
            }
            
            return new Drawing.Color (rTotal / uint8.MAX / pixels,
                             gTotal / uint8.MAX / pixels,
                             bTotal / uint8.MAX / pixels,
                             1).set_val (0.8).multiply_sat (1.15);
        }
        
    }
    
}

