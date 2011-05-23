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
    
namespace Granite.Widgets {

    public class Welcome : VBox {
    
        // Signals
        public signal void activated (int index);

        protected new List<Button> children;
        protected VBox options;
        
        public Welcome (string title_text, string subtitle_text) {
        
            children = new List<Button> ();
            options = new Gtk.VBox (false, 6);
        
            // VBox properties
            spacing = 5;
            homogeneous = false;
            
            // Top spacer
            pack_start (new Gtk.VBox (false, 0), true, true, 0);
            
            // Labels
            var title = new Label ("<span weight='heavy' size='15000'>" + title_text + "</span>");
            title.use_markup = true;
            title.set_justify (Justification.CENTER);
            pack_start (title, false, true, 0);
            
            var subtitle = new Label (subtitle_text);
            subtitle.sensitive = false;
            subtitle.set_justify (Justification.CENTER);
            pack_start (subtitle, false, true, 6);
            
            // Options wrapper
            
            var options_wrapper = new HBox (false, 0);
            
            options_wrapper.pack_start (new Gtk.VBox (false, 0), true, true, 0); // left padding
            options_wrapper.pack_start (options, false, false, 0); // actual options
            options_wrapper.pack_end (new Gtk.VBox (false, 0), true, true, 0); // right padding
            
            pack_start (options_wrapper, false, false, 0);
            
            // Bottom spacer
            pack_end (new Gtk.VBox (false, 0), true, true, 0);
        }
        
        public void append (string icon_name, string label_text, string description_text) {
            
            // Button
            var button = new Button ();
            button.set_relief (ReliefStyle.NONE);
            
            // HBox wrapper
            var hbox = new HBox (false, 6);
            
            // Add left image
            var icon = new Image.from_icon_name (icon_name, IconSize.DIALOG);
            hbox.pack_start (icon, false, true, 6);
            
            // Add right vbox
            var vbox = new VBox (false, 0);
            
            vbox.pack_start (new HBox (false, 0), true, true, 0); // top spacing
            
            // Option label
            var label = new Label ("<span weight='medium' size='12500'>" + label_text + "</span>");
            label.use_markup = true;
            label.set_alignment(0.0f, 0.5f);
            vbox.pack_start (label, false, false, 0);
            
            // Description label
            var description = new Label (description_text);
            description.sensitive = false;
            description.set_alignment(0.0f, 0.5f);
            vbox.pack_start (description, false, false, 0);
            
            vbox.pack_end (new Gtk.VBox (false, 0), true, true, 0); // bottom spacing
            
            hbox.pack_start (vbox, false, true, 6);
            
            button.add (hbox);
            children.append (button);
            options.pack_start (button, false, false, 0);
            
            button.button_release_event.connect ( () => {
                int index = children.index (button);
                activated (index); // send signal
                
                return false;
            } );
            
        }
        
        public new void set_sensitive (int index, bool sensitivity) {
            children.nth_data (index).sensitive = sensitivity;
        }
            
    }
    
}

