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
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA.
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
        header4.margin_bottom = 12;
        header4.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);

        var card_label = new Gtk.Label ("\"card\" with \"rounded\" style class:");
        card_label.halign = Gtk.Align.END;

        var card = new Gtk.Grid ();
        card.orientation = Gtk.Orientation.VERTICAL;

        unowned Gtk.StyleContext card_context = card.get_style_context ();
        card_context.add_class (Granite.STYLE_CLASS_CARD);
        card_context.add_class (Granite.STYLE_CLASS_ROUNDED);

        card.add (header1);
        card.add (header2);
        card.add (header3);
        card.add (header4);

        var checker_label = new Gtk.Label ("\"checkerboard\" style class:");

        var checker_image = new Gtk.Image.from_icon_name ("dialog-information", Gtk.IconSize.DND);
        checker_image.hexpand = true;
        checker_image.margin = 6;

        var checker_grid = new Gtk.Grid ();
        checker_grid.get_style_context ().add_class (Granite.STYLE_CLASS_CHECKERBOARD);
        checker_grid.add (checker_image);

        var terminal_label = new Gtk.Label ("\"terminal\" style class:");

        var terminal = new Gtk.TextView ();
        terminal.buffer.text = "[ 73%] Linking C executable granite-demo\n[100%] Built target granite-demo";
        terminal.pixels_below_lines = 3;
        terminal.border_width = 12;
        terminal.get_style_context ().add_class (Granite.STYLE_CLASS_TERMINAL);

        var back_button_label = new Gtk.Label ("\"back-button\" style class:");
        back_button_label.halign = Gtk.Align.END;

        var back_button = new Gtk.Button.with_label ("Back Button");
        back_button.halign = Gtk.Align.START;
        back_button.get_style_context ().add_class (Granite.STYLE_CLASS_BACK_BUTTON);

        var primary_color_label = new Gtk.Label ("Set HeaderBar color:");
        primary_color_label.halign = Gtk.Align.END;

        var primary_color_button = new Gtk.ColorButton.with_rgba ({ 222, 222, 222, 255 });

        var accent_color_label = new Gtk.Label ("Accent colored labels and icons:");
        accent_color_label.halign = Gtk.Align.END;

        var accent_color_icon = new Gtk.Image.from_icon_name ("emoji-body-symbolic", Gtk.IconSize.MENU);
        accent_color_icon.get_style_context ().add_class (Granite.STYLE_CLASS_ACCENT);

        var accent_color_string = new Gtk.Label ("Lorem ipsum dolor sit amet");
        accent_color_string.get_style_context ().add_class (Granite.STYLE_CLASS_ACCENT);

        var accent_color_grid = new Gtk.Grid ();
        accent_color_grid.column_spacing = 6;
        accent_color_grid.add (accent_color_icon);
        accent_color_grid.add (accent_color_string);

        column_spacing = 12;
        row_spacing = 24;
        attach (card_label, 0, 0, 1, 1);
        attach (card, 1, 0, 2, 1);
        attach (checker_label, 0, 1);
        attach (checker_grid, 1, 1, 2, 1);
        attach (terminal_label, 0, 2);
        attach (terminal, 1, 2, 2, 1);
        attach (back_button_label, 0, 3);
        attach (back_button, 1, 3, 2, 1);
        attach (primary_color_label, 0, 4);
        attach (primary_color_button, 1, 4, 2, 1);
        attach (accent_color_label, 0, 5);
        attach (accent_color_grid, 1, 5);

        primary_color_button.color_set.connect (() => {
            Granite.Widgets.Utils.set_color_primary (window, primary_color_button.rgba);
        });
    }
}
