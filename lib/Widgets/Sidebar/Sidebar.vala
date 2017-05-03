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
    public class Sidebar : Gtk.ListBox {
    
        public Sidebar () {
            Object ();
        }
        
        construct {
            build_ui ();
        }

        private void build_ui () {
            get_style_context ().add_class (Gtk.STYLE_CLASS_SIDEBAR);
            width_request = 176;
            vexpand = true;
        }

        public void bind_model (ListModel? model) {
            base.bind_model (model, walk_model_items);
        }
        
        private Gtk.Widget walk_model_items (Object item) {
            assert (item is SidebarRowModel);    

            if (item is SidebarExpandableRowModel) {
                var sidebar_model = (SidebarExpandableRowModel) item;
                
                return new SidebarExpandableRow (sidebar_model);
            } else if (item is SidebarHeaderModel) {
                var sidebar_model = (SidebarHeaderModel) item;
                
                return new SidebarHeader (sidebar_model);
            } else {
                var sidebar_model = (SidebarRowModel) item;

                return new SidebarRow (sidebar_model);
            }


        }
    }
}