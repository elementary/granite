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
	
	    public MenuItem about_item;
	
        public signal void show_about(Gtk.Widget w);

		public AppMenu (Menu menu) {
		
			base (new Image.from_stock (Stock.PROPERTIES, IconSize.MENU), _("Menu"), menu);
		}

		public AppMenu.with_app (Granite.Application application, Gtk.Menu menu) {
		
			base (new Image.from_stock (Stock.PROPERTIES, IconSize.MENU), _("Menu"), menu);
			
			this.add_items (menu);
			
			about_item.activate.connect (() => { show_about(get_toplevel()); });
		}

        /**
         * Create a new AppMenu, parameters are unused now.
         *
         * @deprecated 0.1
         **/
        public AppMenu.with_urls (Menu menu, string help_url, string translate_url, string bug_url) {
            critical("This is a deprecated creation method: AppMenu.with_urls");
			base (new Image.from_stock (Stock.PROPERTIES, IconSize.MENU), _("Menu"), menu);
        }
		
		public void add_items (Menu menu) {
		    
			about_item = new MenuItem.with_label (_("About"));
			
			if (menu.get_children ().length () > 0)
				menu.append (new SeparatorMenuItem ());
			menu.append (about_item);
		}
		
	}
	
}


