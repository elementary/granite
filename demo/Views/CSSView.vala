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
        var card_header = new Granite.HeaderLabel ("Containers") {
            secondary_text = "\"Granite.CssClass.CARD\" and \"Granite.CssClass.CHECKERBOARD\""
        };

        var card = new Gtk.Box (VERTICAL, 0) {
            height_request = 128,
            hexpand = true
        };
        card.add_css_class (Granite.CssClass.CARD);

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

        var devel_label = new Granite.HeaderLabel ("Miscellaneous");

        var devel_switchmodel = new Granite.SwitchModelButton ("This is a development build!") {
            description = "Granite.CssClass.DEVEL"
        };
        devel_switchmodel.clicked.connect (() => {
            if (devel_switchmodel.active) {
                this.get_root ().add_css_class (Granite.CssClass.DEVEL);
                return;
            }
            this.get_root ().remove_css_class (Granite.CssClass.DEVEL);
        });

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
        box.append (devel_label);
        box.append (devel_switchmodel);

        child = box;
    }
}
