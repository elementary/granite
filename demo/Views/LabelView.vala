/*
 * Copyright 2026 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class LabelView : DemoPage {
    construct {
        title = "Labels & Text";

        var style_header = new Granite.HeaderLabel ("Font Styles");

        var numeric = new Gtk.Label ("Granite.CssClass.NUMERIC 123.4") {
            halign = START
        };
        numeric.add_css_class (Granite.CssClass.NUMERIC);

        var mono = new Gtk.Label ("Granite.CssClass.MONOSPACE") {
            halign = START
        };
        mono.add_css_class (Granite.CssClass.MONOSPACE);

        var small = new Gtk.Label ("Granite.CssClass.SMALL") {
            halign = START
        };
        small.add_css_class (Granite.CssClass.SMALL);

        var style_box = new Granite.Box (VERTICAL);
        style_box.append (style_header);
        style_box.append (numeric);
        style_box.append (mono);
        style_box.append (small);

        var header1 = new Granite.HeaderLabel ("H1 HeaderLabel") {
            size = H1,
            secondary_text = "secondary text"
        };

        var header2 = new Granite.HeaderLabel ("H2 HeaderLabel") {
            size = H2,
            secondary_text = "secondary text"
        };

        var header3 = new Granite.HeaderLabel ("H3 HeaderLabel") {
            size = H3,
            secondary_text = "secondary text"
        };

        var header4 = new Granite.HeaderLabel ("H4 HeaderLabel") {
            secondary_text = "secondary text"
        };

        var header_box = new Granite.Box (VERTICAL, NONE) {
            hexpand = true
        };
        header_box.append (header1);
        header_box.append (header2);
        header_box.append (header3);
        header_box.append (header4);

        var color_header = new Granite.HeaderLabel ("Colored labels and icons");

        var accent_color_box = new Granite.Box (HORIZONTAL, HALF);
        accent_color_box.append (new Gtk.Image.from_icon_name ("emoji-body-symbolic"));
        accent_color_box.append (new Gtk.Image.from_icon_name ("face-tired-symbolic"));
        accent_color_box.append (new Gtk.Label ("Granite.CssClass.ACCENT"));
        accent_color_box.add_css_class (Granite.CssClass.ACCENT);

        var success_color_box = new Granite.Box (HORIZONTAL, HALF);
        success_color_box.append (new Gtk.Image.from_icon_name ("process-completed-symbolic"));
        success_color_box.append (new Gtk.Image.from_icon_name ("face-sick-symbolic"));
        success_color_box.append (new Gtk.Label ("Granite.CssClass.SUCCESS"));
        success_color_box.add_css_class (Granite.CssClass.SUCCESS);

        var warning_color_box = new Granite.Box (HORIZONTAL, HALF);
        warning_color_box.append (new Gtk.Image.from_icon_name ("dialog-warning-symbolic"));
        warning_color_box.append (new Gtk.Image.from_icon_name ("face-laugh-symbolic"));
        warning_color_box.append (new Gtk.Label ("Granite.CssClass.WARNING"));
        warning_color_box.add_css_class (Granite.CssClass.WARNING);

        var error_color_box = new Granite.Box (HORIZONTAL, HALF);
        error_color_box.append (new Gtk.Image.from_icon_name ("dialog-error-symbolic"));
        error_color_box.append (new Gtk.Image.from_icon_name ("face-angry-symbolic"));
        error_color_box.append (new Gtk.Label ("Granite.CssClass.ERROR"));
        error_color_box.add_css_class (Granite.CssClass.ERROR);

        var dimmed_box = new Granite.Box (HORIZONTAL, HALF);
        dimmed_box.append (new Gtk.Image.from_icon_name ("adw-tab-icon-missing-symbolic"));
        dimmed_box.append (new Gtk.Image.from_icon_name ("face-plain-symbolic"));
        dimmed_box.append (new Gtk.Label ("Granite.CssClass.DIM"));
        dimmed_box.add_css_class (Granite.CssClass.DIM);

        var color_box = new Granite.Box (VERTICAL);
        color_box.append (color_header);
        color_box.append (accent_color_box);
        color_box.append (success_color_box);
        color_box.append (warning_color_box);
        color_box.append (error_color_box);
        color_box.append (dimmed_box);

        var accellabel_header = new Granite.HeaderLabel ("Granite.AccelLabel");

        var copy_label = new Granite.AccelLabel ("Copy", "<Ctrl>C") {
            margin_top = 6,
            margin_end = 6,
            margin_bottom = 6,
            margin_start = 6
        };

        var copy_label_card = new Granite.Bin () {
            child = copy_label,
            halign = START,
            width_request = 128
        };
        copy_label_card.add_css_class (Granite.CssClass.CARD);

        var accellabel_box = new Granite.Box (VERTICAL, NONE);
        accellabel_box.append (accellabel_header);
        accellabel_box.append (copy_label_card);

        var vbox = new Granite.Box (VERTICAL, DOUBLE) {
            margin_top = 12,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12
        };
        vbox.append (style_box);
        vbox.append (header_box);
        vbox.append (color_box);
        vbox.append (accellabel_box);

        child = vbox;
    }
}
