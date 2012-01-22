/*
 * Copyright (c) 2012 Victor Eduardo
 * Copyright (C) 2011 Maxwell Barvian
 *
 * This is a free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * This is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this program; see the file COPYING.  If not,
 * write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 */

using Gtk;

public class Granite.Widgets.Welcome : Gtk.EventBox {

    // Signals
    public signal void activated (int index);

    protected new GLib.List<Gtk.Button> children = new GLib.List<Gtk.Button> ();
    protected Gtk.Box options;

    private enum CaseConversionMode {
        TITLE,
        SENTENCE
    }

    public Welcome (string title_text, string subtitle_text) {
        string _title_text = title_text;
        string _subtitle_text = subtitle_text;
        _title_text = _title_text.replace("&", "&amp;");
        _subtitle_text = _subtitle_text.replace("&", "&amp;");

        Gtk.Box content = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

        // Box properties
        content.homogeneous = false;

        // Top spacer
        content.pack_start (new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0), true, true, 0);

        // Labels
        var title = new Gtk.Label ("<span weight='medium' size='14700'>" + _title_text + "</span>");

        title.get_style_context().add_class ("title");

        title.use_markup = true;
        title.set_justify (Gtk.Justification.CENTER);
        content.pack_start (title, false, true, 0);

        var subtitle = new Gtk.Label ("<span weight='medium' size='11500'>" + _subtitle_text + "</span>");
        subtitle.use_markup = true;
        subtitle.sensitive = false;
        subtitle.set_justify (Gtk.Justification.CENTER);
        content.pack_start (subtitle, false, true, 2);

        subtitle.get_style_context().add_class("subtitle");

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

    public void set_item_visible (uint index, bool val) {
        if(index < children.length () && children.nth_data (index) is Gtk.Widget) {
            children.nth_data(index).set_no_show_all (!val);
            children.nth_data(index).set_visible (val);
        }
    }

    public void remove_item (uint index) {
        if(index < children.length () && children.nth_data (index) is Gtk.Widget) {
            var item = children.nth_data (index);
            item.destroy ();
            children.remove (item);
        }
    }

    public void set_item_sensitivity (uint index, bool val) {
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
        string _option_text = option_text;
        string _description_text = description_text;
        _option_text = _option_text.replace ("&", "&amp;");
        _description_text = _description_text.replace ("&", "&amp;");

        // Option label
        var label = new Gtk.Label ("<span weight='medium' size='11700'>" + _option_text + "</span>");
        label.use_markup = true;
        label.halign = Gtk.Align.START;
        label.valign = Gtk.Align.CENTER;
        label.get_style_context().add_class ("option-title");

        // Description label
        var description = new Gtk.Label ("<span weight='medium' size='11400'>" + _description_text + "</span>");
        description.use_markup = true;
        description.halign = Gtk.Align.START;
        description.valign = Gtk.Align.CENTER;
        description.sensitive = false;
        description.get_style_context().add_class ("option-description");

        // Button
        var button = new Gtk.Button ();
        button.set_relief (Gtk.ReliefStyle.NONE);

        // Button contents wrapper
        var button_contents = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 7);

        // Add left image
        if (image != null) {
            image.set_pixel_size (48);
            button_contents.pack_start (image, false, true, 8);
        }

        // Add right text wrapper
        var text_wrapper = new Gtk.Box (Gtk.Orientation.VERTICAL, 3);
        // top spacing
        text_wrapper.pack_start (new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0), true, true, 0);
        text_wrapper.pack_start (label, false, false, 0);
        text_wrapper.pack_start (description, false, false, 0);
        // bottom spacing
        text_wrapper.pack_end (new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0), true, true, 0);

        button_contents.pack_start (text_wrapper, false, true, 8);

        button.add (button_contents);
        children.append (button);
        options.pack_start (button, false, false, 0);

        button.button_release_event.connect ( () => {
            int index = this.children.index (button);
            activated (index); // send signal
            return false;
        } );
    }
}

