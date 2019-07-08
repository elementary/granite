/*
 *  Copyright 2019 elementary, Inc. (https://elementary.io)
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
 */

public class ApplicationView : Gtk.Grid {
    construct {
        var progress_visible_label = new Gtk.Label ("Show Progress:");

        var progress_visible_switch = new Gtk.Switch ();
        progress_visible_switch.valign = Gtk.Align.CENTER;

        var progress_scale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 1, 0.05);

        var badge_visible_label = new Gtk.Label ("Show Badge:");

        var badge_visible_switch = new Gtk.Switch ();
        badge_visible_switch.valign = Gtk.Align.CENTER;

        var badge_spin = new Gtk.SpinButton.with_range (0, int64.MAX, 1);

        column_spacing = 12;
        row_spacing = 6;
        orientation = Gtk.Orientation.VERTICAL;
        halign = Gtk.Align.CENTER;
        valign = Gtk.Align.CENTER;
        attach (progress_visible_label, 0, 0);
        attach (progress_visible_switch, 1, 0);
        attach (progress_scale, 2, 0);
        attach (badge_visible_label, 0, 1);
        attach (badge_visible_switch, 1, 1);
        attach (badge_spin, 2, 1);

        progress_visible_switch.bind_property ("active", progress_scale, "sensitive", GLib.BindingFlags.SYNC_CREATE);
        badge_visible_switch.bind_property ("active", badge_spin, "sensitive", GLib.BindingFlags.SYNC_CREATE);

        progress_scale.value_changed.connect (() => {
            Granite.Services.Application.set_progress.begin (progress_scale.get_value (), (obj, res) => {
                try {
                    Granite.Services.Application.set_progress.end (res);
                } catch (GLib.Error e) {
                    critical (e.message);
                }
            });
        });

        progress_visible_switch.notify["active"].connect (() => {
            Granite.Services.Application.set_progress_visible.begin (progress_visible_switch.active, (obj, res) => {
                try {
                    Granite.Services.Application.set_progress_visible.end (res);
                } catch (GLib.Error e) {
                    critical (e.message);
                }
            });
        });

        badge_spin.value_changed.connect (() => {
            Granite.Services.Application.set_badge.begin ((int64)badge_spin.value, (obj, res) => {
                try {
                    Granite.Services.Application.set_badge.end (res);
                } catch (GLib.Error e) {
                    critical (e.message);
                }
            });
        });

        badge_visible_switch.notify["active"].connect (() => {
            Granite.Services.Application.set_badge_visible.begin (badge_visible_switch.active, (obj, res) => {
                try {
                    Granite.Services.Application.set_badge_visible.end (res);
                } catch (GLib.Error e) {
                    critical (e.message);
                }
            });
        });
    }
}
