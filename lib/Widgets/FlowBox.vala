//  
//  Copyright (C) 2011 Christian Dywan <christian@twotoasts.de>
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

namespace Granite.Widgets {

	public class FlowBox : Gtk.Container {
	
		List<Widget> children;
		
		int last_row_count;
		int last_row_height;

		public FlowBox () {
		
			// Widget properties
			set_has_window (false);
		}

		public override void add (Widget widget) {
		
			children.append (widget);
			widget.set_parent (this);
			if (get_realized ())
				widget.realize ();
		}

		public override void remove (Widget widget) {
		
			children.remove (widget);
			widget.unparent ();
			if (widget.get_realized ())
				widget.unrealize ();
			queue_resize ();
		}

		public override void forall_internal (bool internal, Gtk.Callback callback) {
		
			foreach (var child in children)
				callback (child);
		}

		public void reorder_child (Widget widget, int position) {
		
			children.remove (widget);
			children.insert (widget, position);
		}

		public override void map () {
		
			set_mapped (true);
			foreach (var child in children) {
				if (child.visible && !child.get_mapped ())
					child.map ();
			}
		}

		public override void size_allocate (Gtk.Allocation allocation) {
		
			int width = 0;
			int row_count = 1;
			int row_height = 1;

			foreach (var child in children) {
				if (child.visible) {
					Requisition child_size;
					child.get_preferred_size (out child_size, null);
					width += child_size.width;

					if (width > allocation.width && width != child_size.width) {
						row_count++;
						width = child_size.width;
					}
					row_height = int.max (row_height, child_size.height);
				}
			}

			if (last_row_count != row_count || last_row_height != row_height) {
				last_row_count = row_count;
				last_row_height = row_height;
				set_size_request (-1, row_height * row_count);
			}

			width = 0;
			int row = 1;
			foreach (var child in children) {
				if (child.visible) {
					Gtk.Requisition child_size;
					child.get_preferred_size (out child_size, null);
					width += child_size.width;
					if (width > allocation.width && width != child_size.width) {
						row++;
						width = child_size.width;
					}

					var child_allocation = Gtk.Allocation ();
					child_allocation.width = child_size.width;
					child_allocation.height = row_height;
					child_allocation.x = allocation.x + width - child_size.width;
					child_allocation.y = allocation.y + row_height * (row - 1);
					child.size_allocate (child_allocation);
				}
			}
		}
		
	}
	
}

