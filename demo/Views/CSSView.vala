/*
 * Copyright 2017–2021 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class CSSView : DemoPage {
    public Gtk.Window window { get; construct; }

    public CSSView (Gtk.Window window) {
        Object (window: window);
    }

    construct {
        var header1 = new Granite.HeaderLabel ("H1 HeaderLabel") {
            margin_end = 12,
            margin_start = 12,
            margin_top = 12,
            size = H1,
            secondary_text = "secondary text"
        };

        var header2 = new Granite.HeaderLabel ("H2 HeaderLabel") {
            margin_end = 12,
            margin_start = 12,
            size = H2,
            secondary_text = "secondary text"
        };

        var header3 = new Granite.HeaderLabel ("H3 HeaderLabel") {
            margin_end = 12,
            margin_start = 12,
            size = H3,
            secondary_text = "secondary text"
        };

        var header4 = new Granite.HeaderLabel ("H4 HeaderLabel") {
            margin_end = 12,
            margin_start = 12,
            secondary_text = "secondary text"
        };

        var numeric = new Gtk.Label ("\"Granite.CssClass.NUMERIC\" 123.4") {
            margin_bottom = 12
        };
        numeric.add_css_class (Granite.CssClass.NUMERIC);

        var small = new Gtk.Label ("\"Granite.CssClass.SMALL\"") {
            margin_bottom = 12
        };
        small.add_css_class (Granite.CssClass.SMALL);

        var mono = new Gtk.Label ("\"Granite.CssClass.MONOSPACE\"") {
            margin_bottom = 12
        };
        mono.add_css_class (Granite.CssClass.MONOSPACE);

        var card_header = new Granite.HeaderLabel ("Cards and Headers") {
            secondary_text = "\"Granite.CssClass.CARD\" and \"Granite.CssClass.CHECKERBOARD\""
        };

        var card = new Gtk.Box (VERTICAL, 0) {
            hexpand = true
        };
        card.add_css_class (Granite.CssClass.CARD);
        card.append (header1);
        card.append (header2);
        card.append (header3);
        card.append (header4);
        card.append (numeric);
        card.append (small);
        card.append (mono);

        var card_checkered = new Granite.Bin () {
            child = new Gtk.Image.from_icon_name ("battery-low") {
                halign = CENTER,
                icon_size = LARGE
            },
            hexpand = true
        };
        card_checkered.add_css_class (Granite.CssClass.CARD);
        card_checkered.add_css_class (Granite.CssClass.CHECKERBOARD);

        var card_box = new Gtk.Box (HORIZONTAL, 24);
        card_box.append (card);
        card_box.append (card_checkered);

        var terminal_label = new Granite.HeaderLabel ("\"terminal\" style class");

        var terminal = new Gtk.Label ("[ 73%] Linking C executable granite-demo\n[100%] Built target granite-demo") {
            selectable = true,
            wrap = true,
            xalign = 0,
            yalign = 0
        };

        var terminal_scroll = new Gtk.ScrolledWindow () {
            min_content_height = 70,
            child = terminal
        };
        terminal_scroll.add_css_class (Granite.STYLE_CLASS_TERMINAL);

        var accent_color_label = new Granite.HeaderLabel ("Colored labels and icons");

        var accent_color_box = new Gtk.Box (HORIZONTAL, 6);
        accent_color_box.append (new Gtk.Image.from_icon_name ("emoji-body-symbolic"));
        accent_color_box.append (new Gtk.Image.from_icon_name ("face-tired-symbolic"));
        accent_color_box.append (new Gtk.Label ("Granite.CssClass.ACCENT"));
        accent_color_box.add_css_class (Granite.CssClass.ACCENT);

        var success_color_box = new Gtk.Box (HORIZONTAL, 6);
        success_color_box.append (new Gtk.Image.from_icon_name ("process-completed-symbolic"));
        success_color_box.append (new Gtk.Image.from_icon_name ("face-sick-symbolic"));
        success_color_box.append (new Gtk.Label ("Granite.CssClass.SUCCESS"));
        success_color_box.add_css_class (Granite.CssClass.SUCCESS);

        var warning_color_box = new Gtk.Box (HORIZONTAL, 6);
        warning_color_box.append (new Gtk.Image.from_icon_name ("dialog-warning-symbolic"));
        warning_color_box.append (new Gtk.Image.from_icon_name ("face-laugh-symbolic"));
        warning_color_box.append (new Gtk.Label ("Granite.CssClass.WARNING"));
        warning_color_box.add_css_class (Granite.CssClass.WARNING);

        var error_color_box = new Gtk.Box (HORIZONTAL, 6);
        error_color_box.append (new Gtk.Image.from_icon_name ("dialog-error-symbolic"));
        error_color_box.append (new Gtk.Image.from_icon_name ("face-angry-symbolic"));
        error_color_box.append (new Gtk.Label ("Granite.CssClass.ERROR"));
        error_color_box.add_css_class (Granite.CssClass.ERROR);

        var dimmed_box = new Gtk.Box (HORIZONTAL, 6);
        dimmed_box.append (new Gtk.Image.from_icon_name ("adw-tab-icon-missing-symbolic"));
        dimmed_box.append (new Gtk.Image.from_icon_name ("face-plain-symbolic"));
        dimmed_box.append (new Gtk.Label ("Granite.CssClass.DIM"));
        dimmed_box.add_css_class (Granite.CssClass.DIM);

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12) {
            margin_top = 24,
            margin_bottom = 24,
            margin_start = 24,
            margin_end = 24,
        };
        box.append (card_header);
        box.append (card_box);
        box.append (terminal_label);
        box.append (terminal_scroll);
        box.append (accent_color_label);
        box.append (accent_color_box);
        box.append (success_color_box);
        box.append (warning_color_box);
        box.append (error_color_box);
        box.append (dimmed_box);

        child = box;
    }
}
