//  
//  Copyright (C) 2011 Mathijs Henquet
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

using Granite.Services;

namespace Granite.Widgets {
	
	public class AppMenu : ToolButtonWithMenu {
	
		public AppMenu (Menu menu) {
			
			var help_item = new MenuItem.with_label (_("Get Help Online..."));
			var translate_item = new MenuItem.with_label (_("Translate This Application..."));
			var report_item = new MenuItem.with_label (_("Report a Problem..."));
			var about_item = new MenuItem.with_label (_("About"));
			
			menu.append (new SeparatorMenuItem ());
			menu.append (help_item);
			menu.append (translate_item);
			menu.append (report_item);
			menu.append (new SeparatorMenuItem ());
			menu.append (about_item);
			
			base (new Image.from_stock (Stock.PROPERTIES, IconSize.MENU), _("Menu"), menu);
			
			help_item.activate.connect(() => System.open_uri (AppFactory.app.help_url));
			translate_item.activate.connect(() => System.open_uri (AppFactory.app.translate_url));
			report_item.activate.connect(() => System.open_uri (AppFactory.app.bug_url));
			about_item.activate.connect (AppFactory.app.show_about);
		}
		
	}
	
}


