//  
//  Copyright (C) 2011-2012 Corentin Noël <tintou@mailoo.org>, Maxwell Barvian
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

namespace Granite.Widgets {

    /**
     * This widget allows users to easily pick a time.
     */
    public class TimePicker : Gtk.EventBox {  
    
        // Signals
        public signal void time_changed ();
        
        // Constants
        protected const int PADDING = 5;

        private DateTime _time = new DateTime.now_local ();

        /**
         * Current time
         */
        public DateTime time {
            get { return _time; }
            set {
                if (_time.get_minute () != value.get_minute ())
                    _time = normalize_time (value);
                else
                    _time = value;
                text = _time.format (format);
            }
        }
        
        private GLib.DateTime normalize_time (GLib.DateTime given_to_normalize_time) {
            GLib.DateTime to_normalize_time = given_to_normalize_time;
            int rest = to_normalize_time.get_minute ();
            rest = (rest - (((int)(rest*0.1f))*10));
            if ( rest < 5) {
                to_normalize_time = to_normalize_time.add_minutes (-rest);
            }
            else {
                to_normalize_time = to_normalize_time.add_minutes (5-rest);
            }
            return to_normalize_time;
        }

        /**
         * Current format for time
         */
        public string format { get; construct; default = _("%l:%M %p"); }

        private bool _is_pressed = false;
        
        /**
         * Currently pressed
         */
        protected bool is_pressed {
            get { return _is_pressed; }
            set {
                _is_pressed = value;
                if (hovered == 0 || hovered == 1 || hovered == 3 || hovered == 4)
                    container_grid.get_children ().nth_data (hovered).set_state (value ? Gtk.StateType.SELECTED : Gtk.StateType.NORMAL);
                queue_draw ();
            }
        }
        
        private int _hovered = -1;
        protected int hovered {
            get { return _hovered; }
            set {
                _hovered = value;
                queue_draw ();
            }
        }
        
        private Gtk.Grid container_grid;
        
        public Gtk.Label label { get; protected set; }
        public string text {
            get { return label.label; }
            set { label.label = value; }
        }
        
        internal Gtk.Alignment set_paddings (Gtk.Widget widget, int top, int right, int bottom, int left) {

        var alignment = new Gtk.Alignment (0.0f, 0.0f, 1.0f, 1.0f);
        alignment.top_padding = top;
        alignment.right_padding = right;
        alignment.bottom_padding = bottom;
        alignment.left_padding = left;

        alignment.add (widget);
        return alignment;
    }

        /**
         * Creates a new DateSwitcher.
         *
         * @param chars_width The width of the label. Automatic if -1 is given.
         */
        construct {
        
            _time = normalize_time (_time);
            
            // EventBox properties
            events |= Gdk.EventMask.POINTER_MOTION_MASK
                   |  Gdk.EventMask.BUTTON_PRESS_MASK
                   |  Gdk.EventMask.BUTTON_RELEASE_MASK
                   |  Gdk.EventMask.SCROLL_MASK
                   |  Gdk.EventMask.LEAVE_NOTIFY_MASK;
            set_visible_window (false);

            // Initialize everything
            
            if (format == null)
                format =_("%l:%M %p");
            
            container_grid = new Gtk.Grid();
            container_grid.border_width = 0;
            container_grid.set_row_homogeneous (true);
            label = new Gtk.Label ("");
            label.width_chars = -1;
            text = time.format (format);
            
            // Add everything in appropriate order
            container_grid.attach (set_paddings (new Gtk.Arrow (Gtk.ArrowType.LEFT, Gtk.ShadowType.NONE), 0, PADDING/2, 0, PADDING), 
                    0, 0, 1, 1);
            container_grid.attach (set_paddings (new Gtk.Arrow (Gtk.ArrowType.RIGHT, Gtk.ShadowType.NONE), 0, PADDING, 0, PADDING/2),
                    1, 0, 1, 1);
            container_grid.attach (label, 2, 0, 1, 1);
            container_grid.attach (set_paddings (new Gtk.Arrow (Gtk.ArrowType.LEFT, Gtk.ShadowType.NONE), 0, PADDING/2, 0, PADDING), 
                    3, 0, 1, 1);
            container_grid.attach (set_paddings (new Gtk.Arrow (Gtk.ArrowType.RIGHT, Gtk.ShadowType.NONE), 0, PADDING, 0, PADDING/2),
                    4, 0, 1, 1);
            
            add (container_grid);
        }

