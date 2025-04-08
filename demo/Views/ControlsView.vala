/*
 * Copyright 2011-2021 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class ControlsView : DemoPage {
    construct {
        var button_header = new Granite.HeaderLabel ("Buttons");

        var textbutton = new Gtk.Button.with_label ("Gtk.Button.with_label ()");

        var toggle_button = new Gtk.ToggleButton.with_label ("Gtk.ToggleButton.with_label ()");

        var imagebutton = new Gtk.Button.from_icon_name ("folder-pictures-symbolic") {
            tooltip_text = "Gtk.Button.from_icon_name ()"
        };

        var toggle_imagebutton = new Gtk.ToggleButton () {
            icon_name = "eye-open-negative-filled-symbolic",
            tooltip_text = "Gtk.ToggleButton.icon_name"
        };

        var back_button = new Gtk.Button.with_label ("Granite.CssClass.BACK");
        back_button.add_css_class (Granite.CssClass.BACK);

        var destructive_button = new Gtk.Button.with_label ("Granite.CssClass.DESTRUCTIVE");
        destructive_button.add_css_class (Granite.CssClass.DESTRUCTIVE);

        var suggested_button = new Gtk.Button.with_label ("Granite.CssClass.SUGGESTED");
        suggested_button.add_css_class (Granite.CssClass.SUGGESTED);

        var button_box = new Granite.Box (VERTICAL, HALF);
        button_box.append (textbutton);
        button_box.append (toggle_button);
        button_box.append (back_button);
        button_box.append (destructive_button);
        button_box.append (suggested_button);
        button_box.append (imagebutton);
        button_box.append (toggle_imagebutton);

        var checkradio_header = new Granite.HeaderLabel ("Check & Radio Buttons");

        var checked_checkbutton = new Gtk.CheckButton.with_label ("active") {
            active = true
        };
        var checkbutton = new Gtk.CheckButton.with_label ("inactive");
        var inconsistent_checkbutton = new Gtk.CheckButton.with_label ("inconsistent") {
            inconsistent = true
        };

        var checkbutton_box = new Granite.Box (VERTICAL, HALF);
        checkbutton_box.append (checked_checkbutton);
        checkbutton_box.append (checkbutton);
        checkbutton_box.append (inconsistent_checkbutton);

        var checked_radiobutton = new Gtk.CheckButton.with_label ("active") {
            active = true
        };
        var radiobutton = new Gtk.CheckButton.with_label ("inactive") {
            group = checked_radiobutton
        };
        var inconsistent_radiobutton = new Gtk.CheckButton.with_label ("inconsistent") {
            group = checked_radiobutton,
            inconsistent = true
        };

        var radiobutton_box = new Granite.Box (VERTICAL, HALF);
        radiobutton_box.append (checked_radiobutton);
        radiobutton_box.append (radiobutton);
        radiobutton_box.append (inconsistent_radiobutton);

        var checkradio_box = new Granite.Box (HORIZONTAL);
        checkradio_box.append (checkbutton_box);
        checkradio_box.append (radiobutton_box);

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

        var scale_header = new Granite.HeaderLabel ("Scale");

        var hscale = new Gtk.Scale.with_range (HORIZONTAL, 0, 100, 1) {
            hexpand = true
        };
        hscale.adjustment.value = 50;

        var vscale = new Gtk.Scale.with_range (VERTICAL, 0, 100, 1) {
            height_request = 128,
            has_origin = false
        };
        vscale.adjustment.value = 50;

        var scale_box = new Granite.Box (HORIZONTAL);
        scale_box.append (hscale);
        scale_box.append (vscale);

        var box = new Granite.Box (VERTICAL, NONE) {
            halign = CENTER,
            valign = CENTER,
            margin_bottom = 12
        };

        box.append (button_header);
        box.append (button_box);
        box.append (checkradio_header);
        box.append (checkradio_box);
        box.append (mode_switch_label);
        box.append (mode_switch);
        box.append (switchbutton_header);
        box.append (popover_button);
        box.append (scale_header);
        box.append (scale_box);

        content = box;
    }
}
