/*
* Copyright (c) 2017 elementary LLC. (https://elementary.io)
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU Lesser General Public License as published by
* the Free Software Foundation, either version 2.1 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU Library General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/


/**
 * HeaderLabel is a start-aligned Gtk.Label with the Granite H4 style class
 */
public class Granite.HeaderLabel : Gtk.Label {

    /**
     * Create a new HeaderLabel
     */
    public HeaderLabel (string label) {
        Object (
            halign: Gtk.Align.START,
            label: label,
            xalign: 0
        );
    }

    construct {
        get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
    }
}
