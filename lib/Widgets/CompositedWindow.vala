//  
//  Copyright (C) 2011 Maxwell Barvian
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

using Gtk;
using Gdk;

namespace Granite.Widgets {

	public class CompositedWindow : Gtk.Window, Gtk.Buildable {
	
		private CssProvider style_provider;
		
		construct {
			
			// Set up css provider
			style_provider = new CssProvider ();
			try {
				style_provider.load_from_path (Build.RESOURCES_DIR + "/style/CompositedWindow.css");
			} catch (Error e) {
				warning ("Could not add css provider. Some widgets will not look as intended. %s", e.message);
			}
			
			// Window properties
			set_visual (get_screen ().get_rgba_visual());
			get_style_context().add_class("composited");
			get_style_context ().add_provider (style_provider, 600);
			app_paintable = true;
			decorated = false;
			resizable = false;
		}
		
	}
	
}

