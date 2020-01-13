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
            background: %s;
            color: %s;
            text-shadow: none;
        }
    """;
    private const string DARK_BG = "#273445";

    private Gtk.StyleContext demo_label_style_context;

    construct {
        var tooltip_markup_label = new Gtk.Label ("Markup Accel Tooltips:");
        tooltip_markup_label.halign = Gtk.Align.END;

        var tooltip_button_one = new Gtk.Button.from_icon_name ("mail-reply-all", Gtk.IconSize.LARGE_TOOLBAR);
        tooltip_button_one.tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl><Shift>R"}, "Reply All");

        var tooltip_button_two = new Gtk.Button.with_label ("Label Buttons");
        tooltip_button_two.tooltip_markup = Granite.markup_accel_tooltip (
            {"<Super>R", "<Ctrl><Shift>Up", "<Ctrl>Return"}
        );

        var contrasting_foreground_color_label = new Gtk.Label ("Contrasting Foreground Color:");
        contrasting_foreground_color_label.halign = Gtk.Align.END;

        var contrast_demo_button = new Gtk.Button ();
        contrast_demo_button.label = "Contrast Demo";

        demo_label_style_context = contrast_demo_button.get_style_context ();
        demo_label_style_context.add_class ("contrast-demo");
        demo_label_style_context.add_class (Gtk.STYLE_CLASS_FLAT);

        halign = valign = Gtk.Align.CENTER;
        column_spacing = 12;
        row_spacing = 12;

        attach (tooltip_markup_label, 0, 0);
        attach (tooltip_button_one, 1, 0);
        attach (tooltip_button_two, 2, 0);
        attach (contrasting_foreground_color_label, 0, 1);
        attach (contrast_demo_button, 1, 1, 2);

        var gdk_demo_bg = Gdk.RGBA ();
        gdk_demo_bg.parse (DARK_BG);

        style_contrast_demo (gdk_demo_bg);

        contrast_demo_button.clicked.connect (() => {
            var dialog = new Gtk.ColorSelectionDialog ("");
            dialog.deletable = false;
            dialog.transient_for = (Gtk.Window) get_toplevel ();

            unowned Gtk.ColorSelection widget = dialog.get_color_selection ();
            widget.current_rgba = gdk_demo_bg;

            widget.color_changed.connect (() => {
                style_contrast_demo (widget.current_rgba);
                gdk_demo_bg = widget.current_rgba;
            });

            dialog.run ();
            dialog.destroy ();
        });
    }

    private void style_contrast_demo (Gdk.RGBA bg_color) {
        var provider = new Gtk.CssProvider ();
        try {
            var css = CSS.printf (
                bg_color.to_string (),
                Granite.contrasting_foreground_color (bg_color).to_string ()
            );

            provider.load_from_data (css, css.length);
            demo_label_style_context.add_provider (
                provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            );
        } catch (GLib.Error e) {
            critical (e.message);
            return;
        }
    }
}
