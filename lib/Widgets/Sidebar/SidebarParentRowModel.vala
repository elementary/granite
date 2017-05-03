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
    public abstract class SidebarParentRowModel : SidebarRowModel {
        
        public signal void items_changed (uint position, uint removed, uint added);
        public signal void expanded_changed (bool expanded);

        public Granite.Widgets.SidebarStore children { 
            get; 
            private set; 
            default = new Granite.Widgets.SidebarStore ();
        }

        private bool _expanded;
        public bool expanded {
            get {
                return _expanded;
            }
            set {
                _expanded = value;
                expanded_changed (_expanded);

                foreach (var item in children.root_items) {
                    if (value) {
                        item.show ();
                    } else {
                        item.hide ();
                    }
                }
            }
        }

        public SidebarParentRowModel (string label, bool expanded) {
            Object (label: label, expanded: expanded);
        }

        public SidebarParentRowModel.with_icon_name (string label, string icon_name, bool expanded) {
            Object (label: label, icon_name: icon_name, expanded: expanded);
        }

        construct {
            connect_signals ();
        }

        private void connect_signals () {
            children.items_changed.connect ((position, removed, added) => {
                items_changed (position, removed, added);
            });

            children.item_added.connect (handle_item_added);
            
            level_changed.connect (handle_level_changed);
            
            hide.connect (handle_hide_propagation);
            show.connect (handle_show_propagation);
        }
        
        private void handle_item_added (SidebarRowModel item) {
            if (expanded) {
                item.show ();
            } else {
                item.hide ();
            }
        }

        private void handle_level_changed (uint level) {
            children.level = level;
        }

        private void handle_show_propagation () {
            if (expanded) {                
                foreach (var item in children.root_items) {
                    item.show ();
                }
            }
        }
        
        private void handle_hide_propagation () {
            if (expanded) {
                foreach (var item in children.root_items) {
                    item.hide ();
                }
            }
        }
    }
}