/*
 * Copyright 2017–2021 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class CSSView : Gtk.Box {
    public Gtk.Window window { get; construct; }

    public CSSView (Gtk.Window window) {
        Object (window: window);
    }

    construct {
        var header1 = new Gtk.Label ("\"title-1\" Style Class") {
            margin_end = 24,
            margin_start = 24,
            margin_top = 12
        };
        header1.add_css_class (Granite.STYLE_CLASS_H1_LABEL);

        var header2 = new Gtk.Label ("\"title-2\" Style Class");
        header2.add_css_class (Granite.STYLE_CLASS_H2_LABEL);

        var header3 = new Gtk.Label ("\"title-3\" Style Class");
        header3.add_css_class (Granite.STYLE_CLASS_H3_LABEL);

        var header4 = new Gtk.Label ("\"title-4\" Style Class") {
            margin_bottom = 12
        };
        header4.add_css_class (Granite.STYLE_CLASS_H4_LABEL);

        var numeric = new Gtk.Label ("\"numeric\" Style Class 123.4") {
            margin_bottom = 12
        };
        numeric.add_css_class (Granite.CssClass.NUMERIC);

        var card_header = new Granite.HeaderLabel ("Cards and Headers") {
            secondary_text = "\"card\" with \"rounded\" and \"checkerboard\" style classes"
        };

        var card = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        card.add_css_class (Granite.STYLE_CLASS_CARD);
        card.add_css_class (Granite.STYLE_CLASS_CHECKERBOARD);
        card.add_css_class (Granite.STYLE_CLASS_ROUNDED);
        card.append (header1);
        card.append (header2);
        card.append (header3);
        card.append (header4);
        card.append (numeric);

        var richlist_label = new Granite.HeaderLabel ("Lists") {
            secondary_text = "\"rich-list\" and \"frame\" style classes"
        };

        var rich_listbox = new Gtk.ListBox () {
            show_separators = true
        };
        rich_listbox.add_css_class (Granite.STYLE_CLASS_RICH_LIST);
        rich_listbox.add_css_class (Granite.STYLE_CLASS_FRAME);
        rich_listbox.append (new Gtk.Label ("Row 1"));
        rich_listbox.append (new Gtk.Label ("Row 2"));
        rich_listbox.append (new Gtk.Label ("Row 3"));

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

        var back_button_label = new Granite.HeaderLabel ("\"back-button\" style class") ;

        var back_button = new Gtk.Button.with_label ("Back Button") {
            halign = Gtk.Align.START
        };
        back_button.add_css_class (Granite.STYLE_CLASS_BACK_BUTTON);

        var scales_header = new Granite.HeaderLabel ("Scales") {
            secondary_text = "\"warmth\" and \"temperature\" style classes"
        };

        var warmth_scale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 3500, 6000, 10) {
            draw_value = false,
            has_origin = false,
            hexpand = true,
            inverted = true
        };
        warmth_scale.set_value (6000);
        warmth_scale.add_css_class (Granite.STYLE_CLASS_WARMTH);

        var temperature_scale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, -16.0f, 16.0f, 1.0) {
            draw_value = false,
            has_origin = false,
            hexpand = true
        };
        temperature_scale.set_value (0);
        temperature_scale.add_css_class (Granite.STYLE_CLASS_TEMPERATURE);

        var primary_color_label = new Granite.HeaderLabel ("Set HeaderBar color");

        var primary_color_button = new Gtk.ColorButton.with_rgba ({ 222, 222, 222, 255 });

        var accent_color_label = new Granite.HeaderLabel ("Colored labels and icons");

        var accent_color_box = new Gtk.Box (HORIZONTAL, 6);
        accent_color_box.append (new Gtk.Image.from_icon_name ("emoji-body-symbolic"));
        accent_color_box.append (new Gtk.Image.from_icon_name ("face-tired-symbolic"));
        accent_color_box.append (new Gtk.Label (".accent"));
        accent_color_box.add_css_class (Granite.STYLE_CLASS_ACCENT);

        var success_color_box = new Gtk.Box (HORIZONTAL, 6);
        success_color_box.append (new Gtk.Image.from_icon_name ("process-completed-symbolic"));
        success_color_box.append (new Gtk.Image.from_icon_name ("face-sick-symbolic"));
        success_color_box.append (new Gtk.Label (".success"));
        success_color_box.add_css_class (Granite.STYLE_CLASS_SUCCESS);

        var warning_color_box = new Gtk.Box (HORIZONTAL, 6);
        warning_color_box.append (new Gtk.Image.from_icon_name ("dialog-warning-symbolic"));
        warning_color_box.append (new Gtk.Image.from_icon_name ("face-laugh-symbolic"));
        warning_color_box.append (new Gtk.Label (".warning"));
        warning_color_box.add_css_class (Granite.STYLE_CLASS_WARNING);

        var error_color_box = new Gtk.Box (HORIZONTAL, 6);
        error_color_box.append (new Gtk.Image.from_icon_name ("dialog-error-symbolic"));
        error_color_box.append (new Gtk.Image.from_icon_name ("face-angry-symbolic"));
        error_color_box.append (new Gtk.Label (".error"));
        error_color_box.add_css_class (Granite.STYLE_CLASS_ERROR);

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12) {
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER,
            margin_top = 24,
            margin_bottom = 24,
            margin_start = 24,
            margin_end = 24,
        };
        box.append (card_header);
        box.append (card);
        box.append (richlist_label);
        box.append (rich_listbox);
        box.append (terminal_label);
        box.append (terminal_scroll);
        box.append (back_button_label);
        box.append (back_button);
        box.append (scales_header);
        box.append (warmth_scale);
        box.append (temperature_scale);
        box.append (primary_color_label);
        box.append (primary_color_button);
        box.append (accent_color_label);
        box.append (accent_color_box);
        box.append (success_color_box);
        box.append (warning_color_box);
        box.append (error_color_box);

        var scrolled = new Gtk.ScrolledWindow () {
            child = box
        };

        append (scrolled);

        primary_color_button.color_set.connect (() => {
            Granite.Widgets.Utils.set_color_primary (window, primary_color_button.rgba);
        });
    }
}
