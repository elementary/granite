//  
//  Copyright (C) 2008 Christian Hergert <chris@dronelabs.com>
//  Copyright (C) 2011 Giulio Collura
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
     
    public class ModeButton : HBox {
	  
		public signal void mode_added (int index, Gtk.Widget widget);
		public signal void mode_removed (int index, Gtk.Widget widget);
		public signal void mode_changed (Gtk.Widget widget);
		static CssProvider style_provider;
 
		private int _selected = -1;
		public int selected {
			get {
				return _selected;
			}
			set {
				set_active(value);
			}
		}
 
        public ModeButton () {
        
        
			if(style_provider == null)
			{
			    style_provider = new CssProvider ();
			    try {
				    style_provider.load_from_path (Build.RESOURCES_DIR + "/style/Switcher.css");
			    } catch (Error e) {
				    warning ("Could not add css provider. Some widgets will not look as intended. %s", e.message);
			    }
			}
 
            homogeneous = true;
            spacing = 0;
 
            app_paintable = true;
            set_visual (get_screen ().get_rgba_visual());
 
            can_focus = true;
 
        }
 
        public void append (Gtk.Widget w) {
 
            var button = new ToggleButton ();
            button.add(w);
            //button.width_request = 30;
            button.can_focus = false;
            button.get_style_context ().add_class ("switcher");
			button.get_style_context ().add_provider (style_provider, 600);
 
            button.button_press_event.connect (() => {
 
                int select = get_children ().index (button);
                set_active (select);
                return true;
 
            });
 
            add (button);
            button.show_all ();
            
            mode_added((int)get_children ().length (), w);
 
        }
       
        public void set_active (int new_active) {
 
            if (new_active >= get_children ().length () || _selected == new_active)
                return;
 
            if (_selected >= 0)
                ((ToggleButton) get_children ().nth_data (_selected)).set_active (false);
 
            _selected = new_active;
            ((ToggleButton) get_children ().nth_data (_selected)).set_active (true);
            mode_changed(((ToggleButton) get_children ().nth_data (_selected)).get_child());
 
        }
        
        public new void remove(int number)
        {
            mode_removed(number, null);
            get_children ().nth_data (number).destroy();
        }
 
        public void clear_children () {
 
            foreach (weak Widget button in get_children ()) {
                button.hide ();
                if (button.get_parent () != null)
                    base.remove (button);
            }
            _selected = -1;
 
        }
    }
#if 0
	public class ModeButton : Gtk.EventBox, Gtk.Buildable {

		public new void focus (Gtk.Widget widget) {
		
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
			StyleContext context = get_style_context();
			int width, height;
			float item_x, item_width;

			width = get_allocated_width ();
			height = get_allocated_height ();

			var n_children = (int) box.get_children ().length ();

			context.set_state(Gtk.StateFlags.NORMAL);
			Gtk.render_background(context, cr, 0, 0, width, height);
			Gtk.render_frame(context, cr, 0, 0, width, height);

			if (hovered >= 0 && selected != hovered) {
				if (n_children > 1) {
					item_width = width / n_children;
					item_x = hovered * width/n_children;
				} else {
					item_x = 0;
					item_width = width;
				}

				cr.move_to(item_x, 0);
				cr.line_to(item_x, height);
				cr.line_to(item_x+item_width + 1, height);
				cr.line_to(item_x+item_width + 1, 0);
				cr.clip();

				context.set_state(Gtk.StateFlags.PRELIGHT);
				Gtk.render_background(context, cr, 0, 0, width, height);
				Gtk.render_frame(context, cr, 0, 0, width, height);
			}

			cr.restore();
			cr.save();
			if (_selected >= 0) {
				if (n_children > 1) {
					item_width = width / n_children;
					item_x = _selected * width / n_children;
				} else {
					item_x = 0;
					item_width = width;
				}
				
				cr.move_to (item_x, 0);
				cr.line_to (item_x, height);
				cr.line_to (item_x+item_width + 1, height);
				cr.line_to (item_x+item_width + 1, 0);
				cr.clip ();

				context.set_state(Gtk.StateFlags.ACTIVE);
				Gtk.render_background(context, cr, 0, 0, width, height);
				Gtk.render_frame(context, cr, 0, 0, width, height);
			}

			cr.restore();

			context.set_state(Gtk.StateFlags.NORMAL);
			for(int i = 1; i < n_children; i++)
			{
				Gtk.render_line(context, cr, i*width/n_children, 2, i*width/n_children, height - 2);
			}

			propagate_draw (box, cr);

			return true;
		}
		
	}
#endif
}

