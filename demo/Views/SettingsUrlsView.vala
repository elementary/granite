/*
 * Copyright 2011-2023 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-3.0-or-later
 */

public class SettingsUrlsView : Gtk.Box {
    construct {
        halign = Gtk.Align.CENTER;

        var flow = new Gtk.FlowBox () {
            margin_start = 24,
            margin_end = 24,
            margin_top = 24,
            margin_bottom = 24,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER,
            selection_mode = Gtk.SelectionMode.NONE,
            homogeneous = true,
            min_children_per_line = 3,
            column_spacing = 8,
            row_spacing = 16
        };

        flow.append (new Gtk.LinkButton.with_label (
            Granite.LINK_SETTINGS_APPLICATIONS_DEFAULTS,
            _("Applications → Defaults")
        ));

        flow.append (new Gtk.LinkButton.with_label (
            Granite.LINK_SETTINGS_APPLICATIONS_STARTUP,
            _("Applications → Startup")
        ));

        flow.append (new Gtk.LinkButton.with_label (
            Granite.LINK_SETTINGS_APPLICATIONS_PERMISSIONS,
            _("Applications → Permissions")
        ));

        flow.append (new Gtk.LinkButton.with_label (
            Granite.LINK_SETTINGS_DESKTOP_APPEARANCE_WALLPAPER,
            _("Desktop → Wallpaper")
        ));

        flow.append (new Gtk.LinkButton.with_label (
            Granite.LINK_SETTINGS_DESKTOP_APPEARANCE,
            _("Desktop → Appearance")
        ));

        flow.append (new Gtk.LinkButton.with_label (
            Granite.LINK_SETTINGS_DESKTOP_TEXT,
            _("Desktop → Text")
        ));

        flow.append (new Gtk.LinkButton.with_label (
            Granite.LINK_SETTINGS_DESKTOP_DOCK,
            _("Desktop → Dock & Panel")
        ));

        flow.append (new Gtk.LinkButton.with_label (
            Granite.LINK_SETTINGS_DESKTOP_MULTITASKING,
            _("Desktop → Multitasking")
        ));

        flow.append (new Gtk.LinkButton.with_label (
            Granite.LINK_SETTINGS_LANGUAGE,
            _("Language & Region")
        ));

        flow.append (new Gtk.LinkButton.with_label (
            Granite.LINK_SETTINGS_NOTIFICATIONS,
            _("Notifications")
        ));

        flow.append (new Gtk.LinkButton.with_label (
            Granite.LINK_SETTINGS_PRIVACY,
            _("Security & Privacy → History")
        ));

        flow.append (new Gtk.LinkButton.with_label (
            Granite.LINK_SETTINGS_SECURITY_LOCKING,
            _("Security & Privacy → Locking")
        ));

        flow.append (new Gtk.LinkButton.with_label (
            Granite.LINK_SETTINGS_SECURITY_FIREWALL,
            _("Security & Privacy → Firewall")
        ));

        flow.append (new Gtk.LinkButton.with_label (
            Granite.LINK_SETTINGS_PRIVACY_TRASH,
            _("Security & Privacy → Housekeeping")
        ));

        flow.append (new Gtk.LinkButton.with_label (
            Granite.LINK_SETTINGS_PRIVACY_LOCATION,
            _("Security & Privacy → Location Services")
        ));

        append (flow);
    }
}
