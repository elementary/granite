/*
 * Copyright 2018 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

/**
 * ModeSwitch is a selection control for choosing between two options that can be described with an icon.
 *
 * ''Example''<<BR>>
 * {{{
 *   var gtk_settings = Gtk.Settings.get_default ();
 *
 *   var mode_switch = new ModeSwitch.from_icon_name ("display-brightness-symbolic", "weather-clear-night-symbolic");
 *   mode_switch.primary_icon_tooltip_text = _("Light background");
 *   mode_switch.secondary_icon_tooltip_text = _("Dark background");
 *   mode_switch.bind_property ("active", gtk_settings, "gtk_application_prefer_dark_theme");
 * }}}
 */
public class Granite.ModeSwitch : Gtk.Grid {
    /**
     * Whether the {@link Gtk.Switch} widget is pointing to the secondary icon or not.
     */
    public bool active { get; set; }

    /**
     * The {@link GLib.Icon} to use for the primary icon for the switch.
     */
    public GLib.Icon primary_icon_gicon { get; construct set; }

    /**
     * The icon name to use for the primary icon for the switch.
     */
    public string primary_icon_name { get; construct set; }

    /**
     * The contents of the tooltip on the primary icon.
     */
    public string primary_icon_tooltip_text { get; set; }

    /**
     * The {@link GLib.Icon} to use for the secondary icon for the switch.
     */
    public GLib.Icon secondary_icon_gicon { get; construct set; }

    /**
     * The icon name to use for the secondary icon for the switch.
     */
    public string secondary_icon_name { get; construct set; }

    /**
     * The contents of the tooltip on the secondary icon.
     */
    public string secondary_icon_tooltip_text { get; set; }

    /**
     * Constructs a new {@link Granite.ModeSwitch} using {@link GLib.Icon}s.
     *
     * @param primary_icon_gicon The {@link GLib.Icon} to use for the primary icon for the switch.
     * @param secondary_icon_gicon The {@link GLib.Icon} to use for the secondary icon for the switch.
     */
    public ModeSwitch (GLib.Icon primary_icon_gicon, GLib.Icon secondary_icon_gicon) {
        Object (
            primary_icon_gicon: primary_icon_gicon,
            secondary_icon_gicon: secondary_icon_gicon
        );
    }

    /**
     * Constructs a new {@link Granite.ModeSwitch} from icon names.
     *
     * @param primary_icon_name The icon name to use for the primary icon for the switch.
     * @param secondary_icon_name The icon name to use for the secondary icon for the switch.
     */
    public ModeSwitch.from_icon_name (string primary_icon_name, string secondary_icon_name) {
        Object (
            primary_icon_gicon: new ThemedIcon (primary_icon_name),
            secondary_icon_gicon: new ThemedIcon (secondary_icon_name),
            primary_icon_name: primary_icon_name,
            secondary_icon_name: secondary_icon_name
        );
    }

    construct {
        var primary_image = new Gtk.Image ();
        primary_image.pixel_size = 16;

        var primary_icon_box = new Gtk.EventBox ();
        primary_icon_box.add_events (Gdk.EventMask.BUTTON_RELEASE_MASK);
        primary_icon_box.add (primary_image);

        var mode_switch = new Gtk.Switch ();
        mode_switch.valign = Gtk.Align.CENTER;
        mode_switch.get_style_context ().add_class (Granite.STYLE_CLASS_MODE_SWITCH);

        var secondary_icon = new Gtk.Image ();
        secondary_icon.pixel_size = 16;

        var secondary_icon_box = new Gtk.EventBox ();
        secondary_icon_box.add_events (Gdk.EventMask.BUTTON_RELEASE_MASK);
        secondary_icon_box.add (secondary_icon);

        column_spacing = 6;
        add (primary_icon_box);
        add (mode_switch);
        add (secondary_icon_box);

        bind_property ("primary-icon-gicon", primary_image, "gicon", GLib.BindingFlags.SYNC_CREATE);
        bind_property ("primary-icon-name", primary_image, "icon-name", GLib.BindingFlags.SYNC_CREATE);
        bind_property ("primary-icon-tooltip-text", primary_image, "tooltip-text");
        bind_property ("secondary-icon-gicon", secondary_icon, "gicon", GLib.BindingFlags.SYNC_CREATE);
        bind_property ("secondary-icon-name", secondary_icon, "icon_name", GLib.BindingFlags.SYNC_CREATE);
        bind_property ("secondary-icon-tooltip-text", secondary_icon, "tooltip-text");

        this.notify["active"].connect (() => {
            if (Gtk.StateFlags.DIR_RTL in get_state_flags ()) {
                mode_switch.active = !active;
            } else {
                mode_switch.active = active;
            }
        });

        mode_switch.notify["active"].connect (() => {
            if (Gtk.StateFlags.DIR_RTL in get_state_flags ()) {
                active = !mode_switch.active;
            } else {
                active = mode_switch.active;
            }
        });

        primary_icon_box.button_release_event.connect (() => {
            active = false;
            return Gdk.EVENT_STOP;
        });

        secondary_icon_box.button_release_event.connect (() => {
            active = true;
            return Gdk.EVENT_STOP;
        });
    }
}
