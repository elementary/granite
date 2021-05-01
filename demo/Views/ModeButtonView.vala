// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2011-2017 elementary LLC. (https://elementary.io)
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA.
 *
 * Authored by: Lucas Baudin <xapantu@gmail.com>
 *              Jaap Broekhuizen <jaapz.b@gmail.com>
 *              Victor Eduardo <victoreduardm@gmal.com>
 *              Tom Beckmann <tom@elementary.io>
 *              Corentin Noël <corentin@elementary.io>
 */

public class ModeButtonView : Gtk.Grid {
    construct {
        var mode_button_label = new Gtk.Label ("ModeButton");
        mode_button_label.halign = Gtk.Align.START;
        mode_button_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);

        var icon_mode = new Granite.Widgets.ModeButton ();
        icon_mode.append_icon ("view-grid-symbolic", Gtk.IconSize.BUTTON);
        icon_mode.append_icon ("view-list-symbolic", Gtk.IconSize.BUTTON);
        icon_mode.append_icon ("view-column-symbolic", Gtk.IconSize.BUTTON);

        var text_mode = new Granite.Widgets.ModeButton ();
        text_mode.append_text ("Foo");
        text_mode.append_text ("Bar");

        var clear_button = new Gtk.Button.with_label ("Clear Selected");

        var mode_switch_label = new Gtk.Label ("ModeSwitch");
        mode_switch_label.halign = Gtk.Align.START;
        mode_switch_label.margin_top = 12;
        mode_switch_label.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);

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
        header_switchmodelbutton.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);

        var switchmodelbutton = new Granite.SwitchModelButton ("Default");

        var description_switchmodelbutton = new Granite.SwitchModelButton ("With Description") {
            active = true,
            description = "A description of additional affects related to the activation state of this switch"
        };

        var switchbutton_grid = new Gtk.Grid () {
            margin_top = 3,
            margin_bottom = 3
        };
        switchbutton_grid.attach (header_switchmodelbutton, 0, 0);
        switchbutton_grid.attach (switchmodelbutton, 0, 1);
        switchbutton_grid.attach (description_switchmodelbutton, 0, 2);
        switchbutton_grid.show_all ();

        var switchbutton_popover = new Gtk.Popover (null);
        switchbutton_popover.add (switchbutton_grid);

        var popover_button = new Gtk.MenuButton () {
            direction = Gtk.ArrowType.UP
        };
        popover_button.popover = switchbutton_popover;

        column_spacing = 12;
        row_spacing = 6;
        orientation = Gtk.Orientation.VERTICAL;
        halign = Gtk.Align.CENTER;
        valign = Gtk.Align.CENTER;
        add (mode_button_label);
        add (icon_mode);
        add (text_mode);
        add (clear_button);
        add (mode_switch_label);
        add (mode_switch);
        add (switchbutton_header);
        add (popover_button);

        clear_button.clicked.connect (() => {
            icon_mode.selected = -1;
            text_mode.selected = -1;
        });
    }
}
