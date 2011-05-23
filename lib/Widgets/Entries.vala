//  
//  Copyright (C) 2011 Avi Romanoff, Allen Lowe, Maxwell Barvian
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

    public class HintedEntry : Gtk.Entry {

        public string hint_string;

        public HintedEntry (string hint_string) {
        
            this.hint_string = hint_string;
            
            hint ();
            
            // Signals and callbacks
            focus_in_event.connect (on_focus_in);
            focus_out_event.connect (on_focus_out);
        }

        private bool on_focus_in () {
        
            if (get_text () == "")
                unhint ();
                
            return false;    
        }
        
        private bool on_focus_out () {
        
            if (get_text () == "")
                hint ();
            
            return false;   
        }
        
        protected void hint () {
        
            text = hint_string;
            grey_out ();
        }

        protected void unhint () {
        
            text = "";
            reset_font ();
        }
        
        
        private void grey_out () {
            Gdk.Color gray;
            Gdk.Color.parse ("#999", out gray);
            
            modify_text (Gtk.StateType.NORMAL, gray);
            modify_font (Pango.FontDescription.from_string ("italic"));
        }
        
        private void reset_font () {
        
            Gdk.Color black;
            Gdk.Color.parse ("#444", out black);
            
            modify_text (Gtk.StateType.NORMAL, black);
            modify_font (Pango.FontDescription.from_string ("normal"));
        }
        
        public new string get_text () {
            
            if (text == this.hint_string)
                return "";
            
            return text;        
        }
        
        public new void set_text (string text) {
        
            if (text == "")
                hint();
            else
                unhint();
            
            this.text = text;
        }
        
    }

    public class SearchBar : HintedEntry {

        private bool is_searching = true;

        public SearchBar (string hint_string) {
        
            base (hint_string);
                        
            set_icon_from_stock (EntryIconPosition.PRIMARY, "gtk-find");
            
            // Signals and callbacks
            changed.connect (manage_icon);
            focus_in_event.connect (on_focus_in);
            focus_out_event.connect (on_focus_out);
            icon_press.connect (on_icon_press);
            
        }

        protected new void hint () {
        
            is_searching = false;
            set_icon_from_stock (Gtk.EntryIconPosition.SECONDARY, null);
            base.hint ();
        }
        
        private bool on_focus_in () {
        
            if (!is_searching) {
                unhint ();
                is_searching = false;
            }
            
            return false;
        }

        private bool on_focus_out () {
            
            if (get_text () == "") {
                hint ();
                is_searching = false;
            }
            
            return false;
        }

        private void manage_icon () {
            
            if (text != "")
                set_icon_from_gicon (EntryIconPosition.SECONDARY, new ThemedIcon.with_default_fallbacks ("edit-clear-symbolic"));
            else
                set_icon_from_stock (EntryIconPosition.SECONDARY, null);
        }

        private void on_icon_press (EntryIconPosition position) {
        
            if (position == EntryIconPosition.SECONDARY) {
                is_searching = false;
                text = "";
                set_icon_from_stock (position, null);
                is_searching = true;
            } else {
                if (!is_focus) {
                    is_searching = false;
                    hint ();
                }
            }
        }
        
    }

}
