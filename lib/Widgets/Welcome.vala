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

public class Granite.Widgets.Welcome : Gtk.EventBox {

    // Signals
    public signal void activated (int index);

    protected new GLib.List<Gtk.Button> children = new GLib.List<Gtk.Button> ();
    protected Gtk.VBox options;

    private CssProvider style_provider;

    public Welcome (string title_text, string subtitle_text) {

        Gtk.Box content = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

        style_provider = new CssProvider ();

        try {
            style_provider.load_from_path (RESOURCES_DIR + "/style/WelcomeScreen.css");
        } catch (Error e) {
            warning ("Could not add CSS provider. Some widgets will not look as intended. %s", e.message);
        }

        var style_context = this.get_style_context();
        style_context.add_class ("WelcomeScreen");
        style_context.add_provider (style_provider, 1000);

        // VBox properties
        content.spacing = 0;
        content.homogeneous = false;

        // Top spacer
        content.pack_start (new Gtk.HBox (false, 0), true, true, 0);

        // Labels
        var title = new Gtk.Label ("<span weight='medium' size='16000'>" + title_text + "</span>");
        
        var main_title_style = title.get_style_context();
        main_title_style.add_class ("main-title");
        main_title_style.add_provider (style_provider, 1000);
        
        title.use_markup = true;
        title.set_justify (Gtk.Justification.CENTER);
        content.pack_start (title, false, true, 0);

        var subtitle = new Gtk.Label ("<span weight='medium' size='13000'>" + subtitle_text + "</span>");
        subtitle.use_markup = true;
        subtitle.sensitive = false;
        subtitle.set_justify (Gtk.Justification.CENTER);
        content.pack_start (subtitle, false, true, 2);

        var subtitle_style = subtitle.get_style_context();
        subtitle_style.add_class("subtitle");
        subtitle_style.add_provider (style_provider, 600);

        // Options wrapper
        this.options = new Gtk.VBox (false, 8);
        var options_wrapper = new Gtk.HBox (false, 0);

        options_wrapper.pack_start (new Gtk.HBox (false, 0), true, true, 0); // left padding
        options_wrapper.pack_start (this.options, false, false, 0); // actual options
        options_wrapper.pack_end (new Gtk.HBox (false, 0), true, true, 0); // right padding

        content.pack_start (options_wrapper, false, false, 20);

        // Bottom spacer
        content.pack_end (new Gtk.HBox (false, 0), true, true, 0);

        add (content);
    }

    public void set_sensitivity(uint index, bool val) {
        if(index < children.length() && children.nth_data(index) is Gtk.Widget)
            children.nth_data(index).set_sensitive(val);
    }

    public void append (string icon_name, string option_text, string description_text) {
        Gtk.Image? icon = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.DIALOG);
        append_from_image (icon, option_text, description_text);
    }

    public void append_from_pixbuf (Gdk.Pixbuf? icon, string option_text, string description_text) {
        var image = new Gtk.Image.from_pixbuf (icon);
        append_from_image (image, option_text, description_text);
    }

    public void append_from_image (Gtk.Image? icon, string option_text, string description_text) {

        // Button
        var button = new Gtk.Button ();
        button.set_relief (Gtk.ReliefStyle.NONE);

        // HBox wrapper
        var hbox = new Gtk.HBox (false, 6);

        // Add left image
        if (icon != null) {
            icon.set_pixel_size (48);
            hbox.pack_start (icon, false, true, 6);
        }

        // Add right vbox
        var vbox = new Gtk.VBox (false, 0);

        vbox.pack_start (new Gtk.HBox (false, 0), true, true, 0); // top spacing

        // Option label
        var label = new Gtk.Label ("<span weight='medium' size='12000'>" + option_text + "</span>");
        var label_style = label.get_style_context();
        label_style.add_class ("option-label");
        label_style.add_provider (style_provider, 600);

        label.use_markup = true;
        label.set_alignment(0.0f, 0.5f);
        vbox.pack_start (label, false, false, 0);

        // Description label
        var description = new Gtk.Label ("<span weight='medium' size='11700'>" + description_text + "</span>");
        description.use_markup = true;
        description.sensitive = false;
        description.set_alignment(0.0f, 0.5f);
        
        vbox.pack_start (description, false, false, 0);

        var description_style = description.get_style_context();        
        description_style.add_class ("subtitle");
        description_style.add_provider (style_provider, 600);

        vbox.pack_end (new Gtk.HBox (false, 0), true, true, 0); // bottom spacing

        hbox.pack_start (vbox, false, true, 6);

        button.add (hbox);
        this.children.append (button);
        options.pack_start (button, false, false, 0);

        button.get_style_context().add_provider (style_provider, 700);

        button.button_release_event.connect ( () => {
            int index = this.children.index (button);
            this.activated (index); // send signal

            return false;
        } );
    }
}


