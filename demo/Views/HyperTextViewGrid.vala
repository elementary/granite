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

public class HyperTextViewGrid : Gtk.Grid {
    construct {
        var hypertext_label = new Granite.HeaderLabel ("Hold Ctrl and click to follow the link");
        var hypertext_textview = new Granite.HyperTextView ();
        hypertext_textview.buffer.text = "elementary OS - https://elementary.io/\nThe fast, open and privacy-respecting replacement for Windows and macOS.";

        var hypertext_scrolled_window = new Gtk.ScrolledWindow (null, null) {
            height_request = 300,
            width_request = 600
        };
        hypertext_scrolled_window.add (hypertext_textview);

        margin = 12;
        orientation = Gtk.Orientation.VERTICAL;
        row_spacing = 3;
        halign = Gtk.Align.CENTER;
        valign = Gtk.Align.CENTER;
        vexpand = true;
        add (hypertext_label);
        add (hypertext_scrolled_window);
        show_all ();
    }
}
