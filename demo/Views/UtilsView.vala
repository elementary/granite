/*
* Copyright (c) 2018 elementary, Inc. (https://elementary.io)
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

public class UtilsView : Gtk.Grid {
    private const string CSS = """
        .contrast-demo {
            padding: 0.5em 1em;
        }

        .dark {
            background-color: %s;
            color: %s;
        }

        .light {
            background-color: %s;
            color: %s;
        }
    """;
    private const string DARK_BG = "#273445";
    private const string LIGHT_BG = "#d1ff82";

    construct {
        var tooltip_markup_label = new Gtk.Label ("Markup Accel Tooltips:");
        tooltip_markup_label.halign = Gtk.Align.END;

        var tooltip_button_one = new Gtk.Button.from_icon_name ("mail-reply-all", Gtk.IconSize.LARGE_TOOLBAR);
        tooltip_button_one.tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl><Shift>R"}, "Reply All");

        var tooltip_button_two = new Gtk.Button.with_label ("Label Buttons");
        tooltip_button_two.tooltip_markup = Granite.markup_accel_tooltip ({"<Super>R", "<Ctrl><Shift>Up", "<Ctrl>Return"});

        var contrasting_foreground_color_label = new Gtk.Label ("Contrasting Foreground Color:");
        contrasting_foreground_color_label.halign = Gtk.Align.END;

        var color_demo_dark = new Gtk.Label ("Dark Background");

        var color_demo_dark_context = color_demo_dark.get_style_context ();
        color_demo_dark_context.add_class (Granite.STYLE_CLASS_CARD);
        color_demo_dark_context.add_class ("contrast-demo");
        color_demo_dark_context.add_class ("dark");

        var color_demo_light = new Gtk.Label ("Light Background");

        var color_demo_light_context = color_demo_light.get_style_context ();
        color_demo_light_context.add_class (Granite.STYLE_CLASS_CARD);
        color_demo_light_context.add_class ("contrast-demo");
        color_demo_light_context.add_class ("light");

        halign = valign = Gtk.Align.CENTER;
        column_spacing = 12;
        row_spacing = 12;

        attach (tooltip_markup_label, 0, 0);
        attach (tooltip_button_one, 1, 0);
        attach (tooltip_button_two, 2, 0);
        attach (contrasting_foreground_color_label, 0, 1);
        attach (color_demo_dark, 1, 1);
        attach (color_demo_light, 2, 1);

        var provider = new Gtk.CssProvider ();
        try {
            var gdk_dark_bg = Gdk.RGBA ();
            gdk_dark_bg.parse (DARK_BG);

            var gdk_light_bg = Gdk.RGBA ();
            gdk_light_bg.parse (LIGHT_BG);

            var css = CSS.printf (
                DARK_BG,
                Granite.contrasting_foreground_color (gdk_dark_bg).to_string (),
                LIGHT_BG,
                Granite.contrasting_foreground_color (gdk_light_bg).to_string ()
            );

            provider.load_from_data (css, css.length);
            Gtk.StyleContext.add_provider_for_screen (
                Gdk.Screen.get_default (),
                provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            );
        } catch (GLib.Error e) {
            critical (e.message);
            return;
        }
    }
}
