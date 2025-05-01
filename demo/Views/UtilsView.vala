/*
 * Copyright 2018 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class UtilsView : DemoPage {
    private const string CSS = """
        .contrast-demo {
            background: %s;
            color: %s;
            text-shadow: none;
        }
    """;
    private const string DARK_BG = "#273445";

    construct {
        var tooltip_markup_label = new Gtk.Label ("Markup Accel Tooltips:");
        tooltip_markup_label.halign = Gtk.Align.END;

        var tooltip_button_one = new Gtk.Button.from_icon_name ("mail-reply-all");
        tooltip_button_one.tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl><Shift>R", "R"}, "Reply All");

        var tooltip_button_two = new Gtk.Button.with_label ("Label Buttons");
        tooltip_button_two.tooltip_markup = Granite.markup_accel_tooltip (
            {"<Super>R", "<Ctrl><Shift>Up", "<Ctrl>Return", "<Super>"}
        );

        var contrasting_foreground_color_label = new Gtk.Label ("Contrasting Foreground Color:") {
            halign = END
        };

        var contrast_demo_button = new Gtk.Button.with_label ("Contrast Demo");
        contrast_demo_button.add_css_class ("contrast-demo");

        var grid = new Gtk.Grid () {
            halign = valign = Gtk.Align.CENTER,
            column_spacing = 12,
            row_spacing = 12,
        };
        grid.attach (tooltip_markup_label, 0, 0);
        grid.attach (tooltip_button_one, 1, 0);
        grid.attach (tooltip_button_two, 2, 0);
        grid.attach (contrasting_foreground_color_label, 0, 1);
        grid.attach (contrast_demo_button, 1, 1, 2);

        content = grid;

        var gdk_demo_bg = Gdk.RGBA ();
        gdk_demo_bg.parse (DARK_BG);

        style_contrast_demo (gdk_demo_bg);

        contrast_demo_button.clicked.connect (() => {
            var dialog = new Gtk.ColorDialog ();
            dialog.choose_rgba.begin ((Gtk.Window) get_root (), gdk_demo_bg, null, (obj, res) => {
                try {
                    gdk_demo_bg = dialog.choose_rgba.end (res);
                    style_contrast_demo (gdk_demo_bg);
                } catch (Error e) {
                    debug (e.message);
                }
            });
        });
    }

    private void style_contrast_demo (Gdk.RGBA bg_color) {
        var provider = new Gtk.CssProvider ();
        var css = CSS.printf (
            bg_color.to_string (),
            Granite.contrasting_foreground_color (bg_color).to_string ()
        );

        provider.load_from_string (css);
        Gtk.StyleContext.add_provider_for_display (
            Gdk.Display.get_default (),
            provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );
    }
}
