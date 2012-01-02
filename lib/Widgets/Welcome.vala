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
    protected Gtk.Box options;

    private enum CaseConversionMode {
        UPPER_CASE,
        LOWER_CASE,
        TOGGLE_CASE,
        TITLE,
        SENTENCE
    }

    private CssProvider style_provider;

    public Welcome (string title_text, string subtitle_text) {

        string _title_text = modify_text_case (title_text, CaseConversionMode.TITLE);
        string _subtitle_text = modify_text_case (subtitle_text, CaseConversionMode.SENTENCE);

        Gtk.Box content = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

        style_provider = new CssProvider ();

        try {
            style_provider.load_from_path (RESOURCES_DIR + "/style/WelcomeScreen.css");
        } catch (Error e) {
            warning ("WelcomeScreen: Could not add CSS provider. This widget will not look as intended. %s", e.message);
        }

        var style_context = this.get_style_context();
        style_context.add_class ("WelcomeScreen");
        style_context.add_provider (style_provider, 1000);

        // Box properties
        content.homogeneous = false;

        // Top spacer
        content.pack_start (new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0), true, true, 0);

        // Labels
        var title = new Gtk.Label ("<span weight='medium' size='14700'>" + _title_text + "</span>");

        var main_title_style = title.get_style_context();
        main_title_style.add_class ("title");
        main_title_style.add_provider (style_provider, 1000);

        title.use_markup = true;
        title.set_justify (Gtk.Justification.CENTER);
        content.pack_start (title, false, true, 0);

        var subtitle = new Gtk.Label ("<span weight='medium' size='11500'>" + _subtitle_text + "</span>");
        subtitle.use_markup = true;
        subtitle.sensitive = false;
        subtitle.set_justify (Gtk.Justification.CENTER);
        content.pack_start (subtitle, false, true, 2);

        var subtitle_style = subtitle.get_style_context();
        subtitle_style.add_class("subtitle");
        subtitle_style.add_provider (style_provider, 600);

        // Options wrapper
        this.options = new Gtk.Box (Gtk.Orientation.VERTICAL, 8);
        var options_wrapper = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

        options_wrapper.pack_start (new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0), true, true, 0); // left padding
        options_wrapper.pack_start (this.options, false, false, 0); // actual options
        options_wrapper.pack_end (new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0), true, true, 0); // right padding

        content.pack_start (options_wrapper, false, false, 20);

        // Bottom spacer
        content.pack_end (new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0), true, true, 0);

        add (content);
    }

    public void set_sensitivity (uint index, bool val) {
        if(index < children.length () && children.nth_data (index) is Gtk.Widget)
            children.nth_data (index).set_sensitive (val);
    }

    public void append (string icon_name, string option_text, string description_text) {
        Gtk.Image? image = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.DIALOG);
        append_with_image (image, option_text, description_text);
    }

    public void append_with_pixbuf (Gdk.Pixbuf? pixbuf, string option_text, string description_text) {
        var image = new Gtk.Image.from_pixbuf (pixbuf);
        append_with_image (image, option_text, description_text);
    }

    public void append_with_image (Gtk.Image? image, string option_text, string description_text) {

        string _option_text = modify_text_case (option_text, CaseConversionMode.TITLE);
        string _description_text = modify_text_case (description_text, CaseConversionMode.SENTENCE);

        // Option label
        var label = new Gtk.Label ("<span weight='medium' size='11700'>" + _option_text + "</span>");
        label.use_markup = true;
        label.halign = Gtk.Align.START;
        label.valign = Gtk.Align.CENTER;
        label.get_style_context().add_class ("option-title");
        label.get_style_context().add_provider (style_provider, 600);

        // Description label
        var description = new Gtk.Label ("<span weight='medium' size='11400'>" + _description_text + "</span>");
        description.use_markup = true;
        description.halign = Gtk.Align.START;
        description.valign = Gtk.Align.CENTER;
        description.get_style_context().add_class ("option-description");
        description.get_style_context().add_provider (style_provider, 600);

        // Button
        var button = new Gtk.Button ();
        button.set_relief (Gtk.ReliefStyle.NONE);
        button.get_style_context().add_provider (style_provider, 700);

        // Button contents wrapper
        var button_contents = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 7);

        // Add left image
        if (image != null) {
            image.set_pixel_size (48);
            button_contents.pack_start (image, false, true, 8);
        }

        // Add right text wrapper
        var text_wrapper = new Gtk.Box (Gtk.Orientation.VERTICAL, 3);
        text_wrapper.pack_start (new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0), true, true, 0); // top spacing
        text_wrapper.pack_start (label, false, false, 0);
        text_wrapper.pack_start (description, false, false, 0);
        text_wrapper.pack_end (new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0), true, true, 0); // bottom spacing

        button_contents.pack_start (text_wrapper, false, true, 8);

        button.add (button_contents);
        this.children.append (button);
        options.pack_start (button, false, false, 0);

        button.button_release_event.connect ( () => {
            int index = this.children.index (button);
            this.activated (index); // send signal
            return false;
        } );
    }

    private string modify_text_case (string text, CaseConversionMode mode) {

        /**
         * This function will not modify the text if it meets the following conditions: 
         * - @text ends with a dot
         * - @text contains at least one character outside the English alphabet
         */

        var fixed_text = new StringBuilder ();
        unichar c;

        // Disabling this feature for other languages
        for (int i = 0; text.get_next_char (ref i, out c);) {
            if (c.isgraph () && !('a' <= c.tolower () && c.tolower () <= 'z'))
            	return text;
        }
        
        if (c == '.')
        	return text;

        switch (mode) {
            case CaseConversionMode.UPPER_CASE:
                for (int i = 0; text.get_next_char (ref i, out c);) {
                    if (c.islower ())
                        fixed_text.append_unichar (c.toupper ());
                    else
                        fixed_text.append_unichar (c);
                }
                break;
            case CaseConversionMode.LOWER_CASE:
                for (int i = 0; text.get_next_char (ref i, out c);) {
                    if (c.isupper ())
                        fixed_text.append_unichar (c.tolower ());
                    else
                        fixed_text.append_unichar (c);
                }
                break;
            case CaseConversionMode.TOGGLE_CASE:
                for (int i = 0; text.get_next_char (ref i, out c);) {
                    if (c.islower ())
                        fixed_text.append_unichar (c.toupper ());
                    else if (c.isupper ())
                        fixed_text.append_unichar (c.tolower ());
                    else
                        fixed_text.append_unichar (c);
                }
                break;
            case CaseConversionMode.TITLE:
                unichar last_char = ' ';
                for (int i = 0; text.get_next_char (ref i, out c);) {
                    if (last_char.isspace () && c.islower ())
                        fixed_text.append_unichar (c.totitle ());
                    else
                        fixed_text.append_unichar (c);

                    last_char = c;
                }
                break;
            case CaseConversionMode.SENTENCE:
                bool fixed = false;
                unichar last_char = ' ';
                for (int i = 0; text.get_next_char (ref i, out c);) {
                    if (!fixed && last_char.isspace ()) {
                        if (c.islower ())
                            fixed_text.append_unichar (c.totitle ());
                        else
                            fixed_text.append_unichar (c);
                        fixed = true;
                    }
                    else {
                        fixed_text.append_unichar (c);
                    }
                }
                fixed_text.append_unichar ('.');
                break;
        }

        return fixed_text.str;
    }
}


