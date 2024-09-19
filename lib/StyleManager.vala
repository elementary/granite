/*
 * Copyright 2024 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

/**
 * A class for managing the style of the application. This handles switching light and dark mode based
 * based on system preference or application preference (see {@link color_scheme_override}), etc.
 */
public class Granite.StyleManager : Object {
    private static Gtk.CssProvider? base_provider = null;
    private static Gtk.CssProvider? dark_provider = null;
    private static Gtk.CssProvider? app_provider = null;

    private static HashTable<Gdk.Display, StyleManager> style_managers_by_displays = new HashTable<Gdk.Display, StyleManager> (null, null);

    public static unowned StyleManager get_default () {
        return style_managers_by_displays[Gdk.Display.get_default ()];
    }

    public static unowned StyleManager get_for_display (Gdk.Display display) {
        return style_managers_by_displays[display];
    }

    internal static void init_for_display (Gdk.Display display) {
        style_managers_by_displays[display] = new StyleManager (display);
    }

    /**
     * If this is set to NO_PREFERENCE the systems preferred color scheme will be used.
     * Otherwise the color scheme set here will be used.
     * Default is NO_PREFERENCE.
     */
    public Settings.ColorScheme color_scheme_override { get; set; default = NO_PREFERENCE; }

    /**
     * The Gdk.Display this StyleManager handles.
     */
    public Gdk.Display display { get; construct; }

    private StyleManager (Gdk.Display display) {
        Object (display: display);
    }

    construct {
        var gtk_settings = Gtk.Settings.get_for_display (display);
        gtk_settings.notify["gtk-application-prefer-dark-theme"].connect (set_provider_for_display);
        set_provider_for_display ();

        var granite_settings = Granite.Settings.get_default ();
        granite_settings.notify["prefers-color-scheme"].connect (update_color_scheme);
        notify["color-scheme-override"].connect (update_color_scheme);
        update_color_scheme ();

        var icon_theme = Gtk.IconTheme.get_for_display (display);
        icon_theme.add_resource_path ("/io/elementary/granite");
    }

    private void set_provider_for_display () {
        if (app_provider == null) {
            var base_path = Application.get_default ().resource_base_path;
            if (base_path != null) {
                var base_uri = "resource://" + base_path;
                var base_file = File.new_for_uri (base_uri);

                app_provider = init_provider_from_file (base_file.get_child ("Application.css"));
            }

            if (app_provider != null) {
                Gtk.StyleContext.add_provider_for_display (display, app_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            }
        }

        if (Gtk.Settings.get_for_display (display).gtk_application_prefer_dark_theme) {
            if (base_provider != null) {
                Gtk.StyleContext.remove_provider_for_display (display, base_provider);
            }

            if (dark_provider == null) {
                dark_provider = new Gtk.CssProvider ();
                dark_provider.load_from_resource ("/io/elementary/granite/Granite-dark.css");
            }

            Gtk.StyleContext.add_provider_for_display (display, dark_provider, Gtk.STYLE_PROVIDER_PRIORITY_THEME);
        } else {
            if (dark_provider != null) {
                Gtk.StyleContext.remove_provider_for_display (display, dark_provider);
            }

            if (base_provider == null) {
                base_provider = new Gtk.CssProvider ();
                base_provider.load_from_resource ("/io/elementary/granite/Granite.css");
            }

            Gtk.StyleContext.add_provider_for_display (display, base_provider, Gtk.STYLE_PROVIDER_PRIORITY_THEME);
        }
    }

    private Gtk.CssProvider? init_provider_from_file (File file) {
        if (file.query_exists ()) {
            var provider = new Gtk.CssProvider ();
            provider.load_from_file (file);

            return provider;
        }

        return null;
    }

    private void update_color_scheme () {
        var gtk_settings = Gtk.Settings.get_for_display (display);
        if (color_scheme_override == NO_PREFERENCE) {
            var granite_settings = Granite.Settings.get_default ();
            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == DARK;
        } else {
            gtk_settings.gtk_application_prefer_dark_theme = color_scheme_override == DARK;
        }
    }
}
