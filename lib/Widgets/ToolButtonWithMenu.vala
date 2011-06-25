//  
//  Copyright (C) 2011 Avi Romanoff
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

	public class ToolButtonWithMenu : Gtk.ToggleToolButton {
		
		public Menu menu { get; protected set; }
		protected PositionType menu_orientation;

		public ToolButtonWithMenu (Image image, string label, Menu menu, PositionType menu_orientation = Gtk.PositionType.LEFT)
				requires (menu_orientation == PositionType.LEFT || menu_orientation == PositionType.RIGHT) {
			
			this.menu_orientation = menu_orientation;
			icon_widget = image;
			label_widget = new Label (label);
			((Label) label_widget).use_underline = true;
			
			this.menu = menu;
			menu.attach_to_widget (this, null);
			menu.deactivate.connect(() => {
				active = false;
			});

			mnemonic_activate.connect (on_mnemonic_activate);
			menu.deactivate.connect (popdown_menu);
			clicked.connect (on_clicked);
		}

		private bool on_mnemonic_activate (bool group_cycling) {
			
			// ToggleButton always grabs focus away from the editor,
			// so reimplement Widget's version, which only grabs the
			// focus if we are group cycling.
			if (!group_cycling)
				activate ();
			else if (can_focus)
				grab_focus ();

			return true;
		}

		protected new void popup_menu (EventButton? event) {
			
			try {
				menu.popup (null,
							null,
							position_menu,
							(event == null) ? 0 : event.button,
							(event == null) ? get_current_event_time () : event.time);
			} finally {
				// Highlight the parent
				if (menu.attach_widget != null)
					menu.attach_widget.set_state (StateType.SELECTED);
			}
		}

		protected void popdown_menu () {
			
			menu.popdown ();

			// Unhighlight the parent
			if (menu.attach_widget != null)
				menu.attach_widget.set_state (StateType.NORMAL);
		}
		
		public override void show_all () {
			base.show_all ();
			menu.show_all ();
		}

		private void on_clicked () {
			popup_menu (null);
		}

		protected virtual void position_menu (Menu menu, out int x, out int y, out bool push_in) {
			
			if (menu.attach_widget == null || menu.attach_widget.get_window () == null) {
				// Prevent null exception in weird cases
				x = 0;
				y = 0;
				push_in = true;
				return;
			}

			menu.attach_widget.get_window ().get_origin (out x, out y);
			Allocation allocation;
			menu.attach_widget.get_allocation (out allocation);


			x += allocation.x;
			y += allocation.y;

			int width, height;
			menu.get_size_request (out width, out height);

			if (y + height >= menu.attach_widget.get_screen ().get_height ())
				y -= height;
			else
				y += allocation.height;

			push_in = true;
		}
		
	}
	
}

