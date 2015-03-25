/*
 *  Copyright (C) 2014-2015 Granite Developers
 *
 *  This program or library is free software; you can redistribute it
 *  and/or modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation; either
 *  version 3 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 *  Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General
 *  Public License along with this library; if not, write to the
 *  Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 *  Boston, MA 02110-1301 USA.
 *
 *  Authored by:    Artem Anufrij <artem.anufrij@live.de>
 */

public class Granite.Widgets.WelcomeButton : Gtk.Button {

    Gtk.Label button_title;
    Gtk.Label button_description;

    /**
     * Title property of the Welcome Button
     *
     * @since 0.3
     */
    public string title {
        get { return button_title.get_text (); }
        set { button_title.set_text (value); }
    }

    /**
     * Description property of the Welcome Button
     *
     * @since 0.3
     */
    public string description {
        get { return button_description.get_text (); }
        set { button_description.set_text (value); }
    }

    /**
     * Image of the Welcome Button
     *
     * @since 0.3
     */
    public Gtk.Image? icon { get; private set; }

    public WelcomeButton (Gtk.Image? image, string option_text, string description_text) {
        icon = image;

        // Title label
        button_title = new Gtk.Label (option_text);
        button_title.get_style_context ().add_class ("h3");
        button_title.halign = Gtk.Align.START;
        button_title.valign = Gtk.Align.CENTER;

        // Description label
        button_description = new Gtk.Label (description_text);
        button_description.halign = Gtk.Align.START;
        button_description.valign = Gtk.Align.CENTER;
        button_description.set_line_wrap (true);
        button_description.set_line_wrap_mode (Pango.WrapMode.WORD);

        this.set_relief (Gtk.ReliefStyle.NONE);

        // Button contents wrapper
        var button_contents = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 7);

        // Add left image
        if (icon != null) {
            icon.set_pixel_size (48);
            button_contents.pack_start (icon, false, true, 8);
        }

        // Add right text wrapper
        var text_wrapper = new Gtk.Box (Gtk.Orientation.VERTICAL, 3);
        // top spacing
        text_wrapper.pack_start (new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0), true, true, 0);
        text_wrapper.pack_start (button_title, false, false, 0);
        text_wrapper.pack_start (button_description, false, false, 0);
        // bottom spacing
        text_wrapper.pack_end (new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0), true, true, 0);

        button_contents.pack_start (text_wrapper, false, true, 8);

        this.add (button_contents);
    }
}
