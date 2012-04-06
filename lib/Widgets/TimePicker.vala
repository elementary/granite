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

    public class TimePicker : SpinButton, Gtk.Buildable {
    
        public string format { get; construct; default = _("%l:%M %p"); }
        
        public DateTime time { get; set; }
        
        construct {
            
            time = new DateTime.now_local ();
            int starting_time = time.get_hour () * 60 + 30; // start at this hour : 30
            set_minutes (starting_time);
        
            // SpinButton properties
            can_focus = false;
            adjustment = new Adjustment (starting_time, 0, 1440, 30, 300, 0);
            climb_rate = 0;
            digits = 0;
            numeric = false; // so the text can be set
            wrap = true;
            notify["time"].connect (on_time_changed);
        }

        public TimePicker.with_format (string format) {
            Object (format: format);
        }

        void on_time_changed () {
            text = time.format (format);
        }
        
        protected override int input (out double new_value) {
            new_value = this.value;
            return 1;
        }

        protected override bool output () {    
            set_minutes ((int) this.value);
            return true;           
        }
        
        protected virtual void set_minutes (int minutes) {
        
            time = time.add_full (0, 0, 0, minutes / 60 - time.get_hour (),
                    minutes % 60 - time.get_minute (), 0);
        }
        
    }

}

