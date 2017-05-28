/*-
 * Copyright (c) 2017 elementary LLC. (https://elementary.io)
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
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

public class CSSView : Gtk.Grid {
    public Gtk.Window window { get; construct; }

    public CSSView (Gtk.Window window) {
        Object (halign: Gtk.Align.CENTER,
                valign: Gtk.Align.CENTER,
                margin: 24,
                window: window);
    }

    construct {
        var header1 = new Gtk.Label ("\"h1\" Style Class");
        header1.margin_top = 12;
        header1.margin_start = 24;
        header1.margin_end = 24;
        header1.get_style_context ().add_class (Granite.STYLE_CLASS_H1_LABEL);

        var header2 = new Gtk.Label ("\"h2\" Style Class");
        header2.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);

        var header3 = new Gtk.Label ("\"h3\" Style Class");
        header3.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);

        var header4 = new Gtk.Label ("\"h4\" Style Class");
        header4.margin_bottom = 12  ;
        header4.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);

        var card_label = new Gtk.Label ("\"card\" style class:");
        card_label.halign = Gtk.Align.END;

        var card = new Gtk.Grid ();
        card.orientation = Gtk.Orientation.VERTICAL;
        card.get_style_context ().add_class (Granite.STYLE_CLASS_CARD);
        card.add (header1);
        card.add (header2);
        card.add (header3);
        card.add (header4);

        var back_button_label = new Gtk.Label ("\"back-button\" style class:");
        back_button_label.halign = Gtk.Align.END;

        var back_button = new Gtk.Button.with_label ("Back Button");
        back_button.halign = Gtk.Align.START;
        back_button.get_style_context ().add_class (Granite.STYLE_CLASS_BACK_BUTTON);

        var primary_color_label = new Gtk.Label ("Set HeaderBar color:");
        primary_color_label.halign = Gtk.Align.END;

        var primary_color_button = new Gtk.ColorButton.with_rgba ({ 222, 222, 222, 255 });

        column_spacing = 12;
        row_spacing = 24;
        attach (card_label, 0, 0, 1, 1);
        attach (card, 1, 0, 1, 1);
        attach (back_button_label, 0, 1, 1, 1);
        attach (back_button, 1, 1, 1, 1);
        attach (primary_color_label, 0, 2, 1, 1);
        attach (primary_color_button, 1, 2, 1, 1);

        primary_color_button.color_set.connect (() => {
            Granite.Widgets.Utils.set_color_primary (window, primary_color_button.rgba);
        });
    }
}
