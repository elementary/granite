/*
 * Copyright 20205 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class TerminalOutputView: DemoPage {
    construct {
        title = "Terminal Output";
        var terminal = new Granite.TerminalView () {
            autoscroll = true,
            vexpand = true,
            margin_top = 12,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12
        };
        terminal.append_text ("[ 25%] Performing optimization passes\n");
        terminal.append_text ("[ 65%] Inserting nonsense functions to pad binary size\n");
        terminal.append_text ("[ 73%] Linking C executable granite-demo\n");
        terminal.append_text ("[100%] Built target granite-demo\n");

        terminal.add_css_class (Granite.CssClass.CARD);

        child = terminal;
    }

}
