/*
 * Copyright 2017–2021 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

/**
 * SimpleSettingsPage is a widget divided into three sections: a predefined header,
 * a content area, and an action area.
 */

public abstract class Granite.SimpleSettingsPage : Granite.SettingsPage {
    private Gtk.Image header_icon;
    private Gtk.Label description_label;
    private Gtk.Label title_label;
    private string _description;

    /**
     * A {@link Gtk.Box} used as the action area for #this
     */
    public Gtk.Box action_area { get; construct; }

    /**
     * A {@link Gtk.Grid} used as the content area for #this
     */
    public Gtk.Grid content_area { get; construct; }

    /**
     * A {@link Gtk.Switch} that appears in the header area when #this.activatable is #true. #status_switch will be #null when #this.activatable is #false
     */
    public Gtk.Switch? status_switch { get; construct; }

    /**
     * Creates a {@link Gtk.Switch} #status_switch in the header of #this
     */
    public bool activatable { get; construct; }

    /**
     * Creates a {@link Gtk.Label} with a page description in the header of #this
     */
    public string description {
        get {
            return _description;
        }
        construct set {
            if (description_label != null) {
                description_label.label = value;
            }
            _description = value;
        }
    }

    /**
     * An icon name associated with #this
     * Deprecated: Use #SettingsPage.icon_name instead.
     */
    public new string icon_name {
        get {
            return _icon_name;
        }
        construct set {
            if (header_icon != null) {
                header_icon.icon_name = value;
            }
            _icon_name = value;
        }
    }

    /**
     * A title associated with #this
     * Deprecated: Use #SettingsPage.title instead.
     */
    public new string title {
        get {
            return _title;
        }
        construct set {
            if (title_label != null) {
                title_label.label = value;
            }
            _title = value;
        }
    }

    /**
     * Creates a new SimpleSettingsPage
     * Deprecated: Subclass this instead.
     */
    protected SimpleSettingsPage () {

    }

    construct {
        header_icon = new Gtk.Image.from_icon_name (icon_name);
        header_icon.pixel_size = 48;
        header_icon.valign = Gtk.Align.START;

        title_label = new Gtk.Label (title);
        title_label.ellipsize = Pango.EllipsizeMode.END;
        title_label.selectable = true;
        title_label.xalign = 0;
        title_label.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);

        var header_area = new Gtk.Grid ();
        header_area.column_spacing = 12;
        header_area.row_spacing = 3;

        header_area.attach (title_label, 1, 0);

        if (description != null) {
            description_label = new Gtk.Label (description);
            description_label.selectable = true;
            description_label.xalign = 0;
            description_label.wrap = true;

            header_area.attach (header_icon, 0, 0, 1, 2);
            header_area.attach (description_label, 1, 1);
        } else {
            header_area.attach (header_icon, 0, 0);
        }

        if (activatable) {
            status_switch = new Gtk.Switch ();
            status_switch.hexpand = true;
            status_switch.halign = Gtk.Align.END;
            status_switch.valign = Gtk.Align.CENTER;
            header_area.attach (status_switch, 2, 0);
        }

        content_area = new Gtk.Grid ();
        content_area.column_spacing = 12;
        content_area.row_spacing = 12;
        content_area.vexpand = true;

        action_area = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);

        var grid = new Gtk.Box (Gtk.Orientation.VERTICAL, 24) {
            margin_start = 12,
            margin_end = 12,
            margin_top = 12,
            margin_bottom = 12
        };

        grid.append (header_area);
        grid.append (content_area);
        grid.append (action_area);

        child = grid;

        notify["icon-name"].connect (() => {
            if (header_icon != null) {
                header_icon.icon_name = icon_name;
            }
        });

        notify["title"].connect (() => {
            if (title_label != null) {
                title_label.label = title;
            }
        });
    }
}
