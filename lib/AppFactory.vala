//  
//  Copyright (C) 2011 Robert Dyer
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

namespace Granite {

	/**
	 * Class for interacting with the properties of a {@link Granite.Application} without
	 * re-instantiating the application.  This class is commonly used to show the about dialog
	 * generated for the {@link Granite.Application} or access other publicly-accessible properties.
	 */
	public class AppFactory : GLib.Object	{
	
		/**
		 * The {@link Granite.Application} to interact with.
		 */
		public static Granite.Application app;
		
		/**
		 * Initializes the {@link Granite.AppFactory} for the supplied {@link Granite.Application}.
		 * This method must be invoked first before using the {@link Granite.Application.app} property.
		 *
		 * @param app_class The {@link Granite.Application} to interact with
		 */
		public static void init (Granite.Application app_class) {
			app = app_class;
		}
		
	}
	
}
