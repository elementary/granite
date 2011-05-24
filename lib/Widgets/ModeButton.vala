//  
//  Copyright (C) 2008 Christian Hergert <chris@dronelabs.com>
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

	public class ModeButton : Gtk.EventBox {  
	  
		public signal void mode_added (int index, Widget widget);
		public signal void mode_removed (int index, Widget widget);
		public signal void mode_changed (Widget widget);

		private int _selected = -1;
		public int selected {
			get {
				return _selected;
			}
			set {
				if (value == _selected || value < 0 || value >= box.get_children().length())
					return;

				if (_selected >= 0)
					box.get_children ().nth_data (_selected).set_state (StateType.NORMAL);

				_selected = value;
				box.get_children ().nth_data (_selected).set_state (StateType.SELECTED);
				queue_draw ();

				Widget selectedItem = (value >= 0) ? box.get_children ().nth_data (value) : null;
				mode_changed (selectedItem);
			}
		}
		
		private int _hovered = -1;
		public int hovered {
			get {
				return _hovered;
			}
			set {
				if (value == _hovered || value <= -1 || value >= box.get_children().length())
					return;

				_hovered = value;
				queue_draw ();
			}
		}

		private HBox box;

		public ModeButton () {
		
			events |= Gdk.EventMask.BUTTON_PRESS_MASK
			//	   |  EventMask.VISIBILITY_NOTIFY_MASK
				   | Gdk.EventMask.POINTER_MOTION_MASK
				   | Gdk.EventMask.LEAVE_NOTIFY_MASK; 
			//	   |  EventMask.SCROLL_MASK;

			box = new HBox (true, 1);
			box.border_width = 0;
			add (box);
			box.show ();
			set_visible_window (false);
			
			set_size_request(-1, 24);
		}
		
		public void append (Widget widget) {
		
			box.pack_start (widget, true, true, 3);
			int index = (int) box.get_children ().length () - 2;
			mode_added (index, widget);
		}

		public new void remove (int index) {
		
			Widget child = box.get_children ().nth_data (index);
			box.remove (child);
			if (_selected == index)
				_selected = -1;
			else if (_selected >= index)
				_selected--;
			if (_hovered >= index)
				_hovered--;
			mode_removed (index, child);
			queue_draw ();
		}

		public new void focus (Widget widget) {
		
			int select = box.get_children ().index (widget);

			if (_selected >= 0)
				box.get_children ().nth_data (_selected).set_state (StateType.NORMAL);

			_selected = select;
			widget.set_state (StateType.SELECTED);
			queue_draw ();
		}

		protected override bool scroll_event (EventScroll evnt) {
		
			switch (evnt.direction) {
				case ScrollDirection.UP:
					if (selected < box.get_children().length() - 1)
						selected++;
					break;
				case ScrollDirection.DOWN:
					if (selected > 0)
						selected--;
					break;
			}

			return true;	
		}

		protected override bool button_press_event (EventButton ev) {
		
			int n_children = (int) box.get_children ().length ();
			if (n_children < 1)
				return false;

			Allocation allocation;
			get_allocation (out allocation);	

			double child_size = allocation.width / n_children;
			int i = -1;

			if (child_size > 0)
				i = (int) (ev.x / child_size);
			hovered = i;
			
			if (ev.button != 3) {
				selected = _hovered;
				return true;
			}

			return false;
		}

		protected override bool leave_notify_event (EventCrossing ev) {
			
			_hovered = -1;
			queue_draw ();

			return true;
		}

		protected override bool motion_notify_event (EventMotion evnt) {
		
			int n_children = (int) box.get_children ().length ();
			if (n_children < 1)
				return false;

			Allocation allocation;
			get_allocation (out allocation);	

			double child_size = allocation.width / n_children;
			int i = -1;

			if (child_size > 0)
				i = (int) (evnt.x / child_size);
			hovered = i;

			return true;
		}

		protected override bool draw (Cairo.Context cr) {
		
			int width, height;
			float item_x, item_width;

			width = get_allocated_width ();
			height = get_allocated_height ();

			var n_children = (int) box.get_children ().length ();

			style.draw_box (cr, StateType.NORMAL, ShadowType.ETCHED_OUT, this, "button", 0, 0, width, height);
			if (_selected >= 0) {
				if (n_children > 1) {
					item_width = width / n_children;
					item_x = (item_width * _selected) + 1;
				} else {
					item_x = 0;
					item_width = width;
				}

				cr.move_to (item_x, 0);
				cr.line_to (item_x, height);
				cr.line_to (item_x+item_width, height);
				cr.line_to (item_x+item_width, 0);
				cr.clip ();

				style.draw_box (cr, StateType.SELECTED,
								ShadowType.IN, this, "button",
								0, 0,
								width, height);
			}

			cr.restore();
			cr.save();

			if (hovered >= 0 && selected != hovered) {
				if (n_children > 1) {
					item_width = width / n_children;
					if (hovered == 0)
						item_x = 0;
					else
						item_x = item_width * hovered + 1;
				} else {
					item_x = 0;
					item_width = width;
				}

				cr.move_to(item_x, 0);
				cr.line_to(item_x, height);
				cr.line_to(item_x+item_width, height);
				cr.line_to(item_x+item_width, 0);
				cr.clip();

				style.draw_box (cr, StateType.PRELIGHT,
								ShadowType.ETCHED_OUT, this, "button",
								0, 0,
								width, height);
			}

			cr.restore();

			propagate_draw (box, cr);

			return true;
		}
		
	}
	
}

