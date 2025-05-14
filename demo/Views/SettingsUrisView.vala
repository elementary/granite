/*
 * Copyright 2011-2023 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class SettingsUrisView : DemoPage {
    construct {
        var column = new Granite.Box (VERTICAL) {
            margin_start = 24,
            margin_end = 24,
            margin_top = 24,
            margin_bottom = 24,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER
        };

        column.append (new Gtk.LinkButton.with_label (
            Granite.SettingsUri.LOCATION,
            _("Security & Privacy → Location Services")
        ));

        column.append (new Gtk.LinkButton.with_label (
            Granite.SettingsUri.ONLINE_ACCOUNTS,
            _("Online Accounts")
        ));

        column.append (new Gtk.LinkButton.with_label (
            Granite.SettingsUri.NETWORK,
            _("Network")
        ));

        column.append (new Gtk.LinkButton.with_label (
            Granite.SettingsUri.PERMISSIONS,
            _("Applications → Permissions")
        ));

        column.append (new Gtk.LinkButton.with_label (
            Granite.SettingsUri.NOTIFICATIONS,
            _("Notifications")
        ));

        column.append (new Gtk.LinkButton.with_label (
            Granite.SettingsUri.SOUND_INPUT,
            _("Sound → Input")
        ));

        column.append (new Gtk.LinkButton.with_label (
            Granite.SettingsUri.SHORTCUTS,
            _("Keyboard → Shortcuts → Custom")
        ));

        child = column;
    }
}
