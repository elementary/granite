/*
* Copyright 2021 elementary, Inc. (https://elementary.io)
*
* This library is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This library is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public
* License along with this library; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA.
*/

public class HyperTextViewGrid : Gtk.Box {
    construct {
        var hypertext_label = new Gtk.Label ("Hold Ctrl and click to follow the link") {
            halign = Gtk.Align.START,
            xalign = 0
        };
        hypertext_label.add_css_class (Granite.STYLE_CLASS_H4_LABEL);

        var hypertext_textview = new Granite.HyperTextView ();
        hypertext_textview.buffer.text = "elementary OS - https://elementary.io/\nThe fast, open and privacy-respecting replacement for Windows and macOS.";

        var hypertext_scrolled_window = new Gtk.ScrolledWindow () {
            height_request = 300,
            width_request = 600,
            child = hypertext_textview
        };

        margin_start = margin_end = margin_top = margin_bottom = 12;
        orientation = Gtk.Orientation.VERTICAL;
        spacing = 3;
        halign = Gtk.Align.CENTER;
        valign = Gtk.Align.CENTER;
        vexpand = true;
        append (hypertext_label);
        append (hypertext_scrolled_window);
    }
}
