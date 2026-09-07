/*
 * Copyright 2026 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class SymbolView : DemoPage {
    construct {
        title = "Granite.Symbol";

        var audio_volume_symbol = new Granite.Symbol (AUDIO_VOLUME);

        var symbol_button = new SymbolButton (audio_volume_symbol);

        var flowbox = new Gtk.FlowBox () {
            column_spacing = 12,
            row_spacing = 12,
            margin_top = 12,
            margin_start = 12,
            margin_end = 12,
            margin_bottom = 12
        };
        flowbox.append (symbol_button);
        flowbox.add_css_class (Granite.CssClass.CARD);

        child = flowbox;
    }

    private class SymbolButton : Gtk.Button {
        public Granite.Symbol symbol { get; construct; }

        public SymbolButton (Granite.Symbol symbol) {
            Object (symbol: symbol);
        }

        construct {
            child = symbol;
            add_css_class ("image-button");

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
