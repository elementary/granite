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

    private static GLib.Once<Granite.StyleManager> instance;
    public static unowned Granite.StyleManager get_default () {
        return instance.once (() => {
            return new Granite.StyleManager ();
        });
    }

    /**
     * If this is set to NO_PREFERENCE the systems preferred color scheme will be used.
     * Otherwise the color scheme set here will be used.
     */
    public Settings.ColorScheme color_scheme_override { get; set; default = NO_PREFERENCE; }

    private StyleManager () { }

    construct {
        unowned var display_manager = Gdk.DisplayManager.@get ();
        display_manager.display_opened.connect (register_display);

        foreach (unowned var display in display_manager.list_displays ()) {
            register_display (display);
        }

        Granite.Settings.get_default ().notify["prefers-color-scheme"].connect (update_color_scheme);
        update_color_scheme ();

        notify["color-scheme-override"].connect (update_color_scheme);
    }

    private void register_display (Gdk.Display display) {
        var gtk_settings = Gtk.Settings.get_for_display (display);
        gtk_settings.gtk_application_prefer_dark_theme = prefers_dark ();
        gtk_settings.notify["gtk-application-prefer-dark-theme"].connect (() => {
            set_provider_for_display (display, gtk_settings.gtk_application_prefer_dark_theme);
        });

        set_provider_for_display (display, gtk_settings.gtk_application_prefer_dark_theme);

        var icon_theme = Gtk.IconTheme.get_for_display (display);
        icon_theme.add_resource_path ("/io/elementary/granite");
    }

    private void set_provider_for_display (Gdk.Display display, bool prefer_dark_style) {
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

        if (prefer_dark_style) {
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
        var dark = prefers_dark ();

        foreach (var display in Gdk.DisplayManager.@get ().list_displays ()) {
            var gtk_settings = Gtk.Settings.get_for_display (display);
            gtk_settings.gtk_application_prefer_dark_theme = dark;
        }
    }

    private bool prefers_dark () {
        if (color_scheme_override == NO_PREFERENCE) {
            var granite_settings = Granite.Settings.get_default ();
            return granite_settings.prefers_color_scheme == DARK;
        } else {
            return color_scheme_override == DARK;
        }
    }
}