        public TimePicker.with_format (string format) {
            Object (format: format);
        }

        protected void hours_left_clicked () {
            time = time.add_hours (-1);
            text = time.format (format);
            time_changed ();
        }

        protected void hours_right_clicked () {
        
            time = time.add_hours (1);
            text = time.format (format);
            time_changed ();
        }

        protected void minutes_left_clicked () {
        
            time = time.add_minutes (-5);
            text = time.format (format);
            time_changed ();
        }

        protected void minutes_right_clicked () {
        
            time = time.add_minutes (5);
            text = time.format (format);
            time_changed ();
        }

        protected override bool button_press_event (Gdk.EventButton event) {
        
            is_pressed = (hovered == 0 || hovered == 1 || hovered == 3 || hovered == 4);

            return true;
        }
        
        protected override bool button_release_event (Gdk.EventButton event) {
        
            is_pressed = false;
            if (hovered == 4)
                hours_left_clicked ();
            else if (hovered == 3)
                hours_right_clicked ();
            else if (hovered == 1)
                minutes_left_clicked ();
            else if (hovered == 0)
                minutes_right_clicked ();

            return true;
        }
        
        protected override bool motion_notify_event (Gdk.EventMotion event) {
        
            Gtk.Allocation box_size, hours_left_size, hours_right_size, minutes_left_size, minutes_right_size;
            container_grid.get_allocation (out box_size);
            container_grid.get_children ().nth_data (0).get_allocation (out hours_left_size);
            container_grid.get_children ().nth_data (1).get_allocation (out hours_right_size);
            container_grid.get_children ().nth_data (3).get_allocation (out minutes_left_size);
            container_grid.get_children ().nth_data (4).get_allocation (out minutes_right_size);
            
            double x = event.x + box_size.x;

            if (x > hours_left_size.x && x < hours_left_size.x + hours_left_size.width)
                hovered = 0;
            else if (x > hours_right_size.x && x < hours_right_size.x + hours_right_size.width)
                hovered = 1;
            else if (x > minutes_left_size.x && x < minutes_left_size.x + minutes_left_size.width)
                hovered = 3;
            else if (x > minutes_right_size.x && x < minutes_right_size.x + minutes_right_size.width)
                hovered = 4;
            else
                hovered = -1;

            return true;
        }

        protected override bool leave_notify_event (Gdk.EventCrossing event) {
        
            is_pressed = false;
            hovered = -1;

            return true;
        }

        protected override bool draw (Cairo.Context cr) {
        
            Gtk.Allocation box_size;
            container_grid.get_allocation (out box_size);
            
            style.draw_box (cr, Gtk.StateType.NORMAL, Gtk.ShadowType.ETCHED_OUT, this, "button", 0, 0, box_size.width, box_size.height);
            
            if (hovered == 0 || hovered == 1 || hovered == 3 || hovered == 4) {

                Gtk.Allocation arrow_size;
                container_grid.get_children ().nth_data (hovered).get_allocation (out arrow_size);
                
                cr.save ();

                cr.rectangle (arrow_size.x - box_size.x, 0, arrow_size.width, arrow_size.height);
                cr.clip ();
                
                if (is_pressed)
                    style.draw_box (cr, Gtk.StateType.SELECTED, Gtk.ShadowType.IN, this, "button", 0, 0, box_size.width, box_size.height);
                else
                    style.draw_box (cr, Gtk.StateType.PRELIGHT, Gtk.ShadowType.ETCHED_OUT, this, "button", 0, 0, box_size.width, box_size.height);
                            
                cr.restore ();
            }
            
            propagate_draw (container_grid, cr);
            
            return true;
        }
        
    }
    
}

