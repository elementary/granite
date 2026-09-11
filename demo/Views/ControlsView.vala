/*
 * Copyright 2011-2021 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class ControlsView : DemoPage {
    construct {
        var button_header = new Granite.HeaderLabel ("Buttons");

        var textbutton = new Gtk.Button.with_label ("Gtk.Button.with_label ()");

        var toggle_button = new Gtk.ToggleButton.with_label ("Gtk.ToggleButton.with_label ()") {
            active = true
        };

        var imagebutton = new Gtk.Button.from_icon_name ("folder-pictures-symbolic") {
            tooltip_text = "Gtk.Button.from_icon_name ()"
        };

        var toggle_imagebutton = new Gtk.ToggleButton () {
            active = true,
            icon_name = "eye-open-negative-filled-symbolic",
            tooltip_text = "Gtk.ToggleButton.icon_name"
        };

        var reply_menuitem = new GLib.MenuItem ("Reply", null);
        reply_menuitem.set_attribute_value ("verb-icon", "mail-reply-sender-symbolic");

        var reply_all_menuitem = new GLib.MenuItem ("Reply All", null);
        reply_all_menuitem.set_attribute_value ("verb-icon", "mail-reply-all-symbolic");

        var forward_menuitem = new GLib.MenuItem ("Forward", null);
        forward_menuitem.set_attribute_value ("verb-icon", "mail-forward-symbolic");

        var switchbutton_header = new Granite.HeaderLabel ("SwitchModelButton") {
            margin_top = 12
        };

        var header_switchmodelbutton = new Granite.SwitchModelButton ("As a Header");
        header_switchmodelbutton.add_css_class (Granite.HeaderLabel.Size.H4.to_string ());

        var switchmodelbutton = new Granite.SwitchModelButton ("Default");

        var description_switchmodelbutton = new Granite.SwitchModelButton ("With A Description") {
            active = true,
            description = "A description of additional affects related to the activation state of this switch"
        };

        var header_item = new GLib.MenuItem (null, null);
        header_item.set_attribute_value ("custom", "header");

        var switch_item = new GLib.MenuItem (null, null);
        switch_item.set_attribute_value ("custom", "switch");

        var description_switch_item = new GLib.MenuItem (null, null);
        description_switch_item.set_attribute_value ("custom", "description-switch");

        var switch_section = new GLib.Menu ();
        switch_section.append_item (switch_item);
        switch_section.append_item (description_switch_item);
        switch_section.append_item (header_item);

        var button_menu = new GLib.Menu ();
        button_menu.append_item (reply_menuitem);
        button_menu.append_item (reply_all_menuitem);
        button_menu.append_item (forward_menuitem);

        var button_section = new GLib.MenuItem.section (null, button_menu);
        button_section.set_attribute_value ("display-hint", "circular-buttons");

        var menuitem_section = new GLib.Menu ();
        menuitem_section.append ("Move", null);
        menuitem_section.append ("Delete", null);

        var menu_model = new GLib.Menu ();
        menu_model.append_item (button_section);
        menu_model.append_section ("SwitchModelButton", switch_section);
        menu_model.append_section ( null, menuitem_section);

        var menu_button = new Gtk.MenuButton () {
            menu_model = menu_model
        };

        var menu_button_popover = (Gtk.PopoverMenu) menu_button.popover;
        menu_button_popover.add_child (header_switchmodelbutton, "header");
        menu_button_popover.add_child (switchmodelbutton, "switch");
        menu_button_popover.add_child (description_switchmodelbutton, "description-switch");

        var back_button = new Granite.BackButton ("Granite.BackButton") {
            halign = START
        };

        var link_button = new Gtk.LinkButton.with_label (
            "https://valadoc.org/gtk4/Gtk.LinkButton.html",
            "Gtk.LinkButton ()"
        );

        var destructive_button = new Gtk.Button.with_label ("Granite.CssClass.DESTRUCTIVE");
        destructive_button.add_css_class (Granite.CssClass.DESTRUCTIVE);

        var destructive_imagebutton = new Gtk.Button.from_icon_name ("call-stop-symbolic") {
            tooltip_text = "Gtk.Button.from_icon_name () with Granite.CssClass.DESTRUCTIVE"
        };
        destructive_imagebutton.add_css_class (Granite.CssClass.DESTRUCTIVE);

        var suggested_button = new Gtk.Button.with_label ("Granite.CssClass.SUGGESTED");
        suggested_button.add_css_class (Granite.CssClass.SUGGESTED);

        var suggested_imagebutton = new Gtk.Button.from_icon_name ("call-start-symbolic") {
            tooltip_text = "Gtk.Button.from_icon_name () with Granite.CssClass.SUGGESTED"
        };
        suggested_imagebutton.add_css_class (Granite.CssClass.SUGGESTED);

        var text_button_box = new Granite.Box (VERTICAL, HALF);
        text_button_box.append (textbutton);
        text_button_box.append (toggle_button);
        text_button_box.append (destructive_button);
        text_button_box.append (suggested_button);
        text_button_box.append (back_button);
        text_button_box.append (link_button);

        var image_button_box = new Granite.Box (VERTICAL, HALF);
        image_button_box.append (imagebutton);
        image_button_box.append (toggle_imagebutton);
        image_button_box.append (menu_button);
        image_button_box.append (destructive_imagebutton);
        image_button_box.append (suggested_imagebutton);

        var button_box = new Granite.Box (HORIZONTAL, SINGLE);
        button_box.append (text_button_box);
        button_box.append (image_button_box);

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

        var scale_header = new Granite.HeaderLabel ("Scale");

        var hscale = new Gtk.Scale.with_range (HORIZONTAL, 0, 1, 0.01) {
            draw_value = true,
            hexpand = true
        };
        hscale.adjustment.value = 0.5;

        var hprogressbar = new Gtk.ProgressBar ();
        hscale.adjustment.bind_property ("value", hprogressbar, "fraction", SYNC_CREATE);

        var hcontrol_box = new Granite.Box (VERTICAL, DOUBLE);
        hcontrol_box.append (hscale);
        hcontrol_box.append (hprogressbar);

        var vscale = new Gtk.Scale.with_range (VERTICAL, 0, 1, 0.01) {
            height_request = 128,
            has_origin = false
        };
        vscale.adjustment.value = 0.5;

        var vprogressbar = new Gtk.ProgressBar () {
            inverted = true,
            orientation = VERTICAL
        };
        vscale.adjustment.bind_property ("value", vprogressbar, "fraction", SYNC_CREATE);

        var vcontrol_box = new Granite.Box (HORIZONTAL, DOUBLE);
        vcontrol_box.append (vscale);
        vcontrol_box.append (vprogressbar);

        var scale_box = new Granite.Box (HORIZONTAL, DOUBLE);
        scale_box.append (hcontrol_box);
        scale_box.append (vcontrol_box);

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
        box.append (scale_header);
        box.append (scale_box);

        child = box;
    }
}
