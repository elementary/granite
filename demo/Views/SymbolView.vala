/*
 * Copyright 2026 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class SymbolView : DemoPage {
    construct {
        title = "Granite.Symbol";

        var symbol_button = new SymbolButton (AUDIO_VOLUME);

        var flowbox = new Gtk.FlowBox () {
            column_spacing = 12,
            row_spacing = 12,
            height_request = 256
        };
        flowbox.append (symbol_button);
        flowbox.add_css_class (Granite.CssClass.CARD);

        var size_header = new Granite.HeaderLabel ("Size");

        var size_scale = new Gtk.Scale.with_range (HORIZONTAL, 16, 128, 1) {
            draw_value = true,
            hexpand = true
        };
        size_scale.adjustment.value = 32;

        var weight_header = new Granite.HeaderLabel ("Weight");

        var weight_scale = new Gtk.Scale.with_range (HORIZONTAL, 100, 800, 100) {
            draw_value = true,
            hexpand = true
        };
        weight_scale.adjustment.value = 300;

        var main_box = new Granite.Box (VERTICAL) {
            margin_top = 12,
            margin_start = 12,
            margin_end = 12,
            margin_bottom = 12
        };
        main_box.append (flowbox);
        main_box.append (size_header);
        main_box.append (size_scale);
        main_box.append (weight_header);
        main_box.append (weight_scale);

        child = main_box;

        size_scale.adjustment.bind_property ("value", symbol_button, "pixel-size", SYNC_CREATE);
        weight_scale.adjustment.bind_property ("value", symbol_button, "weight", SYNC_CREATE);
    }

    private class SymbolButton : Gtk.Button {
        public int pixel_size { get; set; }
        public double weight { get; set; }
        public Granite.SymbolName symbol_name { get; construct; }

        public SymbolButton (Granite.SymbolName symbol_name) {
            Object (symbol_name: symbol_name);
        }

        construct {
            var symbol = new Granite.Symbol (symbol_name);

            child = symbol;
            add_css_class ("image-button");

            bind_property ("pixel-size", symbol, "pixel-size", SYNC_CREATE);
            bind_property ("weight", symbol, "weight", SYNC_CREATE);

            clicked.connect (() => {
                if (symbol.state_index == symbol.states_length - 1) {
                    symbol.state_index = 0;
                    return;
                }

                symbol.state_index++;
            });
        }
    }
}
