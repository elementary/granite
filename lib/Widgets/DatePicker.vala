//  
//  Copyright (C) 2011 Maxwell Barvian
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

    /**
     * This class allows users to pick dates from a calendar.
     *
     */
    public class DatePicker : Gtk.Entry, Gtk.Buildable {
	
        /**
         * Desired format of DatePicker
         *
         */
        public string format { get; construct; default = _("%B %e, %Y"); }
    
        /**
         * Dropdown of DatePicker
         *
         */
        protected Gtk.EventBox dropdown;
        /**
         * The Calendar to create the DatePicker
         *
         */
        protected Calendar calendar;

        PopOver popover;
        
        private DateTime _date;
        /**
         * Current Date
         *
         */
        public DateTime date {
            get { return _date; }
            set {
                _date = value;
                text = _date.format (format);
            }
        }
		
        /**
         * Makes new DatePicker
         *
         */
        construct {
            
            dropdown = new Gtk.EventBox();
            popover = new PopOver();
            ((Gtk.Box)popover.get_content_area()).add(dropdown);
            calendar = new Calendar ();        
            date = new DateTime.now_local ();
        
            // Entry properties
            can_focus = false;
            editable = false; // user can't edit the entry directly
            secondary_icon_gicon = new ThemedIcon.with_default_fallbacks ("office-calendar-symbolic");
            
            dropdown.add_events (EventMask.FOCUS_CHANGE_MASK);
            dropdown.add (calendar);
            
            // Signals and callbacks
            icon_release.connect (on_icon_press);
            calendar.day_selected_double_click.connect (on_calendar_day_selected);
        }

        /**
         * Makes a new DatePicker
         *
         * @param format desired format of new DatePicker
         */
        public DatePicker.with_format (string format) {
            Object (format: format);
        }

        private void on_icon_press (EntryIconPosition position) {
        
            int x, y;
            position_dropdown (out x, out y);
        
            popover.show_all ();
            popover.move_to_coords (x, y);
            popover.present();
            calendar.grab_focus ();
        }
        
        protected virtual void position_dropdown (out int x, out int y) {
        
            Allocation size;
            Requisition calendar_size;
            
            get_allocation (out size);
            calendar.get_preferred_size (out calendar_size, null);
            get_window ().get_origin (out x, out y);
            
            x += size.x + size.width - 10; //size.x - (calendar_size.width - size.width);
            y += size.y + size.height;
            
            //x = x.clamp (0, int.max (0, Screen.width () - calendar_size.width));
            //y = y.clamp (0, int.max (0, Screen.height () - calendar_size.height));
        }
        
        private void on_calendar_day_selected () {
            date = new DateTime.local (calendar.year, calendar.month + 1, calendar.day, 0, 0, 0);
            hide_dropdown ();
        }
        
        private void hide_dropdown () {
        
            popover.hide ();
        }
                
    }

}

