/*
 * Copyright 2024 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

/**
 * A class for managing the style of the application. This handles switching light and dark mode based
 * based on system preference or application preference (see {@link color_scheme}), etc.
 */
[Version (since = "7.7.0")]
public class Granite.StyleManager : Object {
    private static Gtk.CssProvider? accent_provider = null;
    private static Gtk.CssProvider? base_provider = null;
    private static Gtk.CssProvider? app_provider = null;
    private static HashTable<Gdk.Display, StyleManager>? style_managers_by_displays;

    /**
     * Returns the {@link Granite.StyleManager} that handles the default display
     * as gotten by {@link Gdk.Display.get_default}.
     */
    public static unowned StyleManager get_default () {
        return style_managers_by_displays[Gdk.Display.get_default ()];
    }

    /**
     * Returns the {@link Granite.StyleManager} that handles the given {@link Gdk.Display}.
     */
    public static unowned StyleManager get_for_display (Gdk.Display display) {
        return style_managers_by_displays[display];
    }

    internal static void init_for_display (Gdk.Display display) {
        if (style_managers_by_displays == null) {
            style_managers_by_displays = new HashTable<Gdk.Display, StyleManager> (null, null);
        }

        style_managers_by_displays[display] = new StyleManager (display);
    }

    /**
     * The {@link Gtk.InterfaceColorScheme} requested by the application
     * Uses value from {@link Gtk.Settings.gtk_interface_color_scheme} when set to {@link Gtk.InterfaceColorScheme.DEFAULT}.
     * Default value is {@link Granite.Settings.ColorScheme.NO_PREFERENCE}
     */
    public Gtk.InterfaceColorScheme color_scheme { get; set; default = DEFAULT; }

    /**
     * The {@link Gdk.Display} handled by #this.
     */
    public Gdk.Display display { get; construct; }

    private StyleManager (Gdk.Display display) {
        Object (display: display);
    }

    static construct {
        base_provider = new Gtk.CssProvider ();
        base_provider.load_from_resource ("/io/elementary/granite/Gtk.css");

        unowned GLib.Application? app = Application.get_default ();
        if (app != null) {
            var app_path = app.resource_base_path;
            if (app_path != null) {
                var resource_uri = "resource://" + app_path;
                var file = File.new_for_uri (resource_uri).get_child ("Application.css");

                if (file.query_exists ()) {
                    app_provider = new Gtk.CssProvider ();
                    app_provider.load_from_file (file);
                }
            }
        }
    }

    construct {
        Gtk.StyleContext.add_provider_for_display (display, base_provider, Gtk.STYLE_PROVIDER_PRIORITY_THEME);

        if (app_provider != null) {
            Gtk.StyleContext.add_provider_for_display (display, app_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        }

        var gtk_settings = Gtk.Settings.get_for_display (display);
        gtk_settings.gtk_theme_name = "Granite-empty";
        gtk_settings.notify["gtk-interface-color-scheme"].connect (update_color_scheme);

        var granite_settings = Granite.Settings.get_default ();
        granite_settings.notify["accent-color"].connect (update_accent_color);
        notify["color-scheme"].connect (update_color_scheme);

        update_accent_color ();
        update_color_scheme ();

        var icon_theme = Gtk.IconTheme.get_for_display (display);
        icon_theme.add_resource_path ("/io/elementary/granite");
    }

    private void update_color_scheme () {
        Gtk.InterfaceColorScheme provider_color_scheme = LIGHT;
        if (color_scheme == DARK || (color_scheme == DEFAULT && Gtk.Settings.get_for_display (display).gtk_interface_color_scheme == DARK)) {
            provider_color_scheme = DARK;
        }

        base_provider.prefers_color_scheme = provider_color_scheme;
        if (app_provider != null) {
            app_provider.prefers_color_scheme = provider_color_scheme;
        }
    }

    private void update_accent_color () {
        if (accent_provider == null) {
            accent_provider = new Gtk.CssProvider ();
        }

        var accent_color = Granite.Settings.get_default ().accent_color.to_string ();

        Gtk.StyleContext.remove_provider_for_display (display, accent_provider);
        accent_provider.load_from_string (":root { --accent-color: %s; }".printf (accent_color));
        Gtk.StyleContext.add_provider_for_display (display, accent_provider, Gtk.STYLE_PROVIDER_PRIORITY_THEME + 2);
    }
}
