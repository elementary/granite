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
    private static Gtk.CssProvider? dark_provider = null;
    private static Gtk.CssProvider? app_provider = null;
#if INCLUDE_GTK_STYLESHEETS
    private static Gtk.CssProvider? gtk_base_provider = null;
    private static Gtk.CssProvider? gtk_dark_provider = null;
#endif
    private static HashTable<Gdk.Display, StyleManager>? style_managers_by_displays;

    /**
     * Returns the {@link Granite.StyleManager} that handles the default display
     * as gotten by {@link Gdk.Display.get_default ()}.
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
     * The {@link Granite.Settings.ColorScheme} requested by the application
     * Uses value from {@link Granite.Settings.prefers_color_scheme} when set to {@link Granite.Settings.ColorScheme.NO_PREFERENCE }.
     * Default value is {@link Granite.Settings.ColorScheme.NO_PREFERENCE }
     */
    public Settings.ColorScheme color_scheme { get; set; default = NO_PREFERENCE; }

    /**
     * The {@link Gdk.Display} handled by #this.
     */
    public Gdk.Display display { get; construct; }

    private StyleManager (Gdk.Display display) {
        Object (display: display);
    }

    construct {
        var gtk_settings = Gtk.Settings.get_for_display (display);
#if INCLUDE_GTK_STYLESHEETS
        gtk_settings.gtk_theme_name = "Granite-empty";
#endif
        gtk_settings.notify["gtk-application-prefer-dark-theme"].connect (set_provider_for_display);
        set_provider_for_display ();

        var granite_settings = Granite.Settings.get_default ();
        granite_settings.notify["prefers-color-scheme"].connect (update_color_scheme);
        granite_settings.notify["accent-color"].connect (update_accent_color);
        notify["color-scheme"].connect (update_color_scheme);
        update_color_scheme ();
        update_accent_color ();

        var icon_theme = Gtk.IconTheme.get_for_display (display);
        icon_theme.add_resource_path ("/io/elementary/granite");
    }

    private void set_provider_for_display () {
        if (app_provider == null) {
            unowned GLib.Application? app = Application.get_default ();
            if (app != null) {
                var base_path = app.resource_base_path;
                if (base_path != null) {
                    var base_uri = "resource://" + base_path;
                    var base_file = File.new_for_uri (base_uri);

                    app_provider = init_provider_from_file (base_file.get_child ("Application.css"));
                }
            }

            if (app_provider != null) {
                Gtk.StyleContext.add_provider_for_display (display, app_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            }
        }

        if (Gtk.Settings.get_for_display (display).gtk_application_prefer_dark_theme) {
            if (base_provider != null) {
                Gtk.StyleContext.remove_provider_for_display (display, base_provider);
            }

#if INCLUDE_GTK_STYLESHEETS
            if (gtk_base_provider != null) {
                Gtk.StyleContext.remove_provider_for_display (display, gtk_base_provider);
            }
#endif

            if (dark_provider == null) {
                dark_provider = new Gtk.CssProvider ();
                dark_provider.load_from_resource ("/io/elementary/granite/Granite-dark.css");
            }

#if INCLUDE_GTK_STYLESHEETS
            if (gtk_dark_provider == null) {
                gtk_dark_provider = new Gtk.CssProvider ();
                gtk_dark_provider.load_from_resource ("/io/elementary/granite/Gtk-dark.css");
            }

            Gtk.StyleContext.add_provider_for_display (display, gtk_dark_provider, Gtk.STYLE_PROVIDER_PRIORITY_THEME + 1);
#endif
            Gtk.StyleContext.add_provider_for_display (display, dark_provider, Gtk.STYLE_PROVIDER_PRIORITY_THEME);
        } else {
            if (dark_provider != null) {
                Gtk.StyleContext.remove_provider_for_display (display, dark_provider);
            }

#if INCLUDE_GTK_STYLESHEETS
            if (gtk_dark_provider != null) {
                Gtk.StyleContext.remove_provider_for_display (display, gtk_dark_provider);
            }
#endif

            if (base_provider == null) {
                base_provider = new Gtk.CssProvider ();
                base_provider.load_from_resource ("/io/elementary/granite/Granite.css");
            }

#if INCLUDE_GTK_STYLESHEETS
            if (gtk_base_provider == null) {
                gtk_base_provider = new Gtk.CssProvider ();
                gtk_base_provider.load_from_resource ("/io/elementary/granite/Gtk.css");
            }

            Gtk.StyleContext.add_provider_for_display (display, gtk_base_provider, Gtk.STYLE_PROVIDER_PRIORITY_THEME + 1);
#endif
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
        if (color_scheme == NO_PREFERENCE) {
            var granite_settings = Granite.Settings.get_default ();
            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == DARK;
        } else {
            gtk_settings.gtk_application_prefer_dark_theme = color_scheme == DARK;
        }
    }

    private void update_accent_color () {
        if (accent_provider == null) {
            accent_provider = new Gtk.CssProvider ();
        }

        var accent_color = Granite.Settings.get_default ().accent_color.to_string ();

        Gtk.StyleContext.remove_provider_for_display (display, accent_provider);
        accent_provider.load_from_string ("@define-color accent_color %s;".printf (accent_color));
        Gtk.StyleContext.add_provider_for_display (display, accent_provider, Gtk.STYLE_PROVIDER_PRIORITY_THEME + 2);
    }
}
