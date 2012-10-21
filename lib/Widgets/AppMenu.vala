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
    
	/**
	* An App Menu is the gear menu that goes on the right of the toolbar.
	*/    
    public class AppMenu : ToolButtonWithMenu {
        
        /**
        * Menu item for about page
        */
        public Gtk.MenuItem about_item;
    
        /**
        * Called when showing about
        */
        public signal void show_about(Gtk.Widget w);

        /**
        * Makes new AppMenu
        *
        * @param menu menu to be added
        */
        public AppMenu (Gtk.Menu menu) {
        
            base (new Image.from_icon_name ("application-menu", IconSize.MENU), _("Menu"), menu);
        }

        /**
        * Makes new AppMenu with built-in about page
        *
        * @param application application of AppMenu
        * @param menu to be created
        */
        public AppMenu.with_app (Granite.Application? application, Gtk.Menu menu) {
        
            base (new Image.from_icon_name ("application-menu", IconSize.MENU), _("Menu"), menu);
            
            this.add_items (menu);
            
            about_item.activate.connect (() => { show_about(get_toplevel()); });
        }

        /**
         * Create a new AppMenu, parameters are unused now.
         *
         * @deprecated 0.1
         **/
        [Deprecated (since = "granite-0.1")]
        public AppMenu.with_urls (Gtk.Menu menu, string help_url, string translate_url, string bug_url) {
            critical("This is a deprecated creation method: AppMenu.with_urls");
            base (new Image.from_icon_name ("application-menu", IconSize.MENU), _("Menu"), menu);
        }
        
        public void add_items (Gtk.Menu menu) {
            
            about_item = new Gtk.MenuItem.with_label (_("About"));
            
            if (menu.get_children ().length () > 0)
                menu.append (new SeparatorMenuItem ());
            menu.append (about_item);
        }
        
    }
    
}


