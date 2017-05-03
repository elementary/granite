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
    public class SidebarStore : GLib.Object, GLib.ListModel {
        
        private uint _level;
        public uint level {
            default = 0;
            get {
                return _level;
            }
            set {
                _level = value;
                level_changed (value);
            }
        }

        public signal void level_changed (uint level);
        public signal void item_added (SidebarRowModel item);

        private Gee.ArrayList<SidebarRowModel> _full_list = new Gee.ArrayList<SidebarRowModel> ();
        public Gee.Collection<SidebarRowModel> full_list {
            owned get {
                // Create a copy of the children so that it's safe to iterate it
                // (e.g. by using foreach) while removing items.
                var full_list_copy = new Gee.ArrayList<SidebarRowModel> ();
                full_list_copy.add_all (_full_list);
                return full_list_copy;
            }
        }

        private Gee.ArrayList<SidebarRowModel> _root_items = new Gee.ArrayList<SidebarRowModel> ();
        public Gee.Collection<SidebarRowModel> root_items {
            owned get {
                // Create a copy of the children so that it's safe to iterate it
                // (e.g. by using foreach) while removing items.
                var root_list_copy = new Gee.ArrayList<SidebarRowModel> ();
                root_list_copy.add_all (_root_items);
                return root_list_copy;
            }
        }
    
        public SidebarStore () { }

        public Object? get_item (uint position) {
            return _full_list.get((int) position);
        }

        public Type get_item_type () {
            return typeof(SidebarRowModel);
        }

        public uint get_n_items () {
            return (uint) _full_list.size;
        }

        public Object? get_object (uint position) {
            return _full_list.get((int) position);
        }
        
        public void append (SidebarRowModel item) {
            assert (item != null);

            _root_items.add (item);

            handle_addition (_root_items.size - 1, item);
        }

        public void insert (uint position, SidebarRowModel item) {
            assert (item != null);

            _root_items.insert ((int) position, item);

            handle_addition (position, item);
        }

        public void handle_addition (uint position, SidebarRowModel item) {
            assert (item != null && position <= _root_items.size);

            item.register_parent_store (this);
            
            item_added (item);

            regenerate_full_list ();
            
            uint items_so_far = 0;

            items_so_far = full_list_items_until_root_items_position (position);

            if (item is SidebarParentRowModel) {
                var expandable_item = (SidebarParentRowModel) item;

                expandable_item.items_changed.connect ((position, removed, added) => {
                    handle_items_changed (item, position, removed, added);
                });

                items_changed (items_so_far, 0, 1 + expandable_item.children.get_n_items ());
            } else {
                items_changed (items_so_far, 0, 1);
            }
        }

        public void remove_at (uint position) {
            assert (position < _root_items.size);

            handle_removal (position);
        }

        public void remove (SidebarRowModel item) {
            var index = _root_items.index_of (item);
            
            assert (index != -1);

            handle_removal (index);
        }
        
        private void handle_removal (uint position) {
            assert (position < _root_items.size);

            uint children_count;
            
            var item = _root_items.get ((int) position);

            item.unregister_parent_store ();

            _root_items.remove (item);

            regenerate_full_list ();

            if (item is SidebarParentRowModel) {
                var expandable_item = (SidebarParentRowModel) item;

                items_changed (position, 1 + expandable_item.children.get_n_items (), 0);
            } else {
                items_changed (position, 1, 0);
            }
        }

        public void remove_all () {
            var size = _full_list.size;
            
            foreach (var root_item in _root_items) {
                root_item.unregister_parent_store ();
            }

            _root_items.clear ();

            regenerate_full_list ();

            items_changed (0, size, 0);
        }
        
        private void handle_items_changed (SidebarRowModel item, uint position, uint removed, uint added) {
            regenerate_full_list ();

            uint items_offset = 0;

            for (uint i = 0; i < _root_items.index_of (item); i++) {
                var child = _root_items.get((int) i);

                if (child is SidebarParentRowModel) {
                    var expandable_child = (SidebarParentRowModel) child;
                    items_offset += 1 + expandable_child.children.get_n_items ();
                } else {
                    items_offset += 1;
                }
            }

            items_offset += 1; // Offsetting for the root_item

            items_changed (items_offset + position, removed, added);
        }

        private void regenerate_full_list () {
            // It's easier and simpler to regenerate everything every time like 
            // this than keep track of everything.

            _full_list.clear ();

            foreach (var root_item in _root_items) {
                _full_list.add (root_item);

                if (root_item is SidebarParentRowModel) {
                    var expandable_item = (SidebarParentRowModel) root_item;
                    _full_list.add_all (expandable_item.children.full_list);
                }
            }
        }
        
        // How many items does the full_list contain before the item at this position in _root_items?
        private uint full_list_items_until_root_items_position (uint position) {
            uint items_so_far = 0;

            for (uint i = 0; i < position; i++) {
                var child = _root_items.get((int) i);
                
                if (child is SidebarParentRowModel) {
                    var expandable_child = (SidebarParentRowModel) child;
                    items_so_far += 1 + expandable_child.children.get_n_items ();
                } else {
                    items_so_far += 1;
                }
            }
            
            return items_so_far;
        }

    }
}