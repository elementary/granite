/*
 *  Copyright (C) 2012-2015 Granite Developers (https://launchpad.net/granite)
 *
 *  This program or library is free software; you can redistribute it
 *  and/or modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation; either
 *  version 3 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 *  Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General
 *  Public License along with this library; if not, write to the
 *  Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 *  Boston, MA 02110-1301 USA.
 *
 *  Authored by: Corentin Noël <corentin@elementary.io>
 */

public class Granite.Widgets.AlertView : Gtk.Grid {
    public signal void action_activated ();

    public string title {
        get {
            return title_label.label;
        }
        set {
            title_label.label = value;
        }
    }

    public string description {
        get {
            return description_label.label;
        }
        set {
            description_label.label = value;
        }
    }

    public string icon_name {
        owned get {
            return image.icon_name;
        }
        set {
            image.set_from_icon_name (value, Gtk.IconSize.DIALOG);
        }
    }

    private Gtk.Label title_label;
    private Gtk.Label description_label;
    private Gtk.Image image;
    private Gtk.Button action_button;
    private Gtk.Revealer action_revealer;

    public AlertView (string title, string description, string icon_name) {
        Object (title: title, description: description, icon_name: icon_name);
    }

    construct {
        get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
        row_spacing = 12;
        column_spacing = 12;
        title_label = new Gtk.Label (null);
        title_label.hexpand = true;
        title_label.get_style_context ().add_class ("h2");
        title_label.halign = Gtk.Align.START;
        title_label.valign = Gtk.Align.START;
        description_label = new Gtk.Label (null);
        description_label.hexpand = true;
        description_label.wrap = true;
        description_label.justify = Gtk.Justification.FILL;
        description_label.use_markup = true;
        description_label.halign = Gtk.Align.START;
        description_label.valign = Gtk.Align.START;
        action_button = new Gtk.Button ();
        action_button.margin_top = 12;
        action_revealer = new Gtk.Revealer ();
        action_revealer.add (action_button);
        action_revealer.halign = Gtk.Align.END;
        action_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_UP;
        image = new Gtk.Image ();
        var image_box = new Gtk.EventBox ();
        image_box.halign = Gtk.Align.END;
        image_box.add (image);
        var grid = new Gtk.Grid ();
        attach (image_box, 1, 1, 1, 2);
        attach (title_label, 2, 1, 1, 1);
        attach (description_label, 2, 2, 1, 1);
        attach (action_revealer, 2, 3, 1, 1);
        var left_grid = new Gtk.Grid ();
        left_grid.expand = true;
        attach (left_grid, 0, 0, 1, 1);
        var right_grid = new Gtk.Grid ();
        right_grid.expand = true;
        attach (right_grid, 3, 4, 1, 1);

        action_button.clicked.connect (() => {action_activated ();});
    }

    public void show_action (string label) {
        action_button.label = label;
        action_revealer.set_reveal_child (true);
        action_revealer.show_all ();
    }

    public void hide_action () {
        action_revealer.set_reveal_child (false);
    }
}
