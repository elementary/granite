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
                    style_provider.load_from_path (Build.RESOURCES_DIR + "/style/ModeButton.css");
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
            button.get_style_context ().add_class ("modebutton");
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
            mode_removed(number, (get_children ().nth_data (number) as Gtk.Bin).get_child ());
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
        
        protected override bool scroll_event (EventScroll ev) {
            if(ev.direction == Gdk.ScrollDirection.DOWN) {
                selected ++;
            }
            else if (ev.direction == Gdk.ScrollDirection.UP) {
                selected --;
            }

            return false;
        }
    }
}

