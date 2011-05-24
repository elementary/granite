//  
//  Copyright (C) 2011 Robert Dyer, Maxwell Barvian
// 
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
// 
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
// 
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
// 

using Cairo;
using Gdk;
using Gee;
using Gtk;

using Granite.Services;

namespace Granite.Drawing {

	public class Utilities : GLib.Object {
	
		public static void draw_rounded_rectangle (Cairo.Context context, double radius, double offset, Gdk.Rectangle size) {
		
			context.move_to (size.x + radius + offset, size.y + offset);
			context.arc (size.x + size.width - radius - offset, size.y + radius + offset, radius, Math.PI * 1.5, Math.PI * 2);
			context.arc (size.x + size.width - radius - offset, size.y + size.height - radius - offset, radius, 0, Math.PI * 0.5);
			context.arc (size.x + radius + offset, size.y + size.height - radius - offset, radius, Math.PI * 0.5, Math.PI);
			context.arc (size.x + radius + offset, size.y + radius + offset, radius, Math.PI, Math.PI * 1.5);
		}
		
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

