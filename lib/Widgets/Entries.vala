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
        Gdk.RGBA normal_color;
        Gdk.RGBA insensitive_color;

        public HintedEntry (string hint_string) {
        
            this.hint_string = hint_string;
            normal_color = get_style_context().get_color(Gtk.StateFlags.NORMAL);
            insensitive_color = get_style_context().get_color(Gtk.StateFlags.INSENSITIVE);
            
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
            override_font (Pango.FontDescription.from_string ("italic"));
            override_color(Gtk.StateFlags.NORMAL, insensitive_color);
        }
        
        private void reset_font () {
            override_font (Pango.FontDescription.from_string ("normal"));
            override_color(Gtk.StateFlags.NORMAL, normal_color);
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
        private uint timeout_id = 0;

        /**
         * This value handles how much time (in ms) should pass
         * after the user stops typing. By default it is set 
         * to 300 ms.
         **/
        public int pause_delay { get; set; default = 300; }

        /**
         * text_changed () signal is emitted after a short delay,
         * which depends on pause_delay.
         * If you need a synchronous signal without any delay,
         * use changed () method.
         **/
        public signal void text_changed_pause (string text);
        
        /**
         * icon_pressed () signal is emitted after a short delay,
         * which depends on the SearchBar's icon.
         * It can be useful to show something on the icon press,
         * we can show a PopOver, for example.
         **/
        public signal void icon_pressed (Gtk.Widget icon);
        
        public SearchBar (string hint_string) {
        
            base (hint_string);
            
            set_icon_from_stock (EntryIconPosition.PRIMARY, "gtk-find");
            
            // Signals and callbacks
            changed.connect (manage_icon);
            changed.connect_after (on_changed);            
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
                var pix = get_icon_pixbuf (EntryIconPosition.PRIMARY);
                Gtk.Image icon = new Gtk.Image.from_pixbuf (pix);
                icon_pressed (icon);
                if (!is_focus) {
                    is_searching = false;
                    hint ();
                }
            }
        }

        private void on_changed () {

            if (timeout_id > 0)
                Source.remove (timeout_id);

            timeout_id = Timeout.add (pause_delay, emit_text_changed);

        }

        private bool emit_text_changed () {

            var terms = get_text ();
            text_changed_pause (terms); // Emit signal

            return Source.remove (timeout_id);

        }

    }

}