/*
* Copyright 2021 elementary, Inc. (https://elementary.io)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

/**
* Granite.Dialog is a styled {@link Gtk.Dialog} that uses an empty title area and
* action widgets in the bottom/end position.
*
* ''Example''<<BR>>
* {{{
*   var header = new Granite.HeaderLabel ("Header");
*   var entry = new Gtk.Entry ();
*   var gtk_switch = new Gtk.Switch () {
*       halign = Gtk.Align.START
*   };
*
*   var layout = new Gtk.Grid () {
*       row_spacing = 12
*   };
*   layout.attach (header, 0, 1);
*   layout.attach (entry, 0, 2);
*   layout.attach (gtk_switch, 0, 3);
*
*   var dialog = new Granite.Dialog () {
*       transient_for = window
*   };
*   dialog.content_area.add (layout);
*   dialog.add_button ("Cancel", Gtk.ResponseType.CANCEL);
*
*   var suggested_button = dialog.add_button ("Suggested Action", Gtk.ResponseType.ACCEPT);
*   suggested_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
*
*   dialog.show_all ();
*   dialog.response.connect ((response_id) => {
*       if (response_id == Gtk.ResponseType.ACCEPT) {
*           // Do Something
*       }
*
*       dialog.destroy ();
*   });
* }}}
*/
public class Granite.Dialog : Gtk.Dialog {
    /**
     * Constructs a new {@link Granite.Dialog}.
     */
    public Dialog () {

    }

    construct {
        Gtk.Box action_area = get_action_area ();
        Gtk.Box content_area = get_content_area ();

        action_area.get_parent ().remove (action_area);

        var content_area_parent = content_area.get_parent ();
        content_area_parent.remove (content_area);

        deletable = false;
        window_position = Gtk.WindowPosition.CENTER_ON_PARENT;
        use_header_bar = (int) false;

        var grid = new Gtk.Grid () {
           orientation = Gtk.Orientation.VERTICAL
        };
        grid.add (content_area);
        grid.add (action_area);
        grid.show_all ();

        content_area_parent.add (grid);
    }

    public override void constructed () {
        base.constructed ();

        get_style_context ().add_class ("csd");

        var headerbar = new Gtk.HeaderBar () {
            has_subtitle = false
        };
        headerbar.get_style_context ().add_class ("default-decoration");
        headerbar.show ();

        set_titlebar (headerbar);
    }
}
