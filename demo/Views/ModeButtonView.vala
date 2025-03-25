/*
 * Copyright 2011-2021 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class ModeButtonView : Gtk.Box {
    construct {
        var mode_switch_label = new Granite.HeaderLabel ("ModeSwitch");
        mode_switch_label.margin_top = 12;

        var mode_switch = new Granite.ModeSwitch.from_icon_name (
            "display-brightness-symbolic",
            "weather-clear-night-symbolic"
        );
        mode_switch.primary_icon_tooltip_text = ("Light background");
        mode_switch.secondary_icon_tooltip_text = ("Dark background");
        mode_switch.valign = Gtk.Align.CENTER;

        var switchbutton_header = new Granite.HeaderLabel ("SwitchModelButton") {
            margin_top = 12
        };

        var header_switchmodelbutton = new Granite.SwitchModelButton ("Header");
        header_switchmodelbutton.add_css_class (Granite.HeaderLabel.Size.H4.to_string ());

        var switchmodelbutton = new Granite.SwitchModelButton ("Default");

        var description_switchmodelbutton = new Granite.SwitchModelButton ("A SwitchModelButton With A Description") {
            active = true,
            description = "A description of additional affects related to the activation state of this switch"
        };

        var switchbutton_grid = new Gtk.Grid ();
        switchbutton_grid.attach (header_switchmodelbutton, 0, 0);
        switchbutton_grid.attach (switchmodelbutton, 0, 1);
        switchbutton_grid.attach (description_switchmodelbutton, 0, 2);

        var switchbutton_popover = new Gtk.Popover () {
            child = switchbutton_grid,
            has_arrow = false
        };
        switchbutton_popover.add_css_class (Granite.STYLE_CLASS_MENU);

        var popover_button = new Gtk.MenuButton () {
            direction = Gtk.ArrowType.UP
        };
        popover_button.popover = switchbutton_popover;

        spacing = 6;
        orientation = Gtk.Orientation.VERTICAL;
        halign = Gtk.Align.CENTER;
        valign = Gtk.Align.CENTER;
        append (mode_switch_label);
        append (mode_switch);
        append (switchbutton_header);
        append (popover_button);
    }
}
