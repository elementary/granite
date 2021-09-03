/*
 * Copyright 2017–2019 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

/**
 * AbstractSettingsPage is a {@link Gtk.ScrolledWindow} subclass with properties used
 * by other Granite settings widgets.
 */
public abstract class Granite.SettingsPage : Gtk.ScrolledWindow {
    protected string _icon_name;
    protected string _title;

    /**
     * Used to display a status icon overlayed on the display_widget in a Granite.SettingsSidebar
     */
    public enum StatusType {
        ERROR,
        OFFLINE,
        SUCCESS,
        WARNING,
        NONE
    }

    /**
     * Selects a colored icon to be displayed in a Granite.SettingsSidebar
     */
    public StatusType status_type { get; set; default = StatusType.NONE; }

    /**
     * A widget to display in place of an icon in a Granite.SettingsSidebar
     */
    public Gtk.Widget? display_widget { get; construct; }

    /**
     * A header to be sorted under in a Granite.SettingsSidebar
     */
    public string? header { get; construct; }

    /**
     * A status string to be displayed underneath the title in a Granite.SettingsSidebar
     */
    public string status { get; set construct; }

    /**
     * An icon name to be displayed in a Granite.SettingsSidebar
     */
    public string? icon_name {
        get {
            return _icon_name;
        }
        construct set {
            _icon_name = value;
        }
    }

    /**
     * A title to be displayed in a Granite.SettingsSidebar
     */
    public string title {
        get {
            return _title;
        }
        construct set {
            _title = value;
        }
    }

    construct {
        hscrollbar_policy = Gtk.PolicyType.NEVER;
    }
}
