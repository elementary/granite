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
	
//~ 	    public MenuItem help_item;
//~ 	    public MenuItem translate_item;
//~ 	    public MenuItem report_item;
	    public MenuItem about_item;
	
	    /**
	     * Deprecated constructor
	     *
	     * @deprecated
	     */
		public AppMenu (Menu menu) {
			
			base (new Image.from_stock (Stock.PROPERTIES, IconSize.MENU), _("Menu"), menu);
			
			this.add_items (menu);
			
//~ 			help_item.activate.connect(() => System.open_uri (Granite.app.help_url));
//~ 			translate_item.activate.connect(() => System.open_uri (Granite.app.translate_url));
//~ 			report_item.activate.connect(() => System.open_uri (Granite.app.bug_url));
			about_item.activate.connect (() => Granite.app.show_about (get_toplevel ()));
		}
		
		public virtual signal void show_about (Gtk.Widget parent) { }
		
//~ 		public AppMenu.with_urls (Menu menu, string help_url, string translate_url, string bug_url) {
		public AppMenu.with_urls (Menu menu) {
		
			base (new Image.from_stock (Stock.PROPERTIES, IconSize.MENU), _("Menu"), menu);
			
			this.add_items (menu);
			
//~ 			help_item.activate.connect(() => System.open_uri (help_url));
//~ 			translate_item.activate.connect(() => System.open_uri (translate_url));
//~ 			report_item.activate.connect(() => System.open_uri (bug_url));
			about_item.activate.connect (() => this.show_about (get_toplevel ()));
		}
		
		public void add_items (Menu menu) {
		    
//~ 		    help_item = new MenuItem.with_label (_("Get Help Online..."));
//~ 			translate_item = new MenuItem.with_label (_("Translate This Application..."));
//~ 			report_item = new MenuItem.with_label (_("Report a Problem..."));
			about_item = new MenuItem.with_label (_("About"));
			
			if (menu.get_children ().length () > 0)
				menu.append (new SeparatorMenuItem ());
//~ 			menu.append (help_item);
//~ 			menu.append (translate_item);
//~ 			menu.append (report_item);
//~ 			menu.append (new SeparatorMenuItem ());
			menu.append (about_item);
		}
		
	}
	
}


